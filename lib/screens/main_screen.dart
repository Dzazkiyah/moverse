import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'analysis_screen.dart';
import 'awards_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AnalysisScreen(),
    AwardsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06),
                blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'HOME', index: 0,
                    current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.bar_chart_rounded, label: 'ANALYSIS', index: 1,
                    current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.emoji_events_rounded, label: 'AWARDS', index: 2,
                    current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.person_rounded, label: 'PROFILE', index: 3,
                    current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final Function(int) onTap;

  const _NavItem({required this.icon, required this.label,
      required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = current == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)])
                  : null,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(icon, size: 22,
                color: isActive ? Colors.white : const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isActive ? const Color(0xFF0ABFDB) : const Color(0xFF9CA3AF),
              )),
        ],
      ),
    );
  }
}