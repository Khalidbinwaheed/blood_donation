import 'package:blood_donation/util/appstyles.dart';
import 'package:flutter/material.dart';

class DonorsEmailedScreen extends StatelessWidget {
  const DonorsEmailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donors Emailed', style: AppStyle.headingTextStyle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundImage: AssetImage('assets/Donorr.png'), // Placeholder
              ),
              title: Text('John Doe ${index + 1}',
                  style: AppStyle.normalTextStyle
                      .copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Contacted on: ${DateTime.now().toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey[600])),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
