import 'dart:convert';

class RunRecord {
  final String id;
  final DateTime date;
  final String activityType;
  final double distanceKm;
  final int durationSeconds;
  final int calories;
  final double pace; // min/km

  RunRecord({
    required this.id,
    required this.date,
    required this.activityType,
    required this.distanceKm,
    required this.durationSeconds,
    required this.calories,
    required this.pace,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'activityType': activityType,
        'distanceKm': distanceKm,
        'durationSeconds': durationSeconds,
        'calories': calories,
        'pace': pace,
      };

  factory RunRecord.fromJson(Map<String, dynamic> json) => RunRecord(
        id: json['id'],
        date: DateTime.parse(json['date']),
        activityType: json['activityType'],
        distanceKm: (json['distanceKm'] as num).toDouble(),
        durationSeconds: json['durationSeconds'],
        calories: json['calories'],
        pace: (json['pace'] as num).toDouble(),
      );

  String toJsonString() => jsonEncode(toJson());
  factory RunRecord.fromJsonString(String s) =>
      RunRecord.fromJson(jsonDecode(s));
}