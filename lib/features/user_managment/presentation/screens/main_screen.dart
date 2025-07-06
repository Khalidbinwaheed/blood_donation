import 'package:blood_donation/common_widgets/async_value_ui.dart';
import 'package:blood_donation/common_widgets/async_value_widget.dart';
import 'package:blood_donation/features/user_managment/Domain/app_user.dart';
import 'package:blood_donation/features/user_managment/data/firestore_repository.dart';
import 'package:blood_donation/features/user_managment/presentation/widgets/main_drawer.dart';
import 'package:blood_donation/features/user_managment/presentation/widgets/user_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final donorsAsyncValue = ref.watch(loadDonorsProvider);

    ref.listen<AsyncValue>(loadDonorsProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(loadDonorsProvider);
            },
          ),
        ],
      ),
      drawer: const MainDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to Add Donor Screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Donor tapped!')),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Donor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search donors by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),
            // Donor List
            Expanded(
              child: AsyncValueWidget<List<AppUser>>(
                value: donorsAsyncValue,
                data: (donors) {
                  final filteredDonors = donors
                      .where((d) => d.name.toLowerCase().contains(_searchQuery))
                      .toList();

                  if (filteredDonors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bloodtype,
                              size: 80, color: Colors.red[200]),
                          const SizedBox(height: 16),
                          const Text(
                            'No donors found',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Be the first to add a donor!',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Navigate to Add Donor Screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Add Donor tapped!')),
                              );
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Donor'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(loadDonorsProvider);
                    },
                    child: ListView.separated(
                      itemCount: filteredDonors.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final donor = filteredDonors[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red[100],
                            child: Text(
                              donor.name.isNotEmpty
                                  ? donor.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          title: Text(
                            donor.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Blood Group: ${donor.bloodGroup}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline,
                                color: Colors.redAccent),
                            tooltip: 'View Details',
                            onPressed: () {
                              // TODO: Navigate to donor details
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Details for ${donor.name}')),
                              );
                            },
                          ),
                          onTap: () {
                            // TODO: Navigate to donor details
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tapped ${donor.name}')),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
