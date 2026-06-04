import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'news_detail_screen.dart';
import '../widgets/notification_icon.dart';
import 'goal_setting_screen.dart';

const List<Map<String, String>> _newsList = [
  {
    'title': 'Sejumlah Warga Antusias Ikuti Car Free Day Depok dengan Aktivitas Lari Pagi',
    'author': 'Nayla Ramadhani',
    'date': 'Apr 30, 2025',
    'image': 'assets/images/news1.webp',
    'content': '''Sejak pagi hari, kawasan Car Free Day Depok dipadati oleh warga yang antusias memanfaatkan ruang publik untuk berolahraga. Aktivitas lari pagi menjadi salah satu pilihan utama, dengan peserta dari berbagai kalangan, mulai dari pelajar, mahasiswa, hingga keluarga.

Suasana semakin semarak dengan hadirnya komunitas lari lokal yang turut meramaikan jalur utama. Selain berlari, banyak peserta juga memanfaatkan momen ini untuk berjalan santai, bersepeda, dan menikmati udara pagi yang segar di tengah kota.

Car Free Day tidak hanya menjadi ajang olahraga, tetapi juga wadah untuk mempererat interaksi sosial antarwarga. Kegiatan ini dinilai mampu mendorong gaya hidup sehat sekaligus meningkatkan kesadaran masyarakat akan pentingnya menjaga kebugaran.

Pemerintah Kota Depok terus mendukung pelaksanaan Car Free Day sebagai ruang publik yang inklusif dan bermanfaat. Dengan tingginya partisipasi masyarakat, kegiatan ini diharapkan dapat terus menjadi agenda rutin yang mendorong budaya hidup aktif di lingkungan perkotaan.''',
  },
  {
    'title': 'Tips Lari Pagi untuk Pemula: Mulai dari 15 Menit Setiap Hari',
    'author': 'Marsadila Dwi',
    'date': 'May 1, 2025',
    'image': 'assets/images/news3.jpeg',
    'content': '''Bagi pemula yang ingin memulai kebiasaan lari pagi, para ahli merekomendasikan untuk memulai dengan durasi pendek sekitar 15 menit terlebih dahulu. Hal ini bertujuan agar tubuh dapat beradaptasi secara bertahap.

Pilih sepatu lari yang nyaman dan sesuai dengan bentuk kaki. Pemanasan selama 5 menit sebelum berlari juga sangat penting untuk mencegah cedera otot.

Konsistensi adalah kunci utama. Lebih baik lari 15 menit setiap hari daripada lari 1 jam sekali seminggu. Secara bertahap tambah durasi setiap minggu hingga mencapai target yang diinginkan.

Jangan lupa hidrasi yang cukup sebelum dan sesudah berlari. Minum air putih minimal 30 menit sebelum mulai berlari untuk menjaga stamina tubuh tetap optimal.''',
  },
  {
    'title': 'Komunitas Lari Depok Catat Rekor Peserta Terbanyak di 2025',
    'author': 'Dzazkiyah Aulia',
    'date': 'May 3, 2025',
    'image': 'assets/images/news2.webp',
    'content': '''Komunitas lari Depok berhasil mencatat rekor peserta terbanyak sepanjang sejarah berdirinya dengan total 2.500 pelari hadir dalam event weekend run bulan ini.

Event yang berlangsung di sepanjang jalur Margonda ini mendapat antusias luar biasa dari masyarakat. Para peserta terdiri dari berbagai usia, mulai dari anak-anak hingga lansia.

Panitia menyediakan berbagai kategori perlombaan mulai dari 5K, 10K, hingga half marathon. Tersedia juga kategori fun run untuk peserta yang ingin menikmati suasana tanpa tekanan waktu.

Komunitas lari Depok berencana mengadakan event serupa setiap bulan sebagai bentuk komitmen mendorong gaya hidup sehat di kalangan masyarakat kota Depok dan sekitarnya.''',
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          _userName = doc.data()?['name'] ?? user.displayName ?? 'User';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('MOVERSE',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                          letterSpacing: 2.5, color: Color(0xFF0A4F66))),
                  const NotificationIcon(),
                ],
              ),
              const SizedBox(height: 28),
              const Text('WELCOME BACK,',
                  style: TextStyle(fontSize: 11, letterSpacing: 1.5,
                      color: Color(0xFF0ABFDB), fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                _userName.isEmpty ? '...' : _userName,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1628)),
              ),
              const SizedBox(height: 24),

              // Daily reminder card
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
                child: Stack(
                  children: [
                    Positioned(
                      right: -8, bottom: -8,
                      child: Icon(Icons.directions_run,
                          size: 90,
                          color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text('DAILY REMINDER',
                              style: TextStyle(fontSize: 10, color: Colors.white,
                                  fontWeight: FontWeight.w700, letterSpacing: 1)),
                        ),
                        const SizedBox(height: 12),
                        const Text('Morning Run Session',
                            style: TextStyle(fontSize: 20,
                                fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text(
                            "You're only 2.4km away from\nhitting your weekly goal.",
                            style: TextStyle(fontSize: 13,
                                color: Colors.white70, height: 1.5)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) =>
                                  const GoalSettingScreen(activityType: 'Running'))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0ABFDB),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            elevation: 0,
                          ),
                          child: const Text('Start Now',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Text('Workout Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1628))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _CategoryCard(
                      icon: Icons.directions_run,
                      label: 'Running',
                      plans: '12 Active Plans',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                              const GoalSettingScreen(activityType: 'Running'))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CategoryCard(
                      icon: Icons.directions_walk,
                      label: 'Walking',
                      plans: '8 Active Plans',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                              const GoalSettingScreen(activityType: 'Walking'))),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Text('Sport News',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1628))),
              const SizedBox(height: 16),

              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newsList.length,
                  itemBuilder: (context, index) {
                    final news = _newsList[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => NewsDetailScreen(news: news))),
                      child: Container(
                        width: 260,
                        margin: EdgeInsets.only(
                            right: index < _newsList.length - 1 ? 16 : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFF0A1628),
                        ),
                        child: Stack(
                          children: [
                            // Gambar berita
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  news['image'] ?? 'assets/images/news1.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: const Color(0xFF1A6B8A),
                                    child: Center(
                                      child: Icon(Icons.directions_run,
                                          size: 60,
                                          color: Colors.white
                                              .withValues(alpha: 0.15)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Gradient overlay
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Color(0xDD0A1628),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Teks berita
                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(news['title'] ?? '',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.4)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(news['author'] ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF0ABFDB))),
                                        ),
                                        Text(news['date'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.white54)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label, plans;
  final VoidCallback onTap;
  const _CategoryCard({required this.icon, required this.label,
      required this.plans, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD6EEF7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF0ABFDB), size: 24),
            ),
            const SizedBox(height: 14),
            Text(label, style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
            const SizedBox(height: 4),
            Text(plans,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}