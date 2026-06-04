import 'package:flutter/material.dart';
import '../models/run_repository.dart';
import '../widgets/notification_icon.dart';
import 'badge_detail_screen.dart';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  bool _loading = true;
  int _streak = 0;
  List<bool> _streakWeek = List.filled(7, false);
  Map<String, bool> _badges = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final streak = await RunRepository.getCurrentStreak();
    final week = await RunRepository.getStreakWeek();
    final badges = await RunRepository.getBadges();
    setState(() {
      _streak = streak;
      _streakWeek = week;
      _badges = badges;
      _loading = false;
    });
  }

  String get _streakMessage {
    if (_streak == 0) return 'Mulai larianmu hari ini!';
    if (_streak < 3) return 'Awal yang bagus! Jaga terus momentumnya.';
    if (_streak < 7) return "You're on fire! Keep the kinetic\nflow going today.";
    if (_streak < 30) return 'Luar biasa! Konsistensimu menginspirasi!';
    return 'LEGENDA! Kamu tak tertandingi!';
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
                            fontSize: 16, fontWeight: FontWeight.w800,
                            letterSpacing: 2.5, color: Color(0xFF0A4F66))),
                    NotificationIcon(),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Streak card ──────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('YOUR MOMENTUM',
                                style: TextStyle(fontSize: 11, color: Colors.white70,
                                    letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(
                              _streak == 0 ? 'BELUM ADA STREAK' : '$_streak DAY STREAK',
                              style: const TextStyle(fontSize: 28,
                                  fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(_streakMessage,
                                style: const TextStyle(fontSize: 13,
                                    color: Colors.white70, height: 1.5)),
                            const SizedBox(height: 20),
                            _StreakWeekRow(days: _streakWeek),
                          ],
                        ),
                ),

                const SizedBox(height: 28),
                const Text('Unlocked Badges',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                        color: Color(0xFF0A1628))),
                const SizedBox(height: 16),

                if (_loading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF0ABFDB)))
                else ...[
                  // ── Featured badge ───────────────────────────────────
                  _FeaturedBadgeCard(badges: _badges),
                  const SizedBox(height: 20),

                  // ── Badge grid (3 badges, Item dihapus dulu) ─────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      _BadgeCategoryCard(
                        title: 'Early Bird',
                        subtitle: 'Run before 6AM for 5 days',
                        imagePath: 'assets/badges/badge_earlybird.png',
                        badgeKey: 'early_bird',
                        unlocked: true, // selalu terbuka
                        category: BadgeCategory.harian,
                        allBadges: _badges,
                        onTap: () => _openDetail(BadgeCategory.harian),
                      ),
                      _BadgeCategoryCard(
                        title: 'Speed Demon',
                        subtitle: 'Achieved 4:00/km pace',
                        imagePath: 'assets/badges/badge_speed.png',
                        badgeKey: 'speed_demon',
                        unlocked: true, // selalu terbuka
                        isNew: true,
                        category: BadgeCategory.kecepatan,
                        allBadges: _badges,
                        onTap: () => _openDetail(BadgeCategory.kecepatan),
                      ),
                      _BadgeCategoryCard(
                        title: 'Trail Blazer',
                        subtitle: 'First 10km trail run',
                        imagePath: 'assets/badges/badge_distance.png',
                        badgeKey: '10km',
                        unlocked: true, // selalu terbuka
                        category: BadgeCategory.jarak,
                        allBadges: _badges,
                        onTap: () => _openDetail(BadgeCategory.jarak),
                      ),
                      // Badge "Item" dihapus dulu,
                      // akan ditambahkan kembali setelah sistem avatar selesai
                    ],
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetail(BadgeCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BadgeDetailScreen(category: category, badges: _badges),
      ),
    ).then((_) => _loadData());
  }
}

// ── Featured badge card ──────────────────────────────────────────────────────
class _FeaturedBadgeCard extends StatelessWidget {
  final Map<String, bool> badges;
  const _FeaturedBadgeCard({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Badge image — selalu unlocked (warna penuh)
          _BadgeHexImage(
            imagePath: 'assets/badges/badge_earlybird.png',
            size: 90,
            unlocked: true,
          ),
          const SizedBox(height: 16),
          const Text('Marathoner',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1628))),
          const SizedBox(height: 6),
          const Text('Completed 42.2km in a single session',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7FB),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text('LEGENDARY',
                style: TextStyle(fontSize: 11, color: Color(0xFF0ABFDB),
                    fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ── Badge category card (grid) ───────────────────────────────────────────────
class _BadgeCategoryCard extends StatelessWidget {
  final String title, subtitle, imagePath, badgeKey;
  final bool unlocked;
  final bool isNew;
  final BadgeCategory category;
  final Map<String, bool> allBadges;
  final VoidCallback onTap;

  const _BadgeCategoryCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.badgeKey,
    required this.unlocked,
    required this.category,
    required this.allBadges,
    required this.onTap,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _BadgeHexImage(
                  imagePath: imagePath,
                  size: 72,
                  unlocked: unlocked, // akan selalu true dari parent
                ),
                if (isNew)
                  Positioned(
                    top: -4, right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text('New!',
                          style: TextStyle(fontSize: 9, color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1628))), // selalu warna penuh
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                textAlign: TextAlign.center,
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Hexagon badge image widget ───────────────────────────────────────────────
class _BadgeHexImage extends StatelessWidget {
  final String imagePath;
  final double size;
  final bool unlocked;

  const _BadgeHexImage({
    required this.imagePath,
    required this.size,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    if (!unlocked) {
      return SizedBox(
        width: size,
        height: size,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ]),
          child: Opacity(
            opacity: 0.4,
            child: Image.asset(
              imagePath,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.lock,
                color: const Color(0xFFD1D5DB),
                size: size * 0.4,
              ),
            ),
          ),
        ),
      );
    }

    // Unlocked: tampil gambar asli warna penuh
    return Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.emoji_events,
        color: const Color(0xFF0ABFDB),
        size: size * 0.5,
      ),
    );
  }
}

// ── Streak week row ──────────────────────────────────────────────────────────
class _StreakWeekRow extends StatelessWidget {
  final List<bool> days;
  const _StreakWeekRow({required this.days});

  @override
  Widget build(BuildContext context) {
    const labels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    final today = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return labels[d.weekday - 1];
    });
    final isToday = List.generate(7, (i) => i == 6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final done = days[i];
        final today_ = isToday[i];
        return Column(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: today_
                    ? Colors.white
                    : Colors.white.withValues(alpha: done ? 0.3 : 0.15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Center(
                child: today_
                    ? Icon(done ? Icons.local_fire_department : Icons.radio_button_unchecked,
                        color: const Color(0xFF0ABFDB), size: 16)
                    : done
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : const SizedBox(),
              ),
            ),
            const SizedBox(height: 6),
            Text(dayLabels[i],
                style: const TextStyle(fontSize: 11,
                    color: Colors.white70, fontWeight: FontWeight.w600)),
          ],
        );
      }),
    );
  }
}