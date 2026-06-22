import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/user_management/Domain/app_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class UserItem extends StatelessWidget {
  const UserItem(this.appUser, {super.key});

  final AppUser appUser;

  @override
  Widget build(BuildContext context) {
    final name = '${appUser.firstName ?? ''} ${appUser.lastName ?? ''}'
        .trim()
        .ifEmpty('Unknown');
    final role =
        appUser.type.trim().ifEmpty(appUser.role.trim()).ifEmpty('Member');
    final bloodGroup = appUser.bloodGroup.trim().ifEmpty('N/A');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        onTap: () =>
            context.pushNamed(AppRoutes.donorDetails.name, extra: appUser),
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
          child: Text(name[0].toUpperCase()),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${role.toUpperCase()} - $bloodGroup',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              appUser.phoneNumber.ifEmpty('Phone not available'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 6,
          children: [
            IconButton(
              tooltip: 'Call',
              onPressed: () => _makeCall(appUser.phoneNumber),
              icon: const Icon(CupertinoIcons.phone_fill),
            ),
            IconButton(
              tooltip: 'Details',
              onPressed: () => context.pushNamed(AppRoutes.donorDetails.name,
                  extra: appUser),
              icon: const Icon(CupertinoIcons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    final phone = phoneNumber.trim();
    if (phone.isEmpty) {
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
