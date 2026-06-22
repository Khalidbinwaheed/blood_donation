import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:blood_donation/features/user_management/presentation/widgets/blood_group_donors_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BloodGroupSelectedScreen extends ConsumerWidget {
  const BloodGroupSelectedScreen(this.bloodGroup, {super.key});

  final String bloodGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final city = user?.district.trim().isNotEmpty == true
        ? user!.district
        : 'Dhaka';
    final displayGroup = bloodGroup.trim().isEmpty ? 'B+' : bloodGroup;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F4),
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => _goBack(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF353535),
          ),
        ),
        title: const Text(
          'Blood Donar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F2F2F),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Select place',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF505050),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFFEF666D),
                ),
                const SizedBox(width: 2),
                Text(
                  city,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFEF666D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Stack(
                children: [
                  BloodGroupDonorsList(bloodGroup: displayGroup),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: Center(
                      child: _ActiveGroupChip(group: displayGroup),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goNamed(AppRoutes.home.name);
  }
}

class _ActiveGroupChip extends StatelessWidget {
  const _ActiveGroupChip({required this.group});

  final String group;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 8, 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFA9AE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bloodtype_rounded,
            size: 13,
            color: Color(0xFFEF5C63),
          ),
          const SizedBox(width: 4),
          Text(
            '$group Blood',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFEF5C63),
            ),
          ),
          const SizedBox(width: 1),
          const Icon(
            Icons.keyboard_arrow_up_rounded,
            size: 15,
            color: Color(0xFFEF5C63),
          ),
        ],
      ),
    );
  }
}
