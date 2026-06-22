import 'dart:async';

import 'package:blood_donation/core/widgets/glass_card.dart';
import 'package:blood_donation/core/widgets/health_stat_card.dart';
import 'package:blood_donation/core/widgets/mini_line_chart.dart';
import 'package:blood_donation/features/iot_health/data/health_data_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeartMonitorScreen extends ConsumerStatefulWidget {
  const HeartMonitorScreen({super.key});

  @override
  ConsumerState<HeartMonitorScreen> createState() => _HeartMonitorScreenState();
}

class _HeartMonitorScreenState extends ConsumerState<HeartMonitorScreen> {
  final List<double> _samples = [72, 74, 73, 75, 77, 76, 74, 72];
  Timer? _timer;
  bool _connected = true;
  int _persistCounter = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_connected || !mounted) return;
      setState(() {
        final next = (_samples.last + (DateTime.now().millisecond % 7 - 3))
            .clamp(48, 132)
            .toDouble();
        _samples.add(next);
        if (_samples.length > 24) {
          _samples.removeAt(0);
        }
      });
      _persistCounter++;
      if (_persistCounter >= 5) {
        _persistCounter = 0;
        _persistReading(_samples.last.round());
      }
    });
  }

  Future<void> _persistReading(int bpm) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      return;
    }
    try {
      await ref.read(healthDataRepositoryProvider).recordHeartRate(
            userId: user.uid,
            bpm: bpm,
          );
    } catch (_) {
      // Sensor UI keeps working even if Firestore write fails offline.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _samples.last.round();
    final warning = current < 55 || current > 105;

    return Scaffold(
      appBar: AppBar(title: const Text('Heart Monitor')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          HealthStatCard(
            label: 'Current heart rate',
            value: '$current bpm',
            icon: Icons.favorite_rounded,
            emphasisColor: warning ? Colors.red : const Color(0xFFFF3B30),
            trailing: Switch.adaptive(
              value: _connected,
              onChanged: (value) => setState(() => _connected = value),
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Realtime waveform',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: CustomPaint(
                    painter: _BackgroundGridPainter(),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: MiniLineChart(
                          points: _samples,
                          lineColor:
                              warning ? Colors.red : const Color(0xFF0A84FF)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (warning)
            const GlassCard(
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          'Abnormal reading detected. Consider checking the patient immediately.')),
                ],
              ),
            )
          else
            const GlassCard(
              child: Text(
                  'Sensor is stable and streaming. Readings sync to your health record.'),
            ),
        ],
      ),
    );
  }
}

class _BackgroundGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var row = 1; row < 4; row++) {
      final y = row * (size.height / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
