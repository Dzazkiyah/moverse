import 'package:flutter/material.dart';
import 'tracking_screen.dart';

class GoalSettingScreen extends StatefulWidget {
  final String activityType;
  const GoalSettingScreen({super.key, required this.activityType});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  double _distanceGoal = 8.5;
  int _timeGoal = 45;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FB),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Color(0xFF0A4F66), size: 16),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Set Your Goal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A4F66),
                      ),
                    ),
                  ),
                  const SizedBox(width: 38), // Balance the back button
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Activity Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              widget.activityType == 'Running'
                                  ? Icons.directions_run
                                  : Icons.directions_walk,
                              color: const Color(0xFF0ABFDB),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.activityType,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Set target untuk sesi ini',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Distance Goal Card
                    _GoalCard(
                      icon: Icons.straighten_rounded,
                      title: 'Distance Goal',
                      value: '${_distanceGoal.toStringAsFixed(1)} km',
                      minLabel: '1 KM',
                      midLabel: 'DAILY TARGET',
                      maxLabel: '42 KM',
                      sliderValue: _distanceGoal,
                      sliderMin: 1.0,
                      sliderMax: 42.0,
                      sliderDivisions: 410,
                      onChanged: (val) =>
                          setState(() => _distanceGoal = double.parse(val.toStringAsFixed(1))),
                    ),

                    const SizedBox(height: 16),

                    // Time Goal Card
                    _GoalCard(
                      icon: Icons.timer_outlined,
                      title: 'Time Goal',
                      value: '${_timeGoal} min',
                      minLabel: '5 MIN',
                      midLabel: 'DAILY TARGET',
                      maxLabel: '3 HRS',
                      sliderValue: _timeGoal.toDouble(),
                      sliderMin: 5.0,
                      sliderMax: 180.0,
                      sliderDivisions: 35,
                      onChanged: (val) =>
                          setState(() => _timeGoal = val.toInt()),
                    ),

                    const SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0ABFDB), Color(0xFF00E5A0)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TrackingScreen(
                                      activityType: widget.activityType,
                                      distanceGoal: _distanceGoal,
                                      timeGoal: _timeGoal,
                                      calorieGoal: null,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: const Text(
                                'Mulai',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TrackingScreen(
                                    activityType: widget.activityType,
                                    distanceGoal: null,
                                    timeGoal: null,
                                    calorieGoal: null,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0A4F66),
                              side: const BorderSide(
                                  color: Color(0xFF0ABFDB), width: 1.5),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFF0A4F66),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String minLabel;
  final String midLabel;
  final String maxLabel;
  final double sliderValue;
  final double sliderMin;
  final double sliderMax;
  final int sliderDivisions;
  final ValueChanged<double> onChanged;

  const _GoalCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.minLabel,
    required this.midLabel,
    required this.maxLabel,
    required this.sliderValue,
    required this.sliderMin,
    required this.sliderMax,
    required this.sliderDivisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header row: icon + title on left, value on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: const Color(0xFF0ABFDB), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1628),
                    ),
                  ),
                ],
              ),
              // Live value display
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value.split(' ')[0],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A1628),
                      ),
                    ),
                    TextSpan(
                      text: ' ${value.split(' ')[1]}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: const Color(0xFF0ABFDB),
              inactiveTrackColor: const Color(0xFFE5F7FA),
              thumbColor: const Color(0xFF0A4F66),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              overlayColor: const Color(0x220ABFDB),
            ),
            child: Slider(
              value: sliderValue,
              min: sliderMin,
              max: sliderMax,
              divisions: sliderDivisions,
              onChanged: onChanged,
            ),
          ),

          // Labels below slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  midLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  maxLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}