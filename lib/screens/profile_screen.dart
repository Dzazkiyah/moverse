import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customize_mascot_screen.dart';
import 'account_info_screen.dart';
import '../widgets/notification_icon.dart';
import '../models/avatar_repository.dart';
import '../models/run_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  double _totalDistance = 0;
  int _totalAwards = 0;
  AvatarData _avatarData = const AvatarData();

  static const List<String> _mascotAssets = [
    'assets/mascot/mascot_skin0.png',
    'assets/mascot/mascot_skin1.png',
    'assets/mascot/mascot_skin2.png',
  ];

  String get _avatarAsset {
    final skin = _avatarData.skinIndex;
    final outfit = _avatarData.outfitKey;
    if (outfit == null || outfit == 'none') return _mascotAssets[skin];
    return 'assets/mascot/mascot_skin${skin}_outfit_$outfit.png';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // FIX 3: Reload data setiap kali screen ini aktif
  // (misalnya setelah balik dari run screen atau screen lain)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final avatarData = await AvatarRepository.getAvatarData();
    final badges = await RunRepository.getBadges();

    // FIX 2: Konsisten pakai RunRepository.getAllTimeTotals()
    // sama persis dengan AnalysisScreen
    final totals = await RunRepository.getAllTimeTotals();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        final data = doc.data();
        setState(() {
          _userName = data?['name'] ?? user.displayName ?? 'User';

          // FIX 2: Cast yang benar, tanpa kurung ganda
          _totalDistance = totals['km'] as double;

          _totalAwards = badges.values.where((v) => v).length;
          _avatarData = avatarData;
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
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
              ),

              const SizedBox(height: 28),

              // Avatar + edit button
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE0F9F5),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        _avatarAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF0ABFDB)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CustomizeMascotScreen()))
                          .then((_) => _loadUserData()),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A4F66),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                _userName.isEmpty ? '...' : _userName,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1628)),
              ),

              const SizedBox(height: 24),

              // FIX 1: Kedua kotak pakai fontSize yang sama (26)
              // supaya tinggi konten setara dan kotak sejajar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Kotak Total Distance
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL DISTANCE',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF9CA3AF),
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _totalDistance.toStringAsFixed(0),
                                    style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A1628)),
                                  ),
                                  const SizedBox(width: 4),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 2),
                                    child: Text('KM',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF9CA3AF),
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Kotak Awards
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AWARDS',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white70,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              // FIX 1: fontSize 26 (sama dengan Total Distance)
                              Text(
                                '$_totalAwards',
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ACCOUNT SETTINGS',
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 14),
                    _SettingItem(
                      icon: Icons.person_outline,
                      label: 'Account Info',
                      desc: 'Email, Password, Personal Data',
                      iconBg: const Color(0xFFD6EEF7),
                      iconColor: const Color(0xFF0ABFDB),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AccountInfoScreen())),
                    ),
                    const SizedBox(height: 12),
                    _SettingItem(
                      icon: Icons.face,
                      label: 'Avatar Customization',
                      desc: 'Styles, Outfits, Equipment',
                      iconBg: const Color(0xFFD6EEF7),
                      iconColor: const Color(0xFF0ABFDB),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomizeMascotScreen())),
                    ),
                    const SizedBox(height: 12),
                    _SettingItem(
                      icon: Icons.delete_outline,
                      label: 'Clear Run Data',
                      desc: 'Reset semua data lari (untuk testing)',
                      iconBg: const Color(0xFFFFF3CD),
                      iconColor: const Color(0xFFF59E0B),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Hapus semua data lari?'),
                            content: const Text(
                                'Data lari akan direset. Aksi ini tidak bisa dibatalkan.'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal')),
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Hapus',
                                      style: TextStyle(
                                          color: Color(0xFFEF4444)))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await RunRepository.clearAll();
                          _loadUserData();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Data lari dihapus!'),
                                    backgroundColor: Color(0xFFF59E0B)));
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _SettingItem(
                      icon: Icons.logout,
                      label: 'Logout',
                      desc: 'Sign out of your account',
                      iconBg: const Color(0xFFFFEBEB),
                      iconColor: const Color(0xFFEF4444),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label, desc;
  final Color iconBg, iconColor;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.desc,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A1628))),
                  const SizedBox(height: 3),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}