import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('digital id QR payload includes required fields', () {
    final payload = jsonEncode({
      'app': 'lifeline',
      'uid': 'user-123',
      'name': 'Jane Doe',
      'bloodGroup': 'O+',
      'version': 1,
    });

    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    expect(decoded['app'], 'lifeline');
    expect(decoded['uid'], 'user-123');
    expect(decoded['bloodGroup'], 'O+');
    expect(decoded['version'], 1);
  });
}
