import 'package:flutter/material.dart';
import '../models/avatar_repository.dart';
import '../models/run_repository.dart';

class CustomizeMascotScreen extends StatefulWidget {
  const CustomizeMascotScreen({super.key});

  @override
  State<CustomizeMascotScreen> createState() => _CustomizeMascotScreenState();
}

class _CustomizeMascotScreenState extends State<CustomizeMascotScreen> {
  bool _loading = true;
  bool _saving = false;

  // Pilihan yang sedang aktif (belum disimpan)
  int _selectedSkin = 0;
  String? _selectedOutfitKey;

  // Data dari repository
  Map<String, bool> _badges = {};
  List<OutfitItem> _allOutfits = [];

  // Tab kategori yang aktif
  _AvatarTab _activeTab = _AvatarTab.skin;

  // Warna kulit yang tersedia
  static const List<Color> _skinColors = [
    Color(0xFFE8B88A), // light
    Color(0xFFBF8654), // medium
    Color(0xFF7D4A2A), // dark
  ];

  // Asset mascot per warna kulit (ganti path sesuai assetmu)
  static const List<String> _mascotAssets = [
    'assets/mascot/mascot_skin0.png',
    'assets/mascot/mascot_skin1.png',
    'assets/mascot/mascot_skin2.png',
  ];

  // Asset mascot + outfit (format: mascot_skin{n}_outfit_{key}.png)
  String get _currentMascotAsset {
    if (_selectedOutfitKey == null || _selectedOutfitKey == 'none') {
      return _mascotAssets[_selectedSkin];
    }
    return 'assets/mascot/mascot_skin${_selectedSkin}_outfit_$_selectedOutfitKey.png';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final avatarData = await AvatarRepository.getAvatarData();
    final badges = await RunRepository.getBadges();
    setState(() {
      _selectedSkin = avatarData.skinIndex;
      _selectedOutfitKey = avatarData.outfitKey;
      _badges = badges;
      _allOutfits = AvatarRepository.allOutfits;
      _loading = false;
    });
  }

  Future<void> _saveAppearance() async {
    setState(() => _saving = true);
    await AvatarRepository.saveAvatarData(AvatarData(
      skinIndex: _selectedSkin,
      outfitKey: _selectedOutfitKey,
    ));
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Appearance saved!'),
          backgroundColor: const Color(0xFF0ABFDB),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FB),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0ABFDB)))
            : Column(
                children: [
                  // ── App bar ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Color(0xFF0A4F66), size: 20),
                        ),
                        const Expanded(
                          child: Text('Customize Mascot',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A1628))),
                        ),
                        const SizedBox(width: 44), // balance
                      ],
                    ),
                  ),

                  // ── Mascot preview card ──────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Color(0xFFE0F9F5)],
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Mascot image
                            Image.asset(
                              _currentMascotAsset,
                              height: 280,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => SizedBox(
                                height: 280,
                                child: Icon(Icons.person,
                                    size: 180, color: _skinColors[_selectedSkin]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Bottom panel ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tab selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _TabButton(
                              icon: Icons.face,
                              active: _activeTab == _AvatarTab.skin,
                              onTap: () => setState(() => _activeTab = _AvatarTab.skin),
                            ),
                            _TabButton(
                              icon: Icons.checkroom,
                              active: _activeTab == _AvatarTab.outfit,
                              onTap: () => setState(() => _activeTab = _AvatarTab.outfit),
                            ),
                            // Placeholder tabs (belum aktif)
                            _TabButton(
                              icon: Icons.content_cut,
                              active: false,
                              onTap: () => _showComingSoon('Hairstyle'),
                            ),
                            _TabButton(
                              icon: Icons.headphones,
                              active: false,
                              onTap: () => _showComingSoon('Accessories'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Konten per tab
                        if (_activeTab == _AvatarTab.skin) _buildSkinSelector(),
                        if (_activeTab == _AvatarTab.outfit) _buildOutfitSelector(),

                        const SizedBox(height: 20),

                        // Save Appearance button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _saveAppearance,
                            icon: _saving
                                ? const SizedBox(width: 16, height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.save_alt, size: 18),
                            label: Text(_saving ? 'Saving...' : 'Save Appearance'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0ABFDB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              textStyle: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
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

  // ── Skin selector ──────────────────────────────────────────────────────────
  Widget _buildSkinSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_skinColors.length, (i) {
        final selected = _selectedSkin == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedSkin = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: _skinColors[i],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? const Color(0xFF0ABFDB) : Colors.transparent,
                width: 3,
              ),
              boxShadow: selected
                  ? [BoxShadow(color: const Color(0xFF0ABFDB).withValues(alpha: 0.4),
                        blurRadius: 8, spreadRadius: 1)]
                  : [],
            ),
            child: selected
                ? const Center(child: Icon(Icons.check, color: Colors.white, size: 22))
                : null,
          ),
        );
      }),
    );
  }

  // ── Outfit selector ────────────────────────────────────────────────────────
  Widget _buildOutfitSelector() {
    // Unlocked di kiri, locked di kanan
    final sorted = [..._allOutfits]..sort((a, b) {
        final aUnlocked = AvatarRepository.isOutfitUnlocked(a, _badges);
        final bUnlocked = AvatarRepository.isOutfitUnlocked(b, _badges);
        if (aUnlocked && !bUnlocked) return -1;
        if (!aUnlocked && bUnlocked) return 1;
        return 0;
      });

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: sorted.map((outfit) {
        final unlocked = AvatarRepository.isOutfitUnlocked(outfit, _badges);
        final selected = (_selectedOutfitKey ?? 'none') == outfit.key;

        return GestureDetector(
          onTap: () {
            if (!unlocked) {
              // Tampilkan info badge yang dibutuhkan
              final badgeName = AvatarRepository.getBadgeNameForOutfit(outfit.key);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Unlock "$badgeName" badge to wear this outfit!'),
                  backgroundColor: const Color(0xFF0A4F66),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }
            setState(() => _selectedOutfitKey = outfit.key == 'none' ? null : outfit.key);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: selected ? Colors.white : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? const Color(0xFF0ABFDB) : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: unlocked
                      ? Image.asset(outfit.imagePath, width: 52, height: 52,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => outfit.key == 'none'
                              ? const Icon(Icons.do_not_disturb_alt,
                                  color: Color(0xFFD1D5DB), size: 36)
                              : Icon(Icons.checkroom,
                                  color: const Color(0xFF0A1628).withValues(alpha: 0.6),
                                  size: 36))
                      // Locked: tampil ikon kunci
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0,      0,      0,      1, 0,
                              ]),
                              child: Opacity(
                                opacity: 0.3,
                                child: Image.asset(outfit.imagePath,
                                    width: 52, height: 52, fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.checkroom, size: 36)),
                              ),
                            ),
                            const Icon(Icons.lock, color: Color(0xFF9CA3AF), size: 20),
                          ],
                        ),
                ),
                // Checkmark kalau selected
                if (selected)
                  Positioned(
                    top: 4, right: 4,
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0ABFDB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 11),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon!'),
        backgroundColor: const Color(0xFF0A4F66),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Tab button ───────────────────────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0ABFDB) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: active ? Colors.white : const Color(0xFF9CA3AF),
            size: 22),
      ),
    );
  }
}

enum _AvatarTab { skin, outfit }