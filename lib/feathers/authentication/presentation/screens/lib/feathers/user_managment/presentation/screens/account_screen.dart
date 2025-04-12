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
        ],
      ),
    );
  }
}
