import 'package:blood_donation/features/user_managment/Domain/app_user.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserItem extends ConsumerWidget {
  const UserItem(this.appUser, {super.key});
  final AppUser appUser;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    return Card(
        child: ListTile(
            leading: Image.asset(
              appUser.type == 'donor'
                  ? 'assets/Donorr.png'
                  : 'assets/recepint.png',
              height: SizeConfig.getProportionateHeight(100),
              width: SizeConfig.getProportionateWidth(100),
            ),
            title: Column(
              children: [
                Text(
                  appUser.type.toUpperCase(),
                  style: AppStyle.normalTextStyle.copyWith(color: Colors.black),
                ),
                Text(
                  'Name: ${appUser.name}',
                  overflow: TextOverflow.ellipsis,
                  style: AppStyle.normalTextStyle.copyWith(color: Colors.black),
                ),
                Text(
                  'Email: ${appUser.email}',
                  overflow: TextOverflow.ellipsis,
                  style: AppStyle.normalTextStyle.copyWith(color: Colors.black),
                ),
                Text(
                  'Phone: ${appUser.phoneNumber}',
                  overflow: TextOverflow.ellipsis,
                  style: AppStyle.normalTextStyle.copyWith(color: Colors.black),
                ),
                Text(
                  'Blood Group: ${appUser.bloodGroup}',
                  overflow: TextOverflow.ellipsis,
                  style: AppStyle.normalTextStyle.copyWith(color: Colors.black),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyle.mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'EMAIL',
                style: AppStyle.normalTextStyle,
              ),
            )));
  }
}
