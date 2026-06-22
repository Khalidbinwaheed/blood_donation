import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/recipient/data/donation_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BloodRequestsScreen extends ConsumerStatefulWidget {
  const BloodRequestsScreen({super.key});

  @override
  ConsumerState<BloodRequestsScreen> createState() =>
      _BloodRequestsScreenState();
}

class _BloodRequestsScreenState extends ConsumerState<BloodRequestsScreen> {
  bool _showGroupBadge = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final requestsStream =
        ref.watch(donationRepositoryProvider).getOpenRequests();

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
          'Blood Request',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F2F2F),
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: requestsStream,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting &&
              data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Could not load requests.',
                style: TextStyle(color: Color(0xFF6B6B6B)),
              ),
            );
          }

          final requests = data ?? const <Map<String, dynamic>>[];
          final city = _resolveCity(requests, user?.district.toString());
          final badgeGroup = _resolveBadgeGroup(requests);

          return Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Blood request',
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
                      if (requests.isEmpty)
                        _EmptyRequestView(
                          onCreate: () =>
                              context.pushNamed(AppRoutes.requestBlood.name),
                        )
                      else
                        ListView.separated(
                          padding: EdgeInsets.only(
                            bottom: _showGroupBadge ? 56 : 6,
                          ),
                          itemCount: requests.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = requests[index];
                            return _RequestFeedCard(
                              item: item,
                              onTap: () => context.pushNamed(
                                AppRoutes.requestPostDetails.name,
                                pathParameters: {
                                  'id': item['id'].toString(),
                                },
                                extra: item,
                              ),
                            );
                          },
                        ),
                      if (_showGroupBadge && requests.isNotEmpty)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 8,
                          child: Center(
                            child: _ActiveGroupChip(
                              group: badgeGroup,
                              onClose: () =>
                                  setState(() => _showGroupBadge = false),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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

  String _resolveCity(
    List<Map<String, dynamic>> requests,
    String? userDistrict,
  ) {
    final userCity = (userDistrict ?? '').trim();
    if (userCity.isNotEmpty) {
      return userCity;
    }
    for (final item in requests) {
      final city = (item['city'] ?? item['district'] ?? '').toString().trim();
      if (city.isNotEmpty) {
        return city;
      }
    }
    return 'Dhaka';
  }

  String _resolveBadgeGroup(List<Map<String, dynamic>> requests) {
    for (final item in requests) {
      final group =
          (item['bloodGroupNeeded'] ?? item['bloodGroup'] ?? '').toString();
      if (group.trim().isNotEmpty) {
        return group.toUpperCase();
      }
    }
    return 'B+';
  }
}

class _RequestFeedCard extends StatelessWidget {
  const _RequestFeedCard({
    required this.item,
    required this.onTap,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final group =
        (item['bloodGroupNeeded'] ?? item['bloodGroup'] ?? '').toString();
    final hospital = (item['hospitalName'] ?? 'Hospital Name').toString();
    final createdAt = _asDateTime(item['createdAt'] ?? item['date']);
    final dateText = createdAt == null
        ? '12 Feb 2022'
        : DateFormat('dd MMM yyyy').format(createdAt);
    final title = group.trim().isEmpty
        ? 'Emergency Blood Needed'
        : 'Emergency $group Blood Needed';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE4E4E4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFEFF0),
                  border: Border.all(color: const Color(0xFFFFB9BD)),
                ),
                child: const Icon(
                  Icons.bloodtype_rounded,
                  size: 16,
                  color: Color(0xFFEF5C63),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF353535),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Color(0xFFE76E75),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            hospital,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF9A9A9A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: Color(0xFFC8C8C8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFB0B0B0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

class _ActiveGroupChip extends StatelessWidget {
  const _ActiveGroupChip({
    required this.group,
    required this.onClose,
  });

  final String group;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
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
          const SizedBox(width: 2),
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: Color(0xFFEF5C63),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRequestView extends StatelessWidget {
  const _EmptyRequestView({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bloodtype_outlined,
              size: 26,
              color: Color(0xFFEF5C63),
            ),
            const SizedBox(height: 6),
            const Text(
              'No blood request found',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF5C5C5C),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onCreate,
              child: const Text('Create request'),
            ),
          ],
        ),
      ),
    );
  }
}
