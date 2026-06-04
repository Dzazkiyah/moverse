import 'package:flutter/material.dart';
import '../screens/notification_screen.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationScreen()),
      ),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.notifications_outlined,
            color: Color(0xFF0A4F66), size: 20),
      ),
    );
  }
}