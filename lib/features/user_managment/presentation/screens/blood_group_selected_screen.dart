import 'package:blood_donation/util/appstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BloodGroupSelectedScreen extends ConsumerWidget {
  const BloodGroupSelectedScreen( this.bloodGroup, {super.key});

  final String bloodGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Group : $bloodGroup',
        style: AppStyle.titleTextStyle, ),
      ),
    );
  }
}
