import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

class LiveLocationService {
  static Timer? _timer;
  static bool _isActive = false;
  static String? _sessionId;

  static Future<void> startTracking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isActive = true;
    // Buat session ID unik tiap sesi lari
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!_isActive) return;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await _updateLocation(user.uid, position.latitude, position.longitude);
      } catch (e) {}
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _updateLocation(user.uid, position.latitude, position.longitude);
    } catch (e) {}
  }

  static Future<void> _updateLocation(
      String uid, double lat, double lng) async {
    await FirebaseFirestore.instance
        .collection('live_sessions')   // ← koleksi baru, publik bisa dibaca
        .doc(_sessionId)
        .set({
      'lat': lat,
      'lng': lng,
      'uid': uid,
      'isActive': true,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> stopTracking() async {
    _isActive = false;
    _timer?.cancel();
    _timer = null;

    if (_sessionId == null) return;
    await FirebaseFirestore.instance
        .collection('live_sessions')
        .doc(_sessionId)
        .update({'isActive': false});
  }

  // Link ke halaman live tracking (bukan snapshot)
  static String? getLiveLink() {
  if (_sessionId == null) return null;
  return 'https://moversec-ae404.web.app/live.html?id=$_sessionId';
  }

  static Future<void> shareLocation(String userName) async {
    final link = getLiveLink();
    if (link == null) return;

    final message =
        '🏃 $userName sedang berlari dan berbagi lokasi!\n\n'
        'Pantau posisi saya secara LIVE di sini:\n$link\n\n'
        '📍 Posisi update otomatis tiap 10 detik\n'
        '⚠️ Link aktif selama sesi lari berlangsung.';

    await Share.share(message);
  }

  static bool get isActive => _isActive;
  static String? get sessionId => _sessionId;
}