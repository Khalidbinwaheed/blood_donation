import 'package:blood_donation/util/appstyles.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us', style: AppStyle.headingTextStyle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 20),
            Text(
              'Blood Donation App',
              style: AppStyle.titleTextStyle
                  .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            const Text(
              'Our mission is to bridge the gap between blood donors and recipients. We provide a platform for easy communication and quick access to life-saving blood donations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            _buildFeature('Find Donors', Icons.search),
            _buildFeature('Connect Instantly', Icons.contact_phone),
            _buildFeature('Save Lives', Icons.favorite),
            const SizedBox(height: 40),
            Text(
              '© 2026 Code Craft It Solution',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppStyle.mainColor),
          const SizedBox(width: 10),
          Text(text,
              style: AppStyle.normalTextStyle
                  .copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
