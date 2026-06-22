import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/core/widgets/floating_action_menu.dart';
import 'package:blood_donation/features/home/presentation/home_stats_provider.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    final displayName = fullName.isEmpty ? 'User name' : fullName;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeader(displayName: displayName),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Activity As'),
                  const SizedBox(height: 10),
                  const _ActivityGrid(),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Blood Group'),
                  const SizedBox(height: 10),
                  const _BloodGroupGrid(),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Recently Viewed'),
                  const SizedBox(height: 10),
                  const _RecentlyViewedList(),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Our Contribution'),
                  const SizedBox(height: 10),
                  const _ContributionGrid(),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Recent Post'),
                  const SizedBox(height: 10),
                  const _RecentPostsList(),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 96,
              child: FloatingActionMenu(
                primaryIcon: Icons.flash_on_rounded,
                items: [
                  FloatingActionMenuItem(
                    icon: Icons.bloodtype,
                    label: 'Request blood',
                    color: const Color(0xFF0A84FF),
                    onTap: () => context.pushNamed(AppRoutes.requestBlood.name),
                  ),
                  FloatingActionMenuItem(
                    icon: Icons.local_hospital,
                    label: 'Doctors',
                    color: const Color(0xFF34C759),
                    onTap: () => context.pushNamed(AppRoutes.doctors.name),
                  ),
                  FloatingActionMenuItem(
                    icon: Icons.local_taxi,
                    label: 'Ambulance',
                    color: const Color(0xFFFF9F0A),
                    onTap: () =>
                        context.pushNamed(AppRoutes.ambulanceRequest.name),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFEA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -38,
            child: Container(
              width: 124,
              height: 124,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE3DC),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: -4,
            child: Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFF9F3EE),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF272727),
                                ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8A8A8A),
                              ),
                              children: [
                                TextSpan(text: 'Donate Blood: '),
                                TextSpan(
                                  text: 'Off',
                                  style: TextStyle(
                                    color: Color(0xFFEE5459),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _HeaderIconButton(
                      icon: Icons.mail_outline_rounded,
                      onTap: () => context.pushNamed(AppRoutes.inbox.name),
                    ),
                    const SizedBox(width: 8),
                    _HeaderIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () =>
                          context.pushNamed(AppRoutes.notifications.name),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Search Blood',
                    hintStyle:
                        const TextStyle(fontSize: 12, color: Color(0xFFA3A3A3)),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: Color(0xFFB6B6B6),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEDEF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Save a life\nGive Blood',
                              style: TextStyle(
                                fontSize: 22,
                                height: 1.05,
                                color: Color(0xFF3A3A3A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                _Dot(color: Color(0xFFEE5459)),
                                SizedBox(width: 5),
                                _Dot(color: Color(0xFFFAB850)),
                                SizedBox(width: 5),
                                _Dot(color: Color(0xFF73C3F8)),
                                SizedBox(width: 5),
                                _Dot(color: Color(0xFFEE5459)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/Donorr.png',
                          width: 98,
                          height: 74,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF585858)),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF313131),
      ),
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  const _ActivityGrid();

  static const _items = [
    _ActivityItem(
      icon: Icons.bloodtype_rounded,
      title: 'Blood Donor',
      subtitle: '120 post',
      route: AppRoutes.donorHub,
    ),
    _ActivityItem(
      icon: Icons.medical_information_outlined,
      title: 'Blood Recepient',
      subtitle: '120 post',
      route: AppRoutes.recipientHub,
    ),
    _ActivityItem(
      icon: Icons.water_drop_outlined,
      title: 'Create Post',
      subtitle: "It's Easy 1 Step",
      route: AppRoutes.requestBlood,
    ),
    _ActivityItem(
      icon: Icons.opacity_outlined,
      title: 'Blood Given',
      subtitle: "It's Easy 1 Step",
      route: AppRoutes.requestFeed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.15,
      ),
      itemBuilder: (context, index) {
        final item = _items[index];
        return InkWell(
          onTap: () => context.pushNamed(item.route.name),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE9E9E9)),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF343434),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFA0A0A0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final AppRoutes route;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

class _BloodGroupGrid extends StatelessWidget {
  const _BloodGroupGrid();

  static const _groups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _groups.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.9,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => context.pushNamed(
            AppRoutes.bloodGroupSelected.name,
            pathParameters: {'group': _groups[index]},
          ),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 3),
                Text(
                  _groups[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecentlyViewedList extends StatelessWidget {
  const _RecentlyViewedList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _RecentlyViewedCard(),
        SizedBox(height: 10),
        _RecentlyViewedCard(),
      ],
    );
  }
}

class _RecentlyViewedCard extends StatelessWidget {
  const _RecentlyViewedCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(AppRoutes.requestFeed.name),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE4E4E4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFF0),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFBFC2)),
              ),
              child: Icon(
                Icons.water_drop_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency B+ Blood Needed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF353535),
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Color(0xFFFF7A7F),
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Hospital Name',
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFF9B9B9B)),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 12,
                        color: Color(0xFFC3C3C3),
                      ),
                      SizedBox(width: 2),
                      Text(
                        '12 Feb 2022',
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFFB0B0B0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributionGrid extends ConsumerWidget {
  const _ContributionGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(homeStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final items = [
          _ContributionStat(value: '${stats.donors}K+', label: 'Blood Donnor'),
          _ContributionStat(value: stats.posts, label: 'Post everyday'),
          _ContributionStat(value: stats.appointments, label: 'Appointments'),
          _ContributionStat(value: '${stats.donors}K+', label: 'Blood Donnor'),
          _ContributionStat(value: stats.posts, label: 'Post everyday'),
          _ContributionStat(value: stats.appointments, label: 'Appointments'),
        ];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final stat = items[index];
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _bgColors[index],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat.value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _valueColors[index],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFA5A5A5),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  static const _bgColors = [
    Color(0xFFEAF6FF),
    Color(0xFFEAF8F0),
    Color(0xFFEEF0FF),
    Color(0xFFFFEEF8),
    Color(0xFFFFF2E8),
    Color(0xFFFFF8DF),
  ];

  static const _valueColors = [
    Color(0xFF67AEF7),
    Color(0xFF5BC17D),
    Color(0xFF6B74ED),
    Color(0xFFD378D9),
    Color(0xFFFF7A67),
    Color(0xFFE8AD4A),
  ];
}

class _ContributionStat {
  const _ContributionStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}

class _RecentPostsList extends StatelessWidget {
  const _RecentPostsList();

  static const _posts = [
    _RecentPost(
      imagePath: 'assets/Donorr.png',
      title: 'Who can give blood - WHO',
    ),
    _RecentPost(
      imagePath: 'assets/recepint.png',
      title: 'Post-donation advice to blood donors',
    ),
    _RecentPost(
      imagePath: 'assets/logo.png',
      title: 'Risks of deep vein thrombosis',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 142,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _posts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Container(
            width: 126,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: Image.asset(
                    post.imagePath,
                    width: 126,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(7, 6, 7, 0),
                  child: Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF404040),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecentPost {
  const _RecentPost({
    required this.imagePath,
    required this.title,
  });

  final String imagePath;
  final String title;
}
