import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pedometer/pedometer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/run_record.dart';
import '../models/run_repository.dart';
import '../services/live_location_service.dart';
import '../widgets/share_location_button.dart';
import '../models/notification_repository.dart';

class TrackingScreen extends StatefulWidget {
  final String activityType;
  final double? distanceGoal;
  final int? timeGoal;
  final int? calorieGoal;

  const TrackingScreen({
    super.key,
    required this.activityType,
    this.distanceGoal,
    this.timeGoal,
    this.calorieGoal,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _routePoints = [];
  LatLng? _currentLatLng;

  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _goalReached = false;

  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  double _distanceKm = 0.0;
  double _currentSpeed = 0.0;
  String _gpsStatus = 'Menunggu GPS...';
  int _calories = 0;
  double _pace = 0.0;

  StreamSubscription<StepCount>? _stepCountStream;
  StreamSubscription<PedestrianStatus>? _pedestrianStream;
  int _steps = 0;
  int _stepsAtStart = 0;
  String _pedestrianStatus = 'stopped';

  bool _demoMode = false;
  Timer? _demoTimer;
  double _demoLat = -6.1754;
  double _demoLng = 106.8272;
  double _demoHeading = 45.0;
  static const double _demoSpeedMs = 3.0;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _initPedometer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    _demoTimer?.cancel();
    _stepCountStream?.cancel();
    _pedestrianStream?.cancel();
    if (_isRunning) LiveLocationService.stopTracking();
    super.dispose();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream.listen(
      (StepCount event) {
        if (!mounted) return;
        setState(() {
          if (_stepsAtStart == 0 && _isRunning) {
            _stepsAtStart = event.steps;
          }
          if (_isRunning && !_isPaused) {
            _steps = event.steps - _stepsAtStart;
          }
        });
      },
      onError: (_) {},
      cancelOnError: false,
    );

    _pedestrianStream = Pedometer.pedestrianStatusStream.listen(
      (PedestrianStatus event) {
        if (!mounted) return;
        setState(() => _pedestrianStatus = event.status);
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _gpsStatus = 'Izin GPS ditolak');
      return;
    }
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLatLng = LatLng(pos.latitude, pos.longitude);
        _gpsStatus = 'GPS siap';
        _demoLat = pos.latitude;
        _demoLng = pos.longitude;
      });
    } catch (e) {
      setState(() => _gpsStatus = 'Gagal ambil lokasi');
    }
  }

  void _startDemoTracking() {
    _demoTimer?.cancel();
    int demoSteps = 0;
    _demoTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused || !_isRunning) return;

      final headingRad = _demoHeading * math.pi / 180.0;
      final metersPerDegLng =
          111000.0 * math.cos(_demoLat * math.pi / 180.0);

      _demoLat += (_demoSpeedMs * math.cos(headingRad)) / 111000.0;
      _demoLng += (_demoSpeedMs * math.sin(headingRad)) / metersPerDegLng;

      if (_seconds % 15 == 0) {
        _demoHeading = (_demoHeading + 25) % 360;
      }

      demoSteps += 4;

      final newPoint = LatLng(_demoLat, _demoLng);
      setState(() {
        _distanceKm += _demoSpeedMs / 1000.0;
        _currentSpeed = _demoSpeedMs * 3.6;
        _currentLatLng = newPoint;
        _routePoints.add(newPoint);
        _steps = demoSteps;
      });
      _mapController.move(newPoint, 17);
      _checkGoals();
    });
  }

  void _startRealTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      final newPoint = LatLng(position.latitude, position.longitude);

      if (_lastPosition != null && !_isPaused) {
        if (position.accuracy > 20) {
          _lastPosition = position;
          return;
        }

        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        final speedMs = position.speed < 0 ? 0.0 : position.speed;
        if (speedMs < 1.0) {
          setState(() {
            _currentSpeed = 0.0;
            _currentLatLng = newPoint;
          });
          _mapController.move(newPoint, 17);
          _lastPosition = position;
          return;
        }

        setState(() {
          _distanceKm += distance / 1000;
          _currentSpeed = speedMs * 3.6;
          _currentLatLng = newPoint;
          _routePoints.add(newPoint);
        });
        _checkGoals();
        _mapController.move(newPoint, 17);
      }

      if (_routePoints.isEmpty) {
        setState(() => _routePoints.add(newPoint));
      }
      _lastPosition = position;
    });
  }

  void _startTracking() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _steps = 0;
      _stepsAtStart = 0;
    });

    if (!_demoMode) LiveLocationService.startTracking();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _seconds++;
        _calories = (_distanceKm * 60).toInt();
        if (_distanceKm > 0 && _seconds > 0) {
          _pace = (_seconds / 60) / _distanceKm;
        }
      });
      _checkGoals();
    });

    if (_demoMode) {
      _startDemoTracking();
    } else {
      _startRealTracking();
    }
  }

  void _pauseTracking() {
    setState(() => _isPaused = true);
    _timer?.cancel();
  }

  void _resumeTracking() {
    setState(() => _isPaused = false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
      _checkGoals();
    });
  }

  void _stopTracking() {
    _timer?.cancel();
    _positionStream?.cancel();
    _demoTimer?.cancel();
    if (!_demoMode) LiveLocationService.stopTracking();
    setState(() => _isRunning = false);
    _saveSession().then((_) => _showSummaryDialog());
  }

  void _checkGoals() {
    if (_goalReached) return;
    final distanceReached =
        widget.distanceGoal != null && _distanceKm >= widget.distanceGoal!;
    final timeReached =
        widget.timeGoal != null && (_seconds / 60) >= widget.timeGoal!;
    final calorieReached =
        widget.calorieGoal != null && _calories >= widget.calorieGoal!;

    if (distanceReached || timeReached || calorieReached) {
      _goalReached = true;
      _timer?.cancel();
      _positionStream?.cancel();
      _demoTimer?.cancel();
      if (!_demoMode) LiveLocationService.stopTracking();
      setState(() => _isRunning = false);
      _saveSession().then((_) => _showGoalAchievedDialog());
    }
  }

  // ── SAVE SESSION + SYNC FIRESTORE ─────────────────────────────────────────
  Future<void> _saveSession() async {
    if (_distanceKm < 0.01 && _seconds < 10) return;

    final badgesBefore = await RunRepository.getBadges();
    final streakBefore = await RunRepository.getCurrentStreak();

    final record = RunRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      activityType: widget.activityType,
      distanceKm: _distanceKm,
      durationSeconds: _seconds,
      calories: _calories,
      pace: _pace,
    );
    await RunRepository.save(record);

    // ── Sync ke Firestore ──────────────────────────────────────────────────
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final xpGained = (_distanceKm * 100).toInt(); // 100 XP per km
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        await docRef.update({
          'totalDistance': FieldValue.increment(_distanceKm),
          'totalSteps': FieldValue.increment(_steps),
          'xp': FieldValue.increment(xpGained),
          'achievements': FieldValue.increment(0), // update saat badge unlock
        });
      }
    } catch (e) {
      // Gagal sync Firestore — data lokal tetap tersimpan
    }

    final badgesAfter = await RunRepository.getBadges();
    final streakAfter = await RunRepository.getCurrentStreak();

    // ── Sync achievements ke Firestore kalau ada badge baru ───────────────
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newBadgesCount = badgesAfter.values.where((v) => v).length -
            badgesBefore.values.where((v) => v).length;
        if (newBadgesCount > 0) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'achievements': FieldValue.increment(newBadgesCount),
          });
        }
      }
    } catch (e) {}

    // Notifikasi sesi selesai
    await NotificationRepository.add(AppNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}_run',
      type: 'run',
      title: '${widget.activityType} Selesai! 🏃',
      body:
          '${_distanceKm.toStringAsFixed(2)} km • ${_formatTime(_seconds)} • $_calories kcal',
      date: DateTime.now(),
    ));

    // Cek streak baru
    if (streakAfter > streakBefore && streakAfter > 0) {
      String streakMsg = '';
      if (streakAfter == 3) {
        streakMsg = 'Awal yang bagus! Jaga terus momentumnya. 💪';
      } else if (streakAfter == 7) {
        streakMsg = 'Seminggu penuh! Kamu luar biasa! 🔥';
      } else if (streakAfter == 30) {
        streakMsg = 'LEGENDA! 30 hari streak! 🏆';
      } else {
        streakMsg = 'Pertahankan momentummu!';
      }

      await NotificationRepository.add(AppNotification(
        id: '${DateTime.now().millisecondsSinceEpoch}_streak',
        type: 'streak',
        title: '$streakAfter Day Streak! 🔥',
        body: streakMsg,
        date: DateTime.now(),
      ));
    }

    // Cek badge baru
    const badgeNames = {
      'first_run': 'First Step 👟',
      '1000_steps': '1K Walker 🚶',
      '3km': '5K Explorer 🗺️',
      '10km': '10K Finisher 🎽',
      '42km': 'Marathoner 🏅',
      'streak_7': 'Weekly Runner 📅',
      'streak_30': '30 Day Legend 🏆',
      '5_sessions': 'Fast Lane ⚡',
      'early_bird': 'Early Bird 🌅',
    };

    for (final key in badgesAfter.keys) {
      final wasUnlocked = badgesBefore[key] ?? false;
      final nowUnlocked = badgesAfter[key] ?? false;
      if (!wasUnlocked && nowUnlocked) {
        await NotificationRepository.add(AppNotification(
          id: '${DateTime.now().millisecondsSinceEpoch}_badge_$key',
          type: 'badge',
          title: 'Badge Baru Terbuka! 🏅',
          body: 'Kamu mendapat badge "${badgeNames[key] ?? key}"',
          date: DateTime.now(),
        ));
      }
    }
  }

  void _showGoalAchievedDialog() {
    String message = '';
    if (widget.distanceGoal != null && _distanceKm >= widget.distanceGoal!) {
      message = '🎉 Target jarak ${widget.distanceGoal} KM tercapai!';
    } else if (widget.timeGoal != null &&
        (_seconds / 60) >= widget.timeGoal!) {
      final h = widget.timeGoal! ~/ 60;
      final m = widget.timeGoal! % 60;
      message =
          '🎉 Target waktu ${h > 0 ? "$h jam $m menit" : "$m menit"} tercapai!';
    } else if (widget.calorieGoal != null && _calories >= widget.calorieGoal!) {
      message = '🎉 Target ${widget.calorieGoal} kalori terbakar!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Goal Tercapai! 🎯',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            _summaryRow('Jarak', '${_distanceKm.toStringAsFixed(2)} km'),
            _summaryRow('Durasi', _formatTime(_seconds)),
            _summaryRow('Kalori', '$_calories kcal'),
            _summaryRow('Langkah', '$_steps langkah'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Selesai',
                style: TextStyle(color: Color(0xFF0ABFDB))),
          ),
        ],
      ),
    );
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sesi Tersimpan! 🎉',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_demoMode)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('⚠️ Data dari Demo Mode',
                    style: TextStyle(fontSize: 12, color: Color(0xFF856404))),
              ),
            _summaryRow('Jarak', '${_distanceKm.toStringAsFixed(2)} km'),
            _summaryRow('Durasi', _formatTime(_seconds)),
            _summaryRow('Kalori', '$_calories kcal'),
            _summaryRow('Pace', '${_pace.toStringAsFixed(1)} min/km'),
            _summaryRow('Langkah', '$_steps langkah'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Selesai',
                style: TextStyle(color: Color(0xFF0ABFDB))),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9CA3AF))),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Color(0xFF0A4F66), size: 16),
                    ),
                  ),
                  const Expanded(
                    child: Text('Start Activity',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A4F66))),
                  ),
                  GestureDetector(
                    onTap: _isRunning
                        ? null
                        : () => setState(() => _demoMode = !_demoMode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _demoMode
                            ? const Color(0xFFFFF3CD)
                            : const Color(0xFFEAF7FB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _demoMode
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF0ABFDB),
                        ),
                      ),
                      child: Text(
                        _demoMode ? '🎮 Demo' : '📡 Real',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _demoMode
                              ? const Color(0xFF856404)
                              : const Color(0xFF0A4F66),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (widget.distanceGoal != null ||
                widget.timeGoal != null ||
                widget.calorieGoal != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A4F66).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (widget.distanceGoal != null)
                        _GoalChip(
                            icon: Icons.straighten,
                            label: '${widget.distanceGoal} KM',
                            current: _distanceKm,
                            target: widget.distanceGoal!),
                      if (widget.timeGoal != null)
                        _GoalChip(
                            icon: Icons.timer,
                            label: '${widget.timeGoal} MIN',
                            current: _seconds / 60,
                            target: widget.timeGoal!.toDouble()),
                      if (widget.calorieGoal != null)
                        _GoalChip(
                            icon: Icons.local_fire_department,
                            label: '${widget.calorieGoal} KCAL',
                            current: _calories.toDouble(),
                            target: widget.calorieGoal!.toDouble()),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _currentLatLng == null
                          ? Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Color(0xFF1A6B8A),
                                  Color(0xFF0A3A50)
                                ]),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.map_outlined,
                                        size: 60,
                                        color: Colors.white
                                            .withValues(alpha: 0.3)),
                                    const SizedBox(height: 12),
                                    Text(_gpsStatus,
                                        style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.7),
                                            fontSize: 14)),
                                    const SizedBox(height: 8),
                                    const CircularProgressIndicator(
                                        color: Color(0xFF0ABFDB)),
                                  ],
                                ),
                              ),
                            )
                          : FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                  initialCenter: _currentLatLng!,
                                  initialZoom: 17),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.moversec',
                                ),
                                if (_routePoints.length > 1)
                                  PolylineLayer(polylines: [
                                    Polyline(
                                        points: _routePoints,
                                        color: const Color(0xFF0ABFDB),
                                        strokeWidth: 5),
                                  ]),
                                if (_currentLatLng != null)
                                  MarkerLayer(markers: [
                                    Marker(
                                      point: _currentLatLng!,
                                      width: 40, height: 40,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF0ABFDB),
                                          border: Border.all(
                                              color: Colors.white, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                                color: const Color(0xFF0ABFDB)
                                                    .withValues(alpha: 0.4),
                                                blurRadius: 10,
                                                spreadRadius: 3)
                                          ],
                                        ),
                                        child: const Icon(Icons.navigation,
                                            color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ]),
                              ],
                            ),
                    ),
                  ),

                  Positioned(
                    top: 16, left: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)]),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8)
                        ],
                      ),
                      child: Text(widget.activityType,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),

                  Positioned(
                    top: 16, right: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _demoMode
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.9)
                            : Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(children: [
                        Container(
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            color: _isRunning
                                ? (_demoMode
                                    ? Colors.white
                                    : const Color(0xFF00E5A0))
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _demoMode
                              ? (_isRunning ? 'Demo Running' : 'Demo Mode')
                              : (_isRunning ? 'Live GPS' : 'GPS Siap'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ]),
                    ),
                  ),

                  Positioned(
                    bottom: 0, left: 24, right: 24,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, -4))
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(_formatTime(_seconds),
                              style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0A1628),
                                  letterSpacing: 2)),
                          const Text('DURASI',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9CA3AF),
                                  letterSpacing: 1.5)),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatBox(
                                  value: _distanceKm.toStringAsFixed(2),
                                  unit: 'KM',
                                  label: 'Jarak'),
                              Container(
                                  width: 1, height: 40,
                                  color: const Color(0xFFE5E7EB)),
                              _StatBox(
                                  value: _currentSpeed.toStringAsFixed(1),
                                  unit: 'km/h',
                                  label: 'Kecepatan'),
                              Container(
                                  width: 1, height: 40,
                                  color: const Color(0xFFE5E7EB)),
                              _StatBox(
                                  value: '$_calories',
                                  unit: 'kcal',
                                  label: 'Kalori'),
                              Container(
                                  width: 1, height: 40,
                                  color: const Color(0xFFE5E7EB)),
                              _StatBox(
                                  value: '$_steps',
                                  unit: 'steps',
                                  label: 'Langkah'),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (_isRunning && !_demoMode) ...[
                            ShareLocationButton(isRunning: _isRunning),
                            const SizedBox(height: 12),
                          ],

                          if (_demoMode && !_isRunning)
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3CD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 14, color: Color(0xFF856404)),
                                  SizedBox(width: 6),
                                  Text('Demo Mode aktif — data simulasi',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF856404),
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),

                          if (!_isRunning)
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Color(0xFF0ABFDB),
                                    Color(0xFF00E5A0)
                                  ]),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      (_currentLatLng != null || _demoMode)
                                          ? _startTracking
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                  ),
                                  child: Text(
                                    _demoMode
                                        ? 'Mulai Demo'
                                        : (_currentLatLng == null
                                            ? 'Menunggu GPS...'
                                            : 'Mulai Aktivitas'),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isPaused
                                        ? _resumeTracking
                                        : _pauseTracking,
                                    icon: Icon(_isPaused
                                        ? Icons.play_arrow
                                        : Icons.pause),
                                    label:
                                        Text(_isPaused ? 'Lanjut' : 'Jeda'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          const Color(0xFF0ABFDB),
                                      side: const BorderSide(
                                          color: Color(0xFF0ABFDB)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF0ABFDB),
                                            Color(0xFF00E5A0)
                                          ]),
                                      borderRadius:
                                          BorderRadius.circular(100),
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: _stopTracking,
                                      icon: const Icon(Icons.stop_rounded),
                                      label: const Text('Selesai'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, unit, label;
  const _StatBox(
      {required this.value, required this.unit, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(
                text: value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1628))),
            TextSpan(
                text: ' $unit',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF))),
          ]),
        ),
        const SizedBox(height: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}

class _GoalChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double current;
  final double target;
  const _GoalChip(
      {required this.icon,
      required this.label,
      required this.current,
      required this.target});

  @override
  Widget build(BuildContext context) {
    final percentage = (current / target).clamp(0.0, 1.0);
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0A4F66)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A4F66))),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFD6EEF7),
            color: const Color(0xFF0ABFDB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text('${(percentage * 100).toInt()}%',
            style:
                const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}