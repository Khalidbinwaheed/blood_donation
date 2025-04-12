import 'package:blood_donation/common_widgets/common_button.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My profile information',
          style: AppStyle.headingTextStyle,
        ),
      ),
      body: Column(
        children: [
          Text(
            'Type : User Type',
            style: AppStyle.titleTextStyle,
          ),
          SizedBox(
            height: SizeConfig.getProportionateHeight(20),
          ),
          Image.asset(
            'assets/logo.png',
            height: SizeConfig.getProportionateHeight(100),
            width: SizeConfig.getProportionateWidth(100),
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: SizeConfig.getProportionateHeight(20),
          ),
          Text(
            'Name : User Name',
            style: AppStyle.normalTextStyle.copyWith(color: Colors.black),
          ),
          Text(
            'BloodGroup : Your Blood Group here ',
            style: AppStyle.normalTextStyle.copyWith(color: Colors.black),
          ),
          Text(
            'Email : Your Email here',
            style: AppStyle.normalTextStyle.copyWith(color: Colors.black),
          ),
          Text(
            'Phone : Your Phone here',
            style: AppStyle.normalTextStyle.copyWith(color: Colors.black),
          ),
          SizedBox(
            height: SizeConfig.getProportionateHeight(20),
          ),
          CommonButton(onTap: () {}, title: 'SignOut', isLoading: false)
        ],
      ),
    );
  }
}
