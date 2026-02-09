import 'package:blood_donation/features/donation/domain/blood_request.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({required this.request, super.key});

  final BloodRequest request;

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'moderate':
        return Colors.yellow.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getTimeRemaining() {
    final now = DateTime.now();
    final difference = request.deadline.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    if (difference.inHours > 24) {
      return '${difference.inDays} days left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours left';
    } else {
      return '${difference.inMinutes} mins left';
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: request.contactEmail,
      query:
          'subject=Help for Blood Request: ${request.id}&body=I can help with the donation request for blood group ${request.bloodGroupNeeded}.',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(request.severity)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _getSeverityColor(request.severity)),
                  ),
                  child: Text(
                    request.severity.toUpperCase(),
                    style: TextStyle(
                      color: _getSeverityColor(request.severity),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  _getTimeRemaining(),
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.bloodtype,
                    size: 40, color: AppStyle.mainColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${request.bloodGroupNeeded} Blood Needed',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.hospitalName,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                request.note,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _launchEmail,
                icon: const Icon(Icons.email),
                label: const Text('Email Donor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.mainColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
