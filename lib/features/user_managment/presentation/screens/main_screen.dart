import 'package:blood_donation/features/user_managment/data/firestore_repository.dart';
import 'package:blood_donation/features/user_managment/presentation/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donorsAsyncValue = ref.watch(loadDonorsProvider);

    ref.listen<AsyncValue>(loadDonorsProvider, (_,state){});
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation'),
      ),
      drawer: const MainDrawer(),
    );
  }
}
