import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/user_management/Domain/app_user.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserAsync = ref.watch(authStateProvider);

    return authUserAsync.when(
      data: (authUser) {
        if (authUser == null) {
          return const _SignedOutAccountView();
        }

        final profileAsync = ref.watch(userProfileStreamProvider(authUser.uid));
        return profileAsync.when(
          data: (liveUser) => _AccountView(
            user: liveUser ?? authUser,
            onSignOut: () => _confirmAndSignOut(context, ref),
          ),
          loading: () => _AccountView(
            user: authUser,
            isSyncing: true,
            onSignOut: () => _confirmAndSignOut(context, ref),
          ),
          error: (_, __) => _AccountView(
            user: authUser,
            hasSyncIssue: true,
            onSignOut: () => _confirmAndSignOut(context, ref),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('My Account')),
        body: Center(child: Text('Could not load account: $error')),
      ),
    );
  }

  Future<void> _confirmAndSignOut(BuildContext context, WidgetRef ref) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) {
      return;
    }

    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) {
      context.goNamed(AppRoutes.signIn.name);
    }
  }
}

class _SignedOutAccountView extends StatelessWidget {
  const _SignedOutAccountView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      CupertinoIcons.person_crop_circle_badge_exclam,
                      size: 34,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You are not signed in',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to view your profile, records, and emergency settings.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.goNamed(AppRoutes.signIn.name),
                    icon: const Icon(CupertinoIcons.arrow_right_circle_fill),
                    label: const Text('Sign In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountView extends ConsumerStatefulWidget {
  const _AccountView({
    required this.user,
    required this.onSignOut,
    this.isSyncing = false,
    this.hasSyncIssue = false,
  });

  final AppUser user;
  final VoidCallback onSignOut;
  final bool isSyncing;
  final bool hasSyncIssue;

  @override
  ConsumerState<_AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends ConsumerState<_AccountView> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
    );

    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      await ref.read(authRepositoryProvider).updateProfilePicture(
            widget.user.uid,
            image,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _roleLabel(widget.user);
    final fallbackAsset = role.toLowerCase() == 'donor'
        ? 'assets/Donorr.png'
        : 'assets/recepint.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        actions: [
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.pushNamed(AppRoutes.settings.name),
            icon: const Icon(CupertinoIcons.settings),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 840;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _AvatarPreview(
                            photoUrl: widget.user.photoUrl,
                            fallbackAsset: fallbackAsset,
                            initials: _initials(widget.user),
                            onUpload: _pickAndUploadImage,
                            isUploading: _isUploading,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${widget.user.firstName ?? ''} ${widget.user.lastName ?? ''}'
                                .trim()
                                .ifEmpty('Account'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            role,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              if (widget.isSyncing)
                                const Chip(
                                  avatar: SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  label: Text('Syncing profile...'),
                                ),
                              if (widget.hasSyncIssue)
                                const Chip(
                                  avatar: Icon(Icons.info_outline, size: 16),
                                  label: Text('Showing cached profile'),
                                ),
                              ActionChip(
                                label: const Text('Complete profile'),
                                avatar: const Icon(CupertinoIcons
                                    .person_crop_circle_badge_plus),
                                onPressed: () => context
                                    .pushNamed(AppRoutes.profileSetup.name),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _InfoCard(
                            title: 'Contact',
                            fields: [
                              _InfoField('Email', widget.user.email),
                              _InfoField('Phone',
                                  widget.user.phoneNumber.ifEmpty('-')),
                              _InfoField('District',
                                  widget.user.district.ifEmpty('-')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            title: 'Donation Profile',
                            fields: [
                              _InfoField('Blood Group',
                                  widget.user.bloodGroup.ifEmpty('-')),
                              _InfoField(
                                  'Status',
                                  widget.user.donorEligibilityStatus
                                      .ifEmpty('-')),
                              _InfoField('Type', widget.user.type.ifEmpty('-')),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _InfoCard(
                      title: 'Contact',
                      fields: [
                        _InfoField('Email', widget.user.email),
                        _InfoField(
                            'Phone', widget.user.phoneNumber.ifEmpty('-')),
                        _InfoField(
                            'District', widget.user.district.ifEmpty('-')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'Donation Profile',
                      fields: [
                        _InfoField(
                            'Blood Group', widget.user.bloodGroup.ifEmpty('-')),
                        _InfoField('Status',
                            widget.user.donorEligibilityStatus.ifEmpty('-')),
                        _InfoField('Type', widget.user.type.ifEmpty('-')),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: widget.onSignOut,
                    icon: const Icon(CupertinoIcons.square_arrow_right),
                    label: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _roleLabel(AppUser user) {
    final normalizedRole = user.role.trim().toLowerCase();
    final normalizedType = user.type.trim().toLowerCase();
    final value = normalizedRole.isNotEmpty &&
            normalizedRole != 'patient' &&
            normalizedRole != 'unknown'
        ? normalizedRole
        : normalizedType;
    if (value.isEmpty) {
      return 'Recipient';
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _initials(AppUser user) {
    final first = user.firstName?.trim() ?? '';
    final last = user.lastName?.trim() ?? '';
    if (first.isEmpty && last.isEmpty) {
      return 'U';
    }
    if (last.isEmpty) {
      return first[0].toUpperCase();
    }
    return '${first[0]}${last[0]}'.toUpperCase();
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.photoUrl,
    required this.fallbackAsset,
    required this.initials,
    required this.onUpload,
    this.isUploading = false,
  });

  final String? photoUrl;
  final String fallbackAsset;
  final String initials;
  final VoidCallback onUpload;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: isUploading ? null : onUpload,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (_, __, ___) => _buildFallback(context),
                  )
                : _buildFallback(context),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isUploading ? null : onUpload,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                CupertinoIcons.camera_fill,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Image.asset(
      fallbackAsset,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.fields,
  });

  final String title;
  final List<_InfoField> fields;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...fields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 108,
                      child: Text(
                        field.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        field.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoField {
  const _InfoField(this.label, this.value);
  final String label;
  final String value;
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
