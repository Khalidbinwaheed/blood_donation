import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/recipient/data/donation_repository.dart';
import 'package:blood_donation/features/user_management/Domain/app_user.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorDetailsScreen extends ConsumerStatefulWidget {
  const DonorDetailsScreen({
    required this.donor,
    super.key,
  });

  final AppUser donor;

  @override
  ConsumerState<DonorDetailsScreen> createState() => _DonorDetailsScreenState();
}

class _DonorDetailsScreenState extends ConsumerState<DonorDetailsScreen> {
  bool _showCreateAds = false;

  @override
  Widget build(BuildContext context) {
    final donorAsync = ref.watch(userProfileStreamProvider(widget.donor.uid));
    final requestsStream =
        ref.watch(donationRepositoryProvider).getUserRequests(widget.donor.uid);

    return donorAsync.when(
      data: (liveDonor) {
        final donor = liveDonor ?? widget.donor;
        final donorName =
            '${donor.firstName ?? ''} ${donor.lastName ?? ''}'.trim().ifEmpty(
                  'Cameron Williamson',
                );
        final bloodGroup = donor.bloodGroup.trim().ifEmpty('A+');
        final city = donor.district.ifEmpty('Dhaka');
        final country = _countryFromLocale(donor.locale);
        final phone = donor.phoneNumber.trim().ifEmpty('+88 01818 121212');
        final email = donor.email.trim().ifEmpty('cameron@mail.com');
        final aboutText = donor.conditions.isEmpty
            ? 'libero tempore, cum soluta nobis est eligendi optio cumque '
                'nihil impedit quo minus id quod maxime placeat facere possimus'
            : donor.conditions.join(', ');

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
              'Profile Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F2F2F),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: _DonorAvatar(
                    photoUrl: donor.photoUrl,
                    fallbackText: donorName,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    donorName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF252525),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '$bloodGroup Blood',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF2E2E2E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFD4951),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            final donorName =
                                '${donor.firstName ?? ''} ${donor.lastName ?? ''}'
                                    .trim()
                                    .ifEmpty('Donor');
                            context.pushNamed(
                              AppRoutes.conversation.name,
                              pathParameters: {'peerId': donor.uid},
                              queryParameters: {'name': donorName},
                            );
                          },
                          child: const Text(
                            'Chat Now',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFD4951)),
                            foregroundColor: const Color(0xFFFD4951),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () => _makePhoneCall(phone),
                          child: const Text(
                            'Call',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SegmentLineToggle(
                  showCreateAds: _showCreateAds,
                  onChanged: (value) => setState(() => _showCreateAds = value),
                ),
                const SizedBox(height: 14),
                if (!_showCreateAds) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE3E3E3)),
                    ),
                    child: Column(
                      children: [
                        _AboutInfoRow(
                          icon: Icons.key_rounded,
                          label: 'Age',
                          value: _ageFromDate(donor.lastDonationDate),
                        ),
                        const _AboutInfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Gender',
                          value: 'Male',
                        ),
                        _AboutInfoRow(
                          icon: Icons.arrow_forward_ios_rounded,
                          label: 'City',
                          value: city,
                        ),
                        _AboutInfoRow(
                          icon: Icons.public_rounded,
                          label: 'Country',
                          value: country,
                        ),
                        _AboutInfoRow(
                          icon: Icons.call_outlined,
                          label: 'Mobile',
                          value: phone,
                          isLast: false,
                        ),
                        _AboutInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: email,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'About User',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    aboutText,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.35,
                      color: Color(0xFF666D7A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Social Media',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      _SocialButton(icon: Icons.facebook_rounded),
                      SizedBox(width: 10),
                      _SocialButton(icon: Icons.alternate_email_rounded),
                      SizedBox(width: 10),
                      _SocialButton(icon: Icons.send_rounded),
                      SizedBox(width: 10),
                      _SocialButton(icon: Icons.work_outline_rounded),
                    ],
                  ),
                ] else ...[
                  _CreateAdsSection(stream: requestsStream),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: const Color(0xFFF2F2F4),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF2F2F4),
          title: const Text('Profile Details'),
        ),
        body: Center(
          child: Text('Could not load profile: $error'),
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

  String _countryFromLocale(String? locale) {
    final normalized = (locale ?? '').toLowerCase();
    if (normalized.contains('pk') || normalized.contains('ur')) {
      return 'Pakistan';
    }
    return 'Bangladesh';
  }

  String _ageFromDate(DateTime? date) {
    if (date == null) {
      return '30';
    }
    final years = DateTime.now().difference(date).inDays ~/ 365;
    if (years <= 0) {
      return '30';
    }
    return '$years';
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final sanitized = phoneNumber.trim();
    if (sanitized.isEmpty) {
      return;
    }
    final uri = Uri.parse('tel:$sanitized');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _DonorAvatar extends StatelessWidget {
  const _DonorAvatar({
    required this.photoUrl,
    required this.fallbackText,
  });

  final String? photoUrl;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final initial = fallbackText.trim().isEmpty
        ? 'C'
        : fallbackText.trim()[0].toUpperCase();
    final hasPhoto = (photoUrl ?? '').trim().isNotEmpty;

    return CircleAvatar(
      radius: 42,
      backgroundColor: const Color(0xFFD2DDE1),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(initial),
              )
            : _fallback(initial),
      ),
    );
  }

  Widget _fallback(String initial) {
    return Container(
      width: 84,
      height: 84,
      color: const Color(0xFFD2DDE1),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4C5962),
        ),
      ),
    );
  }
}

class _SegmentLineToggle extends StatelessWidget {
  const _SegmentLineToggle({
    required this.showCreateAds,
    required this.onChanged,
  });

  final bool showCreateAds;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SegmentTextButton(
                text: 'About',
                selected: !showCreateAds,
                onTap: () => onChanged(false),
              ),
            ),
            Expanded(
              child: _SegmentTextButton(
                text: 'Create Ads',
                selected: showCreateAds,
                onTap: () => onChanged(true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xFFE0E0E0),
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 3,
                color: !showCreateAds
                    ? const Color(0xFFFD4951)
                    : Colors.transparent,
              ),
            ),
            Expanded(
              child: Container(
                height: 3,
                color: showCreateAds
                    ? const Color(0xFFFD4951)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SegmentTextButton extends StatelessWidget {
  const _SegmentTextButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 40,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28,
              color:
                  selected ? const Color(0xFF202020) : const Color(0xFF2B2B2B),
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutInfoRow extends StatelessWidget {
  const _AboutInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFEDEDED)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 11, 10, 11),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFEFF0),
              ),
              child: Icon(
                icon,
                size: 13,
                color: const Color(0xFFFD4951),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 22,
                  color: Color(0xFF868D9A),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  color: Color(0xFF666D7A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateAdsSection extends StatelessWidget {
  const _CreateAdsSection({
    required this.stream,
  });

  final Stream<List<Map<String, dynamic>>> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data ?? const <Map<String, dynamic>>[];
        if (items.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: const Text(
              'No ads posted yet.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6A6A6A),
              ),
            ),
          );
        }

        final first = items.first;
        final group = (first['bloodGroupNeeded'] ?? first['bloodGroup'] ?? 'B+')
            .toString();
        final title = 'Emergency $group Blood Needed';
        final hospital = (first['hospitalName'] ?? 'Hospital Name').toString();
        final createdAt = _asDateTime(first['createdAt'] ?? first['date']);
        final dateText = createdAt == null
            ? '12 Feb 2022'
            : DateFormat('dd MMM yyyy').format(createdAt);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE4E4E4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFEFF0),
                  border: Border.all(color: const Color(0xFFFFB8BC)),
                ),
                child: Center(
                  child: Text(
                    group.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFD4951),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
        );
      },
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2EA2F3)),
      ),
      child: Icon(icon, color: const Color(0xFF2EA2F3), size: 22),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
