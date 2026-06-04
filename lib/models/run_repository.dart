import 'package:shared_preferences/shared_preferences.dart';
import 'run_record.dart';

class RunRepository {
  static const _key = 'run_records';

  // ── Save ──────────────────────────────────────────────────────────────────
  static Future<void> save(RunRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.add(record);
    await prefs.setStringList(
      _key,
      all.map((r) => r.toJsonString()).toList(),
    );
  }

  // ── Fetch all (newest first) ───────────────────────────────────────────────
  static Future<List<RunRecord>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final records = raw.map(RunRecord.fromJsonString).toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  // ── Last 7 days (grouped by weekday Mon=0 … Sun=6) ───────────────────────
  static Future<Map<int, double>> getWeeklyDistanceByDay() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1)); // Monday

    final all = await getAll();
    final Map<int, double> result = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (final r in all) {
      final day = DateTime(r.date.year, r.date.month, r.date.day);
      if (!day.isBefore(startOfWeek) && !day.isAfter(DateTime(now.year, now.month, now.day))) {
        final index = day.difference(startOfWeek).inDays;
        if (index >= 0 && index <= 6) {
          result[index] = (result[index] ?? 0) + r.distanceKm;
        }
      }
    }
    return result;
  }

  // ── Weekly totals ─────────────────────────────────────────────────────────
  static Future<Map<String, num>> getWeeklyTotals() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final all = await getAll();
    double totalKm = 0;
    int totalCalories = 0;
    int totalMinutes = 0;

    for (final r in all) {
      final day = DateTime(r.date.year, r.date.month, r.date.day);
      if (!day.isBefore(startOfWeek)) {
        totalKm += r.distanceKm;
        totalCalories += r.calories;
        totalMinutes += r.durationSeconds ~/ 60;
      }
    }

    return {
      'km': totalKm,
      'calories': totalCalories,
      'minutes': totalMinutes,
    };
  }

  // ── All-time totals ───────────────────────────────────────────────────────
  static Future<Map<String, num>> getAllTimeTotals() async {
    final all = await getAll();
    double totalKm = 0;
    int totalCalories = 0;
    int totalMinutes = 0;

    for (final r in all) {
      totalKm += r.distanceKm;
      totalCalories += r.calories;
      totalMinutes += r.durationSeconds ~/ 60;
    }

    return {
      'km': totalKm,
      'calories': totalCalories,
      'minutes': totalMinutes,
    };
  }

  // ── Streak: berapa hari berturut-turut ada aktivitas (sampai hari ini) ────
  static Future<int> getCurrentStreak() async {
    final all = await getAll();
    if (all.isEmpty) return 0;

    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Kumpulkan semua tanggal unik yang ada aktivitas
    final activeDays = all
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet();

    int streak = 0;
    DateTime check = today;

    // Kalau hari ini belum lari, mulai hitung dari kemarin
    if (!activeDays.contains(today)) {
      check = today.subtract(const Duration(days: 1));
    }

    while (activeDays.contains(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // ── Streak week view (7 hari terakhir: index 0 = 6 hari lalu, 6 = hari ini)
  static Future<List<bool>> getStreakWeek() async {
    final all = await getAll();
    final activeDays = all
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet();

    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return activeDays.contains(day);
    });
  }

  // ── Badge checks ──────────────────────────────────────────────────────────
  static Future<Map<String, bool>> getBadges() async {
    final all = await getAll();
    final totals = await getAllTimeTotals();
    final streak = await getCurrentStreak();

    // Total langkah estimasi: 1 km ≈ 1300 langkah
    final estimatedSteps = (totals['km'] as double) * 1300;

    bool hasRun3km = all.any((r) => r.distanceKm >= 3.0);
    bool hasRun10km = all.any((r) => r.distanceKm >= 10.0);
    bool hasRun42km = all.any((r) => r.distanceKm >= 42.2);
    bool has1000Steps = estimatedSteps >= 1000;
    bool streak7 = streak >= 7;
    bool streak30 = streak >= 30;
    bool has5Sessions = all.length >= 5;
    bool earlyBird = all.any((r) => r.date.hour < 6);

    return {
      'first_run': all.isNotEmpty,
      '1000_steps': has1000Steps,
      '3km': hasRun3km,
      '10km': hasRun10km,
      '42km': hasRun42km,
      'streak_7': streak7,
      'streak_30': streak30,
      '5_sessions': has5Sessions,
      'early_bird': earlyBird,
    };
  }

  // ── Delete all (untuk testing) ────────────────────────────────────────────
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}