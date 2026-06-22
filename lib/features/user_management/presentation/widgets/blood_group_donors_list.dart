import 'package:blood_donation/common_widgets/async_value_ui.dart';
import 'package:blood_donation/common_widgets/async_value_widget.dart';
import 'package:blood_donation/features/user_management/Domain/app_user.dart';
import 'package:blood_donation/features/user_management/data/firestore_repository.dart';
import 'package:blood_donation/features/user_management/presentation/widgets/user_item.dart';
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
                  ? Center(
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off, size: 34),
                              const SizedBox(height: 8),
                              Text(
                                'No donors found for this blood group.',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'We are listening for new profiles in real time.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      key: const PageStorageKey('blood-group-donor-list'),
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
