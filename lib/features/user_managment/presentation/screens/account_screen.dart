import 'package:blood_donation/common_widgets/async_value_ui.dart';
import 'package:blood_donation/common_widgets/async_value_widget.dart';
import 'package:blood_donation/common_widgets/common_button.dart';
import 'package:blood_donation/features/user_managment/Domain/app_user.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
import 'package:blood_donation/core/router/router.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('User not found')));
        }
        final userId = user.uid;
        final userDataAsync = ref.watch(loadUserInformationProvider(userId));

        // Listen for errors
        ref.listen<AsyncValue>(loadUserInformationProvider(userId), (_, state) {
          state.showAlertDialogOnError(context);
        });

        void logOut() {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Are you sure?'),
                    icon: const Icon(
                      Icons.logout,
                      size: 50,
                      color: AppStyle.mainColor,
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyle.mainColor),
                          child: Text(
                            'Cancel',
                            style: AppStyle.normalTextStyle,
                          )),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ref.read(authRepositoryProvider).signOut();
                            ref.read(goRouterProvider).refresh();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyle.mainColor),
                          child: Text(
                            'Log Out',
                            style: AppStyle.normalTextStyle,
                          ))
                    ],
                  ));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'My profile information',
              style: AppStyle.headingTextStyle,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.pushNamed('settings'),
              ),
            ],
          ),
          body: AsyncValueWidget<AppUser>(
              value: userDataAsync,
              data: (userData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Type : ${userData.type}',
                        style: AppStyle.titleTextStyle.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.getProportionateHeight(20),
                      ),
                      Image.asset(
                        userData.type == 'donor'
                            ? 'assets/Donorr.png' //donor image
                            : 'assets/recepint.png', //recipient image
                        height: SizeConfig.getProportionateHeight(150),
                        width: SizeConfig.getProportionateWidth(150),
                      ),
                      SizedBox(
                        height: SizeConfig.getProportionateHeight(20),
                      ),
                      Text(
                        'Name : ${userData.firstName ?? ''} ${userData.lastName ?? ''}',
                        style: AppStyle.normalTextStyle
                            .copyWith(color: Colors.black),
                      ),
                      Text(
                        'BloodGroup : ${userData.bloodGroup}',
                        style: AppStyle.normalTextStyle
                            .copyWith(color: Colors.black),
                      ),
                      Text(
                        'Email : ${userData.email}',
                        style: AppStyle.normalTextStyle
                            .copyWith(color: Colors.black),
                      ),
                      Text(
                        'Phone : ${userData.phoneNumber}',
                        style: AppStyle.normalTextStyle
                            .copyWith(color: Colors.black),
                      ),
                      SizedBox(
                        height: SizeConfig.getProportionateHeight(20),
                      ),
                      CommonButton(
                          onTap: () {
                            logOut();
                          },
                          title: 'SignOut',
                          isLoading: false)
                    ],
                  ),
                );
              }),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
