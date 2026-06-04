import 'package:flutter/material.dart';
import '../models/run_repository.dart';

enum BadgeCategory { harian, jarak, kecepatan }

class BadgeDetailScreen extends StatefulWidget {
  final BadgeCategory category;
  final Map<String, bool> badges;

  const BadgeDetailScreen({
    super.key,
    required this.category,
    required this.badges,
  });

  @override
  State<BadgeDetailScreen> createState() => _BadgeDetailScreenState();
}

class _BadgeDetailScreenState extends State<BadgeDetailScreen> {
  Map<String, bool> _badges = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _badges = widget.badges;
    _loadFresh();
  }

  Future<void> _loadFresh() async {
    final fresh = await RunRepository.getBadges();
    setState(() {
      _badges = fresh;
      _loading = false;
    });
  }

  String get _categoryTitle {
    switch (widget.category) {
      case BadgeCategory.harian: return 'Early Bird Badges';
      case BadgeCategory.jarak:  return 'Distance Badges';
      case BadgeCategory.kecepatan: return 'Speed Badges';
    }
  }

  String get _badgeImagePath {
    switch (widget.category) {
      case BadgeCategory.harian:    return 'assets/badges/badge_earlybird.png';
      case BadgeCategory.jarak:     return 'assets/badges/badge_distance.png';
      case BadgeCategory.kecepatan: return 'assets/badges/badge_speed.png';
    }
  }

  List<_Challenge> get _allChallenges {
    switch (widget.category) {
      case BadgeCategory.harian:
        return [
          _Challenge(
            key: 'first_run',
            title: 'First Step',
            desc: 'Menyelesaikan 1 kali lari berturut-turut sebelum pukul 07.00 pagi.',
            avatarItem: 'Jersey Hitam',
          ),
          _Challenge(
            key: 'early_bird_2',
            title: '1K Walker',
            desc: 'Workout sebelum jam 07.00 pagi sebanyak 2 kali.',
            avatarItem: null,
          ),
          _Challenge(
            key: 'early_bird_streak3',
            title: 'Morning Spirit',
            desc: 'Lari 3 hari berturut-turut.',
            avatarItem: 'Headband Hijau',
          ),
          _Challenge(
            key: 'streak_7',
            title: 'Weekly Runner',
            desc: 'Seminggu tanpa menyerah! Menyelesaikan 7 lari berturut-turut.',
            avatarItem: 'Jersey Streak',
          ),
          _Challenge(
            key: 'early_bird',
            title: 'Early Bird',
            desc: 'Lari sebelum jam 6 pagi sebanyak 5 kali.',
            avatarItem: 'Jersey Hitam',
          ),
        ];

      case BadgeCategory.jarak:
        return [
          _Challenge(
            key: '1000_steps',
            title: '1K Walker',
            desc: 'Berhasil mencapai 1.000 langkah pertama.',
            avatarItem: 'Kaus Kaki Putih',
          ),
          _Challenge(
            key: 'first_run',
            title: 'Step Collector',
            desc: 'Mengumpulkan total 5.000 langkah.',
            avatarItem: null,
          ),
          _Challenge(
            key: '3km',
            title: '5K Explorer',
            desc: 'Menyelesaikan total jarak 5 km.',
            avatarItem: null,
          ),
          _Challenge(
            key: '10km',
            title: '10K Finisher',
            desc: 'Berhasil menyelesaikan lari 10 km pertama.',
            avatarItem: null,
          ),
          _Challenge(
            key: '42km',
            title: 'Marathoner',
            desc: 'Menyelesaikan 42.2 km dalam satu sesi.',
            avatarItem: null,
          ),
        ];

      case BadgeCategory.kecepatan:
        return [
          _Challenge(
            key: 'first_run',
            title: 'Pace Starter',
            desc: 'Menyelesaikan lari dengan pace stabil pertama.',
            avatarItem: null,
          ),
          _Challenge(
            key: '3km',
            title: 'Speed Hunter',
            desc: 'Menyelesaikan 3 km dengan peningkatan pace pribadi.',
            avatarItem: null,
          ),
          _Challenge(
            key: '5_sessions',
            title: 'Fast Lane',
            desc: 'Menyelesaikan lari dengan pace di bawah target aplikasi.',
            avatarItem: 'Jaket Speed',
          ),
          _Challenge(
            key: '10km',
            title: 'Lightning Runner',
            desc: 'Mencapai rekor kecepatan terbaik.',
            avatarItem: null,
          ),
        ];
    }
  }

  List<_Challenge> get _earnedChallenges =>
      _allChallenges.where((c) => _badges[c.key] == true).toList();

  List<_Challenge> get _lockedChallenges =>
      _allChallenges.where((c) => _badges[c.key] != true).toList();

  int get _totalCount => _allChallenges.length;
  int get _earnedCount => _earnedChallenges.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FB),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Color(0xFF0A4F66), size: 16),
                    ),
                  ),
                  Expanded(
                    child: Text(_categoryTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold, color: Color(0xFF0A4F66))),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0ABFDB)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Collection card ──────────────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                const Text('YOUR COLLECTION',
                                    style: TextStyle(fontSize: 11, letterSpacing: 1.5,
                                        color: Color(0xFF0A4F66), fontWeight: FontWeight.w600)),
                                const SizedBox(height: 16),
                                _BadgeHexImage(
                                  imagePath: _badgeImagePath,
                                  size: 100,
                                  unlocked: _earnedCount > 0,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '$_earnedCount / $_totalCount Earned',
                                  style: const TextStyle(fontSize: 24,
                                      fontWeight: FontWeight.bold, color: Color(0xFF0A1628)),
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: LinearProgressIndicator(
                                    value: _totalCount == 0 ? 0 : _earnedCount / _totalCount,
                                    minHeight: 6,
                                    backgroundColor: Colors.white.withValues(alpha: 0.5),
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF0ABFDB)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Recently earned ──────────────────────────
                          Row(
                            children: [
                              Container(
                                width: 4, height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0ABFDB),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Recently Earned',
                                  style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (_earnedChallenges.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text('Belum ada yang diraih. Ayo mulai berlari!',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                            )
                          else
                            ..._earnedChallenges.map((c) => _ChallengeListTile(
                              challenge: c,
                              earned: true,
                            )),

                          const SizedBox(height: 24),

                          // ── Locked challenges ────────────────────────
                          Row(
                            children: [
                              Container(
                                width: 4, height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1D5DB),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Locked Challenges',
                                  style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
                            ],
                          ),
                          const SizedBox(height: 12),

                          ..._lockedChallenges.map((c) => _ChallengeListTile(
                            challenge: c,
                            earned: false,
                          )),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model challenge ─────────────────────────────────────────────────────
class _Challenge {
  final String key;
  final String title;
  final String desc;
  final String? avatarItem; // null = tidak ada reward item avatar

  const _Challenge({
    required this.key,
    required this.title,
    required this.desc,
    this.avatarItem,
  });
}

// ── Challenge list tile ──────────────────────────────────────────────────────
class _ChallengeListTile extends StatelessWidget {
  final _Challenge challenge;
  final bool earned;

  const _ChallengeListTile({required this.challenge, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: earned
                  ? const Color(0xFF0ABFDB).withValues(alpha: 0.15)
                  : const Color(0xFFE5E7EB),
            ),
            child: Icon(
              earned ? Icons.local_fire_department : Icons.local_fire_department_outlined,
              color: earned ? const Color(0xFF0ABFDB) : const Color(0xFFD1D5DB),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(challenge.title,
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold,
                          color: earned ? const Color(0xFF0A1628) : const Color(0xFF6B7280),
                        )),
                    if (earned)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.check_circle, color: Color(0xFF00E5A0), size: 16),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(challenge.desc,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                // Avatar item reward
                if (challenge.avatarItem != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.checkroom, size: 12, color: Color(0xFF0ABFDB)),
                      const SizedBox(width: 4),
                      Text(
                        'Unlock: ${challenge.avatarItem}',
                        style: TextStyle(
                          fontSize: 11,
                          color: earned
                              ? const Color(0xFF0ABFDB)
                              : const Color(0xFFD1D5DB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hexagon badge image ──────────────────────────────────────────────────────
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