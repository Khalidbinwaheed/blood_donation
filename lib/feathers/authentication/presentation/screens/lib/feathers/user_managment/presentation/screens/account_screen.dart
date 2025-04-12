import 'package:blood_donation/util/appstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountScreen extends ConsumerWidget { 
  const AccountScreen({super.key});

  @override
  Widget build (BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My profile information' , style: AppStyle.headingTextStyle,),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Account Screen'),
            ElevatedButton(
              onPressed: () {
                // Add your logout logic here
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}