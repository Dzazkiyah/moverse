import 'package:flutter/material.dart';
import '../models/run_record.dart';
import '../models/run_repository.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<RunRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await RunRepository.getAll();
    if (mounted) {
      setState(() {
        _records = records;
        _loading = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h}j ${m}m ${s}d';
    }
    return '${m}m ${s}d';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';

    return '${date.day}/${date.month}/${date.year}';
  }

  // Kelompokkan records per hari
  Map<String, List<RunRecord>> _groupByDate() {
    final Map<String, List<RunRecord>> grouped = {};
    for (final r in _records) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final recordDay = DateTime(r.date.year, r.date.month, r.date.day);

      String label;
      if (recordDay == today) {
        label = 'Hari Ini';
      } else if (recordDay == yesterday) {
        label = 'Kemarin';
      } else {
        label = '${r.date.day}/${r.date.month}/${r.date.year}';
      }

      grouped.putIfAbsent(label, () => []).add(r);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar — badge sesi dihapus
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Color(0xFF0A4F66), size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text('Riwayat Aktivitas',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A1628))),
                ],
              ),
            ),

            // Loading
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF0ABFDB)),
                ),
              )
            // Empty state
            else if (_records.isEmpty)
              Expanded(child: _buildEmptyState())
            // List
            else
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF0ABFDB),
                  onRefresh: _loadRecords,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Summary card total
                      _buildSummaryCard(),
                      const SizedBox(height: 24),

                      // List per grup tanggal
                      ...grouped.entries.map((entry) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label tanggal
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0A4F66),
                                      letterSpacing: 0.5),
                                ),
                              ),
                              // Cards dalam grup
                              ...entry.value.map((record) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _RunCard(
                                      record: record,
                                      formatDuration: _formatDuration,
                                      formatDate: _formatDate,
                                    ),
                                  )),
                              const SizedBox(height: 8),
                            ],
                          )),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalKm = _records.fold(0.0, (sum, r) => sum + r.distanceKm);
    final totalCal = _records.fold(0, (sum, r) => sum + r.calories);
    final totalSec = _records.fold(0, (sum, r) => sum + r.durationSeconds);
    final totalMin = totalSec ~/ 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0ABFDB).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Semua Waktu',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                value: totalKm.toStringAsFixed(1),
                unit: 'km',
                label: 'Jarak',
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              _SummaryItem(
                value: '$totalCal',
                unit: 'kcal',
                label: 'Kalori',
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              _SummaryItem(
                value: '$totalMin',
                unit: 'menit',
                label: 'Durasi',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0ABFDB).withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.directions_run,
                size: 40, color: Color(0xFFB0C4CC)),
          ),
          const SizedBox(height: 20),
          const Text('Belum ada aktivitas',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1628))),
          const SizedBox(height: 8),
          const Text('Mulai lari pertamamu sekarang!',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

// ── Run Card ──────────────────────────────────────────────────────────────────
class _RunCard extends StatelessWidget {
  final RunRecord record;
  final String Function(int) formatDuration;
  final String Function(DateTime) formatDate;

  const _RunCard({
    required this.record,
    required this.formatDuration,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final isRun = record.activityType.toLowerCase() == 'running';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon aktivitas
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isRun
                  ? const Color(0xFFD6F5FB)
                  : const Color(0xFFD6FBF0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isRun ? Icons.directions_run : Icons.directions_walk,
              color: isRun
                  ? const Color(0xFF0ABFDB)
                  : const Color(0xFF00E5A0),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(record.activityType,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A1628))),
                    Text(formatDate(record.date),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MiniStat(
                      icon: Icons.straighten,
                      value: '${record.distanceKm.toStringAsFixed(2)} km',
                    ),
                    const SizedBox(width: 12),
                    _MiniStat(
                      icon: Icons.timer_outlined,
                      value: formatDuration(record.durationSeconds),
                    ),
                    const SizedBox(width: 12),
                    _MiniStat(
                      icon: Icons.local_fire_department_outlined,
                      value: '${record.calories} kcal',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MiniStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 3),
        Text(value,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value, unit, label;

  const _SummaryItem(
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
                    color: Colors.white)),
            TextSpan(
                text: ' $unit',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }
}