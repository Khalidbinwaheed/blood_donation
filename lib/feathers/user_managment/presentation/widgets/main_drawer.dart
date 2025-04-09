import 'package:blood_donation/routes/routes.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            DrawerHeader(
                child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppStyle.mainColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white,
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: SizeConfig.getProportionateHeight(40),
                    width: SizeConfig.getProportionateWidth(40),
                    fit: BoxFit.cover,
                  ),
                  Text('Blood Donation App', style: AppStyle.titleTextStyle),
                  Text('Your name', style: AppStyle.normalTextStyle),
                  Text('Your email', style: AppStyle.normalTextStyle),
                ],
              ),
            )),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: AppStyle.mainColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                      style: BorderStyle.solid,
                      width: 2,
                    )),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.home,
                            color: Colors.black,
                            size: 30,
                          ),
                          title: Text(
                            'Home',
                            style: AppStyle.headingTextStyle
                                .copyWith(fontSize: 17.0),
                          ),
                          onTap: () {
                            context.goNamed(AppRoutes.main.name);
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.black,
                            size: 30,
                          ),
                          title: Text(
                            'Donors Emailed',
                            style: AppStyle.headingTextStyle
                                .copyWith(fontSize: 17.0),
                          ),
                          onTap: () {
                            // context.goNamed(AppRoutes.main.name);
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.handshake,
                            color: Colors.black,
                            size: 30,
                          ),
                          title: Text(
                            'Same Blood Group As me',
                            style: AppStyle.headingTextStyle
                                .copyWith(fontSize: 17.0),
                          ),
                          onTap: () {
                            context.goNamed(AppRoutes.main.name);
                          },
                        ),
                        const Divider(
                          color: Colors.white,
                          height: 2,
                        ),
                        Text(
                          'Blood Groups',
                          style: AppStyle.normalTextStyle,
                        ),
                        ListTile(
                          leading: Image.asset('assets/logo.png',
                              height: 30, width: 30),
                          title: Text(
                            'A positive',
                            style: AppStyle.normalTextStyle,
                          ),
                          onTap: (){
                            //context.goNamed(AppRoutes.main.name);
                            
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
