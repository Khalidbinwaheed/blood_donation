import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/recipient/data/donation_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestPostDetailsScreen extends ConsumerStatefulWidget {
  const RequestPostDetailsScreen({
    required this.requestId,
    this.initialData,
    super.key,
  });

  final String requestId;
  final Map<String, dynamic>? initialData;

  @override
  ConsumerState<RequestPostDetailsScreen> createState() =>
      _RequestPostDetailsScreenState();
}

class _RequestPostDetailsScreenState
    extends ConsumerState<RequestPostDetailsScreen> {
  bool _isOffering = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final requestStream =
        ref.watch(donationRepositoryProvider).watchRequestById(widget.requestId);

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
          'Post Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F2F2F),
          ),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: requestStream,
        initialData: widget.initialData,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting &&
              data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (data == null) {
            return const Center(
              child: Text(
                'Request not found.',
                style: TextStyle(color: Color(0xFF666666)),
              ),
            );
          }

          final bloodGroup = _bloodGroup(data);
          final title = 'Emergency $bloodGroup Blood Needed';
          final personName = _value(
            data,
            ['contactPersonName', 'requesterName', 'name'],
            'Person Name',
          );
          final phone = _value(
            data,
            ['contactPhone', 'phone', 'phoneNumber'],
            '+88 011122233344',
          );
          final bags = _bagValue(data);
          final country = _value(data, ['country'], 'Bangladesh');
          final city = _value(data, ['city', 'district'], 'Dhaka');
          final hospital =
              _value(data, ['hospitalName', 'hospital'], 'Nur Hospital');
          final reason = _value(
            data,
            ['note', 'reason'],
            'No additional details provided.',
          );
          final status = (data['status'] ?? 'Open').toString();
          final requesterId = (data['requesterId'] ?? '').toString();
          final isOwner = user != null && requesterId == user.uid;
          final canOffer = user != null &&
              !isOwner &&
              status.toLowerCase() == 'open' &&
              (user.role.toLowerCase().contains('donor') ||
                  user.type.toLowerCase().contains('donor') ||
                  user.bloodGroup.trim().isNotEmpty);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: _BloodGroupBadge(group: bloodGroup),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF323232),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE6E6E6)),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Contact Person',
                        value: personName,
                      ),
                      const Divider(height: 1, color: Color(0xFFEDEDED)),
                      _InfoRow(
                        icon: Icons.call_outlined,
                        label: 'Mobile Number',
                        value: phone,
                        onTap: () => _launchPhone(phone),
                      ),
                      const Divider(height: 1, color: Color(0xFFEDEDED)),
                      _InfoRow(
                        icon: Icons.bloodtype_outlined,
                        label: 'How many Bag(s)',
                        value: bags,
                      ),
                      const Divider(height: 1, color: Color(0xFFEDEDED)),
                      _InfoRow(
                        icon: Icons.flag_outlined,
                        label: 'Country',
                        value: country,
                      ),
                      const Divider(height: 1, color: Color(0xFFEDEDED)),
                      _InfoRow(
                        icon: Icons.location_city_outlined,
                        label: 'City',
                        value: city,
                      ),
                      const Divider(height: 1, color: Color(0xFFEDEDED)),
                      _InfoRow(
                        icon: Icons.local_hospital_outlined,
                        label: 'Hospital',
                        value: hospital,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Why do you need blood?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF363636),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Color(0xFF6E6E6E),
                  ),
                ),
                const SizedBox(height: 10),
                if (canOffer)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isOffering
                          ? null
                          : () => _offerToDonate(context, user, data),
                      icon: _isOffering
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.favorite_outline),
                      label: Text(
                        _isOffering ? 'Sending offer...' : 'I want to donate',
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E8EC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOwner
                          ? 'Your request is $status. Donors can contact you directly.'
                          : 'If you want to donate, sign in with a donor profile and tap "I want to donate".',
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: Color(0xFF6A6B70),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TagChip(text: '#Baby'),
                    _TagChip(text: '#Woman'),
                    _TagChip(text: '#Urgents'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _offerToDonate(
    BuildContext context,
    dynamic user,
    Map<String, dynamic> data,
  ) async {
    setState(() => _isOffering = true);
    try {
      final donorName =
          '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().ifEmpty('Donor');
      await ref.read(donationRepositoryProvider).offerToDonate(
            requestId: widget.requestId,
            donorUid: user.uid,
            donorName: donorName,
            donorPhone: user.phoneNumber?.toString() ?? '',
            donorBloodGroup: user.bloodGroup?.toString() ?? '',
          );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your offer was sent to the requester.'),
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send offer: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOffering = false);
      }
    }
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goNamed(AppRoutes.requestFeed.name);
  }

  String _bloodGroup(Map<String, dynamic> data) {
    final group =
        (data['bloodGroupNeeded'] ?? data['bloodGroup'] ?? 'B+').toString();
    if (group.trim().isEmpty) {
      return 'B+';
    }
    return group.toUpperCase();
  }

  String _value(
    Map<String, dynamic> data,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = (data[key] ?? '').toString().trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return fallback;
  }

  String _bagValue(Map<String, dynamic> data) {
    final raw = (data['amount'] ?? data['bags'] ?? '3').toString().trim();
    if (raw.isEmpty) {
      return '3 Bags';
    }
    if (raw.toLowerCase().contains('bag')) {
      return raw;
    }
    return '$raw Bags';
  }

  Future<void> _launchPhone(String number) async {
    final normalized = number.trim();
    if (normalized.isEmpty) {
      return;
    }
    final uri = Uri.parse('tel:$normalized');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

class _BloodGroupBadge extends StatelessWidget {
  const _BloodGroupBadge({required this.group});

  final String group;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFEFF0),
        border: Border.all(color: const Color(0xFFFFABB0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.water_drop_rounded,
            size: 15,
            color: Color(0xFFEF5C63),
          ),
          Text(
            group,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEF5C63),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFEFF0),
              ),
              child: Icon(
                icon,
                size: 12,
                color: const Color(0xFFEF5C63),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8A8A8A),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6E6E6E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFFEF5C63),
        ),
      ),
    );
  }
}
