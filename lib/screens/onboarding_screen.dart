import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'tag': 'TRACK YOUR MOVEMENT',
      'title': 'Start Tracking\nYour Activity',
      'desc': 'Record your daily runs and walks automatically. Every step you take fuels your kinetic energy to earn exclusive rewards.',
      'type': 'tracking',
    },
    {
      'tag': 'LEVEL UP YOUR JOURNEY',
      'title': 'Earn Avatar\nRewards',
      'desc': 'Running and walking unlocks exclusive gear for your mascot. Track your movement to build the ultimate digital athlete.',
      'type': 'rewards',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDF3F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar — logo tengah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: Text(
                  'Moverse',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0A1628),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(page: _pages[index]);
                },
              ),
            ),

            // Bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: Column(
                children: [
                  // ── Gradient button ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0ABFDB).withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Dot indicator ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? const Color(0xFF0ABFDB)
                              : const Color(0xFF0ABFDB).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final Map<String, String> page;
  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    final isTracking = page['type'] == 'tracking';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: isTracking ? _TrackingCard() : _RewardsCard(),
          ),
          const SizedBox(height: 32),
          Text(
            page['tag']!,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              color: Color(0xFF0ABFDB),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            page['title']!,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A1628),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page['desc']!,
            style: const TextStyle(
                fontSize: 15, color: Color(0xFF6B7280), height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Card halaman 1: Tracking ─────────────────────────────────────────────────
class _TrackingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                  radius: 20, backgroundColor: Color(0xFF0ABFDB)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('LIVE NOW',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF0ABFDB),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  Text('5AM Run Club Recap',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A1628))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [60, 90, 70, 110, 85, 95, 65, 80, 55, 75]
                .map((h) => Container(
                      width: 18,
                      height: h.toDouble(),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0ABFDB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ...List.generate(
                  3,
                  (i) => Container(
                        margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0ABFDB)
                              .withOpacity(0.4 + i * 0.2),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      )),
              const SizedBox(width: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0ABFDB).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('+42',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0ABFDB),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Card halaman 2: Rewards + mascot ────────────────────────────────────────
class _RewardsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0ABFDB), Color.fromARGB(255, 255, 255, 255)],
        ),
      ),
      child: Stack(
        children: [
          // Lingkaran dekorasi belakang
          Positioned(
            top: -30, right: -30,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20, left: -20,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // Label badge
          Positioned(
            top: 16, left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text('UNLOCK OUTFITS',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
            ),
          ),

          // Mascot image
          Center(
            child: Image.asset(
              'assets/mascot/mascot_skin1_outfit_moverse_tee.png',
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/mascot/mascot_skin1.png',
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.directions_run,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}