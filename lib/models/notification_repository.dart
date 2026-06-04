import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final String id;
  final String type; // 'badge' | 'streak' | 'run'
  final String title;
  final String body;
  final DateTime date;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'date': date.toIso8601String(),
        'isRead': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'],
        type: j['type'],
        title: j['title'],
        body: j['body'],
        date: DateTime.parse(j['date']),
        isRead: j['isRead'] ?? false,
      );

  String toJsonString() => jsonEncode(toJson());
  factory AppNotification.fromJsonString(String s) =>
      AppNotification.fromJson(jsonDecode(s));
}

class NotificationRepository {
  static const _key = 'app_notifications';

  static Future<void> add(AppNotification notif) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.insert(0, notif); // terbaru di atas
    // Maksimal simpan 50 notifikasi
    final trimmed = all.take(50).toList();
    await prefs.setStringList(
        _key, trimmed.map((n) => n.toJsonString()).toList());
  }

  static Future<List<AppNotification>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map(AppNotification.fromJsonString).toList();
  }

  static Future<int> getUnreadCount() async {
    final all = await getAll();
    return all.where((n) => !n.isRead).length;
  }

  static Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    for (final n in all) {
      n.isRead = true;
    }
    await prefs.setStringList(
        _key, all.map((n) => n.toJsonString()).toList());
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}