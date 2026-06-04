import 'package:flutter/material.dart';
import '../models/run_record.dart';
import '../models/run_repository.dart';
import '../widgets/notification_icon.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  double _calorieGoal = 650;

  // Data dari repository
  bool _loading = true;
  double _totalKm = 0;
  int _totalCalories = 0;
  int _totalMinutes = 0;
  Map<int, double> _weeklyKm = {};
  List<RunRecord> _recentRuns = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final totals = await RunRepository.getAllTimeTotals();
    final weekly = await RunRepository.getWeeklyDistanceByDay();
    final recent = await RunRepository.getAll();

    setState(() {
      _totalKm = (totals['km'] as double);
      _totalCalories = (totals['calories'] as int);
      _totalMinutes = (totals['minutes'] as int);
      _weeklyKm = weekly;
      _recentRuns = recent.take(5).toList();
      _loading = false;
    });
  }

  String _formatKm(double km) {
    if (km >= 1000) return '${(km / 1000).toStringAsFixed(1)}K';
    return km.toStringAsFixed(1);
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF0ABFDB),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('MOVERSE',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5,
                            color: Color(0xFF0A4F66))),
                    NotificationIcon(),
                  ],
                ),
                const SizedBox(height: 28),
                const Text('YOUR MOMENTUM',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        color: Color(0xFF0ABFDB),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Steady & Strong.',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A1628))),
                const SizedBox(height: 20),

                // ── Total Distance card ───────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL DISTANCE',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: _formatKm(_totalKm),
                                      style: const TextStyle(
                                          fontSize: 52,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  const TextSpan(
                                      text: ' KM',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.directions_run,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                '${_recentRuns.length} sesi tercatat',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ]),
                          ],
                        ),
                ),
                const SizedBox(height: 16),

                // ── Calories + Active min ─────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                          label: 'CALORIES',
                          value: _loading
                              ? '—'
                              : _totalCalories.toString(),
                          unit: 'KCAL'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                          label: 'ACTIVE MIN',
                          value: _loading
                              ? '—'
                              : _totalMinutes.toString(),
                          unit: 'MINS'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Activity Flow bar chart ────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6F0F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Activity Flow',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0A1628))),
                              Text('7 hari terakhir',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9CA3AF))),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(children: [
                              const CircleAvatar(
                                  radius: 4,
                                  backgroundColor: Color(0xFF0ABFDB)),
                              const SizedBox(width: 6),
                              Text(
                                _loading
                                    ? '—'
                                    : 'Avg: ${(_weeklyKm.values.where((v) => v > 0).isEmpty ? 0 : _weeklyKm.values.where((v) => v > 0).reduce((a, b) => a + b) / _weeklyKm.values.where((v) => v > 0).length).toStringAsFixed(1)}km',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF0A1628),
                                    fontWeight: FontWeight.w600),
                              ),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF0ABFDB)))
                          : _RealBarChart(weeklyKm: _weeklyKm),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── History 5 sesi terakhir ───────────────────────────────
                if (!_loading && _recentRuns.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Riwayat Terkini',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A1628))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._recentRuns.map((r) => _HistoryTile(record: r,
                            formatDuration: _formatDuration)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Calorie goal slider ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF7FB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.fitness_center,
                                color: Color(0xFF0ABFDB), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Calories\nBurn Goal',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A1628),
                                        height: 1.3)),
                                SizedBox(height: 4),
                                Text('Recommended for your activity level',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: '${_calorieGoal.toInt()}',
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A1628)),
                              ),
                              const TextSpan(
                                  text: ' KCAL',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9CA3AF),
                                      fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF0ABFDB),
                          inactiveTrackColor: const Color(0xFFE5E7EB),
                          thumbColor: const Color(0xFF0A4F66),
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 10),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 18),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: _calorieGoal,
                          min: 100,
                          max: 2500,
                          onChanged: (v) =>
                              setState(() => _calorieGoal = v),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('100 KCAL',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF9CA3AF))),
                          Text('TARGET BURN',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF0ABFDB),
                                  fontWeight: FontWeight.w600)),
                          Text('2500 KCAL',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bar Chart dengan data real ──────────────────────────────────────────────
class _RealBarChart extends StatelessWidget {
  final Map<int, double> weeklyKm;
  const _RealBarChart({required this.weeklyKm});

  @override
  Widget build(BuildContext context) {
    const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    final today = DateTime.now().weekday - 1; // 0=Mon … 6=Sun

    // max untuk normalisasi height
    final maxKm = weeklyKm.values.isEmpty
        ? 1.0
        : weeklyKm.values.reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxKm < 1.0 ? 1.0 : maxKm;

    return Column(
      children: [
        SizedBox(
          height: 130,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final km = weeklyKm[i] ?? 0.0;
              final heightFactor = km / effectiveMax;
              final isToday = i == today;
              final hasRun = km > 0;

              Color barColor;
              if (isToday && hasRun) {
                barColor = const Color(0xFF0A4F66);
              } else if (hasRun) {
                barColor = const Color(0xFF0ABFDB);
              } else {
                barColor = const Color(0xFFB8E0EF);
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasRun)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${km.toStringAsFixed(1)}',
                        style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF0A4F66),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: hasRun ? heightFactor.clamp(0.05, 1.0) : 0.05,
                        child: Container(
                          width: 30,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(days[i],
                      style: TextStyle(
                          fontSize: 10,
                          color: isToday
                              ? const Color(0xFF0A4F66)
                              : const Color(0xFF9CA3AF),
                          fontWeight: isToday
                              ? FontWeight.w800
                              : FontWeight.w600)),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        // Legenda
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: const Color(0xFF0A4F66), label: 'Hari ini'),
            const SizedBox(width: 16),
            _LegendDot(color: const Color(0xFF0ABFDB), label: 'Ada aktivitas'),
            const SizedBox(width: 16),
            _LegendDot(color: const Color(0xFFB8E0EF), label: 'Tidak ada'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}

// ── History tile ─────────────────────────────────────────────────────────────
class _HistoryTile extends StatelessWidget {
  final RunRecord record;
  final String Function(int) formatDuration;
  const _HistoryTile({required this.record, required this.formatDuration});

  @override
  Widget build(BuildContext context) {
    final d = record.date;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              record.activityType == 'Running'
                  ? Icons.directions_run
                  : Icons.directions_walk,
              color: const Color(0xFF0ABFDB),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.activityType,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0A1628))),
                Text(dateStr,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${record.distanceKm.toStringAsFixed(2)} km',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1628))),
              Text(formatDuration(record.durationSeconds),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, unit;
  const _StatCard(
      {required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1628))),
          Text(unit,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}