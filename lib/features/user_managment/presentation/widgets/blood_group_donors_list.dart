import 'package:blood_donation/common_widgets/async_value_ui.dart';
import 'package:blood_donation/common_widgets/async_value_widget.dart';
import 'package:blood_donation/features/user_managment/Domain/app_user.dart';
import 'package:blood_donation/features/user_managment/data/firestore_repository.dart';
import 'package:blood_donation/features/user_managment/presentation/widgets/user_item.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BloodGroupDonorsList extends ConsumerWidget {
  const BloodGroupDonorsList({required this.bloodGroup, super.key});

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

    return Column(
      children: [
        Expanded(
          child: AsyncValueWidget<List<AppUser>>(
            value: donarsAsyncValue,
            data: (donors) {
              return donors.isEmpty
                  ? const Center(
                      child: Text('No donors found for this blood group.'),
                    )
                  : ListView.builder(
                      itemCount: donors.length,
                      itemBuilder: (ctx, index) {
                        return UserItem(donors[index]);
                      },
                    );
            },
          ),
        ),
      ],
    );
  }
}
