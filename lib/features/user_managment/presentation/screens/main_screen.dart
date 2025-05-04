import 'package:blood_donation/common_widgets/async_value_ui.dart';
import 'package:blood_donation/common_widgets/async_value_widget.dart';
import 'package:blood_donation/features/user_managment/Domain/app_user.dart';
import 'package:blood_donation/features/user_managment/data/firestore_repository.dart';
import 'package:blood_donation/features/user_managment/presentation/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donorsAsyncValue = ref.watch(loadDonorsProvider);

    ref.listen<AsyncValue>(loadDonorsProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation'),
      ),
      drawer: const MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(child: AsyncValueWidget<list<AppUser>>(value: donorsAsyncValue,data: (donors){return donors.isEmpty}? const Center(child: Text('no Donors yet') ,) : ListView.builder(itemCount: donors.length,itemBuilder: (ctx, index){
              
            }),))
          ],
        ),
      ),
    );
  }
}
