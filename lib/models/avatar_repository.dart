import 'package:shared_preferences/shared_preferences.dart';

/// Model untuk data avatar
class AvatarData {
  final int skinIndex;      // 0 = light, 1 = medium, 2 = dark
  final String? outfitKey;  // null = no outfit, 'black_tee', 'moverse_tee'

  const AvatarData({
    this.skinIndex = 0,
    this.outfitKey,
  });

  AvatarData copyWith({int? skinIndex, String? outfitKey, bool clearOutfit = false}) {
    return AvatarData(
      skinIndex: skinIndex ?? this.skinIndex,
      outfitKey: clearOutfit ? null : (outfitKey ?? this.outfitKey),
    );
  }
}

/// Model untuk satu outfit
class OutfitItem {
  final String key;
  final String name;
  final String imagePath;       // icon di selector
  final String? badgeRequired;  // null = selalu tersedia

  const OutfitItem({
    required this.key,
    required this.name,
    required this.imagePath,
    this.badgeRequired,
  });
}

class AvatarRepository {
  static const _skinKey = 'avatar_skin_index';
  static const _outfitKey = 'avatar_outfit_key';

  // ── Daftar semua outfit yang ada di app ─────────────────────────────────
  static const List<OutfitItem> allOutfits = [
    OutfitItem(
      key: 'none',
      name: 'No Outfit',
      imagePath: 'assets/outfits/outfit_none.png',
      badgeRequired: null, // selalu tersedia
    ),
    OutfitItem(
      key: 'black_tee',
      name: 'Black Tee',
      imagePath: 'assets/outfits/outfit_black_tee.png',
      badgeRequired: 'first_run', // unlock setelah lari pertama
    ),
    OutfitItem(
      key: 'moverse_tee',
      name: 'Moverse Tee',
      imagePath: 'assets/outfits/outfit_moverse_tee.png',
      badgeRequired: 'first_run', // unlock setelah lari pertama
    ),
  ];

  // ── Baca data avatar tersimpan ───────────────────────────────────────────
  static Future<AvatarData> getAvatarData() async {
    final prefs = await SharedPreferences.getInstance();
    return AvatarData(
      skinIndex: prefs.getInt(_skinKey) ?? 0,
      outfitKey: prefs.getString(_outfitKey), // null kalau belum pernah simpan
    );
  }

  // ── Simpan data avatar ───────────────────────────────────────────────────
  static Future<void> saveAvatarData(AvatarData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_skinKey, data.skinIndex);
    if (data.outfitKey == null) {
      await prefs.remove(_outfitKey);
    } else {
      await prefs.setString(_outfitKey, data.outfitKey!);
    }
  }

  // ── Cek outfit mana saja yang terbuka berdasarkan badge ─────────────────
  /// [unlockedBadges] = Map<String, bool> dari RunRepository.getBadges()
  static List<OutfitItem> getUnlockedOutfits(Map<String, bool> unlockedBadges) {
    return allOutfits.where((outfit) {
      if (outfit.badgeRequired == null) return true; // selalu tersedia
      return unlockedBadges[outfit.badgeRequired] == true;
    }).toList();
  }

  // ── Cek satu outfit apakah terbuka ──────────────────────────────────────
  static bool isOutfitUnlocked(OutfitItem outfit, Map<String, bool> unlockedBadges) {
    if (outfit.badgeRequired == null) return true;
    return unlockedBadges[outfit.badgeRequired] == true;
  }

  // ── Helper: ambil nama badge yang dibutuhkan (untuk tooltip UI) ──────────
  static String getBadgeNameForOutfit(String outfitKey) {
    final outfit = allOutfits.firstWhere(
      (o) => o.key == outfitKey,
      orElse: () => const OutfitItem(key: '', name: '', imagePath: ''),
    );
    switch (outfit.badgeRequired) {
      case 'early_bird': return 'Early Bird';
      case 'speed_demon': return 'Speed Demon';
      default: return '';
    }
  }
}