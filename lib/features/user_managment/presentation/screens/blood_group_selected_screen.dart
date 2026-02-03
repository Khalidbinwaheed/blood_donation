import 'package:blood_donation/common_widgets/async_value_ui.dart';
import 'package:blood_donation/common_widgets/async_value_widget.dart';
import 'package:blood_donation/features/user_managment/Domain/app_user.dart';
import 'package:blood_donation/features/user_managment/data/firestore_repository.dart';
import 'package:blood_donation/features/user_managment/presentation/widgets/user_item.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: AsyncValueWidget<List<AppUser>>(
              value: donarsAsyncValue,
              data: (donors) {
                return donors.isEmpty
                    ? const Center(
                        child: Text('no Donors yet'),
                      )
                    : ListView.builder(
                        itemCount: donors.length,
                        itemBuilder: (ctx, index) {
                          return UserItem(donors[index]);
                        });
              },
            ))
          ],
        ),
      ),
    );
  }
}
