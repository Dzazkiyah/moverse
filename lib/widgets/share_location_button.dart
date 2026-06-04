import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/live_location_service.dart';

/// Widget tombol share lokasi — tempel di halaman sesi lari
/// Contoh pemakaian:
///   ShareLocationButton(isRunning: _isRunning)
class ShareLocationButton extends StatefulWidget {
  final bool isRunning; // true kalau sesi lari sedang aktif

  const ShareLocationButton({super.key, required this.isRunning});

  @override
  State<ShareLocationButton> createState() => _ShareLocationButtonState();
}

class _ShareLocationButtonState extends State<ShareLocationButton> {
  bool _sharing = false;

  Future<void> _share() async {
    if (!widget.isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mulai lari dulu untuk share lokasi!'),
          backgroundColor: const Color(0xFF0A4F66),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _sharing = true);

    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Saya';

    await LiveLocationService.shareLocation(userName);

    if (mounted) setState(() => _sharing = false);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.isRunning;

    return GestureDetector(
      onTap: _share,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0ABFDB) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sharing
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Icon(
                    Icons.share_location,
                    size: 18,
                    color: active ? Colors.white : const Color(0xFF9CA3AF),
                  ),
            const SizedBox(width: 8),
            Text(
              'Share Lokasi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}