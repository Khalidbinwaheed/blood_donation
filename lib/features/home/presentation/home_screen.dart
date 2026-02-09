import 'package:blood_donation/l10n/app_localizations.dart';
import 'package:blood_donation/features/home/data/news_repository.dart';
import 'package:blood_donation/features/home/presentation/widgets/home_app_bar.dart';
import 'package:blood_donation/features/home/presentation/widgets/mini_map_widget.dart';
import 'package:blood_donation/features/home/presentation/widgets/news_ticker.dart';
import 'package:blood_donation/features/home/presentation/widgets/quick_actions_widget.dart';
import 'package:blood_donation/features/home/presentation/widgets/role_selection_card.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
import 'package:blood_donation/features/user_managment/presentation/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation/features/home/presentation/home_providers.dart';
import 'package:blood_donation/features/user_managment/presentation/widgets/blood_group_donors_list.dart';
import 'package:blood_donation/features/donation/presentation/requests_dashboard.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final userName = userAsync.value?.firstName ?? 'User';
    final bloodGroupFilter = ref.watch(bloodGroupFilterProvider);

    return Scaffold(
      appBar: HomeAppBar(
        userName: userName,
        statusMessage: bloodGroupFilter != null
            ? 'Filter: $bloodGroupFilter'
            : AppLocalizations.of(context)!.lastCheckIn('Today'),
        onNotificationTap: () {
          context.pushNamed('notifications');
        },
      ),
      drawer: const MainDrawer(),
      body: bloodGroupFilter != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: BloodGroupDonorsList(bloodGroup: bloodGroupFilter),
            )
          : RefreshIndicator(
              onRefresh: () async {
                // Trigger a refresh of the news stream
                ref.invalidate(newsStreamProvider);
                await Future.delayed(const Duration(seconds: 1));
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideLength = constraints.maxWidth > 600;
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isWideLength ? 32.0 : 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const NewsTicker(),
                              const SizedBox(height: 16),
                              if (isWideLength) ...[
                                // Wide Layout: Row for Cards + Quick Actions
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          _buildRoleSelectionRow(context),
                                          const SizedBox(height: 24),
                                          const RequestsDashboard(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle(
                                              context,
                                              AppLocalizations.of(context)!
                                                  .quickActionsTitle),
                                          const SizedBox(height: 16),
                                          const QuickActionsWidget(),
                                          const SizedBox(height: 24),
                                          _buildSectionTitle(
                                              context,
                                              AppLocalizations.of(context)!
                                                  .nearbyCentersTitle),
                                          const SizedBox(height: 16),
                                          const AspectRatio(
                                            aspectRatio: 1.5,
                                            child: MiniMapWidget(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                // Mobile Layout: Vertical Stack
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: _buildRoleSelectionRow(context),
                                ),
                                const SizedBox(height: 24),
                                const RequestsDashboard(),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: _buildSectionTitle(
                                      context,
                                      AppLocalizations.of(context)!
                                          .quickActionsTitle),
                                ),
                                const SizedBox(height: 16),
                                const QuickActionsWidget(),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: _buildSectionTitle(
                                      context,
                                      AppLocalizations.of(context)!
                                          .nearbyCentersTitle),
                                ),
                                const MiniMapWidget(),
                              ],
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildRoleSelectionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RoleSelectionCard(
            title: AppLocalizations.of(context)!.donorCtaTitle,
            subtitle: AppLocalizations.of(context)!.donorCtaSubtitle,
            icon: Icons.favorite,
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              context.goNamed('donorHub');
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: RoleSelectionCard(
            title: AppLocalizations.of(context)!.recipientCtaTitle,
            subtitle: AppLocalizations.of(context)!.recipientCtaSubtitle,
            icon: Icons.handshake,
            color: Theme.of(context).colorScheme.secondary,
            onTap: () {
              context.goNamed('recipientHub');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
