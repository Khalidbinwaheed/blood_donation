import 'dart:async';

import 'package:blood_donation/core/widgets/glass_card.dart';
import 'package:blood_donation/core/widgets/health_stat_card.dart';
import 'package:blood_donation/core/widgets/mini_line_chart.dart';
import 'package:blood_donation/features/iot_health/data/health_data_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BpMonitorScreen extends ConsumerStatefulWidget {
  const BpMonitorScreen({super.key});

  @override
  ConsumerState<BpMonitorScreen> createState() => _BpMonitorScreenState();
}

class _BpMonitorScreenState extends ConsumerState<BpMonitorScreen> {
  final List<double> _sysSamples = [118, 120, 122, 119, 121, 124, 123, 120];
  final List<double> _diaSamples = [76, 78, 77, 76, 79, 78, 76, 75];
  Timer? _timer;
  int _persistCounter = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        final nextSys =
            (_sysSamples.last + (DateTime.now().millisecond % 5 - 2))
                .clamp(95, 160)
                .toDouble();
        final nextDia =
            (_diaSamples.last + (DateTime.now().millisecond % 3 - 1))
                .clamp(60, 100)
                .toDouble();
        _sysSamples.add(nextSys);
        _diaSamples.add(nextDia);
        if (_sysSamples.length > 24) _sysSamples.removeAt(0);
        if (_diaSamples.length > 24) _diaSamples.removeAt(0);
      });
      _persistCounter++;
      if (_persistCounter >= 4) {
        _persistCounter = 0;
        _persistReading(
          _sysSamples.last.round(),
          _diaSamples.last.round(),
        );
      }
    });
  }

  Future<void> _persistReading(int systolic, int diastolic) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      return;
    }
    try {
      await ref.read(healthDataRepositoryProvider).recordBloodPressure(
            userId: user.uid,
            systolic: systolic,
            diastolic: diastolic,
          );
    } catch (_) {
      // Keep UI responsive when offline.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final systolic = _sysSamples.last.round();
    final diastolic = _diaSamples.last.round();
    final warning = systolic >= 140 || diastolic >= 90;

    return Scaffold(
      appBar: AppBar(title: const Text('BP Monitor')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          HealthStatCard(
            label: 'Blood pressure',
            value: '$systolic/$diastolic mmHg',
            icon: Icons.monitor_heart_rounded,
            emphasisColor: warning ? Colors.red : const Color(0xFF0A84FF),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Systolic history',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                SizedBox(
                    height: 160, child: MiniLineChart(points: _sysSamples)),
                const SizedBox(height: 14),
                Text('Diastolic history',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                SizedBox(
                    height: 160,
                    child: MiniLineChart(
                        points: _diaSamples,
                        lineColor: const Color(0xFFFF9F0A))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Row(
              children: [
                Icon(
                    warning
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_rounded,
                    color: warning ? Colors.red : Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    warning
                        ? 'Elevated BP trend detected. Review the patient or recheck in a few minutes.'
                        : 'BP is within the normal monitoring range. Readings sync to your health record.',
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
