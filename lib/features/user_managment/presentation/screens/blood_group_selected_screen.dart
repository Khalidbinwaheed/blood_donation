import 'package:blood_donation/common_widgets/async_value_ui.dart';
import 'package:blood_donation/features/user_managment/data/firestore_repository.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BloodGroupSelectedScreen extends ConsumerWidget {
  const BloodGroupSelectedScreen(this.bloodGroup, {super.key});

  final String bloodGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final donarsAsyncValue =
        ref.watch(loadSpecificBloodGroupDonorsProvider(bloodGroup));
    final userDataAsync =
        ref.watch(loadSpecificBloodGroupDonorsProvider(bloodGroup));
    ref.listen<AsyncValue>(loadSpecificBloodGroupDonorsProvider(bloodGroup),
        (_, state) {
      state.showAlertDialogOnError(context);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blood Group : $bloodGroup',
          style: AppStyle.titleTextStyle,
        ),
      ),
    );
  }
}
