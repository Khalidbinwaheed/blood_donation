import 'package:blood_donation/features/user_managment/Domain/app_user.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:blood_donation/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DonorDetailsScreen extends StatelessWidget {
  final AppUser donor;

  const DonorDetailsScreen({super.key, required this.donor});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrlString(launchUri.toString())) {
      await launchUrlString(launchUri.toString());
    } else {
      // Handle error
      debugPrint('Count not launch phone call to $phoneNumber');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrlString(launchUri.toString())) {
      await launchUrlString(launchUri.toString());
    } else {
      // Handle error
      debugPrint('Count not launch email to $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Donor Details'),
        backgroundColor: AppStyle.mainColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.red[100],
                child: Text(
                  (donor.firstName?.isNotEmpty == true)
                      ? donor.firstName![0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppStyle.mainColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${donor.firstName ?? ''} ${donor.lastName ?? ''}',
              style: AppStyle.titleTextStyle.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent),
              ),
              child: Text(
                'Blood Group: ${donor.bloodGroup}',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildDetailRow(Icons.phone, 'Phone', donor.phoneNumber,
                onTap: () => _makePhoneCall(donor.phoneNumber)),
            const Divider(height: 30),
            _buildDetailRow(Icons.email, 'Email', donor.email,
                onTap: () => _sendEmail(donor.email)),
            const Divider(height: 30),
            // Assuming district is not in AppUser yet based on previous check, but was mentioned in plan.
            // If AppUser definition doesn't have district, we skip it or show type.
            _buildDetailRow(Icons.person_outline, 'Type', donor.type),

            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(donor.phoneNumber),
                    icon: const Icon(Icons.call),
                    label: const Text('Call Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendEmail(donor.email),
                    icon: const Icon(Icons.email),
                    label: const Text('Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
