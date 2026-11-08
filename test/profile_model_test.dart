import 'package:ansar_family/models/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads and serializes the member email', () {
    final profile = ProfileModel.fromJson({
      'id': 'member-id',
      'full_name': 'Aisha',
      'email': 'aisha@example.com',
      'role': 'member',
      'status': 'approved',
    });

    expect(profile.email, 'aisha@example.com');
    expect(profile.toJson(), containsPair('email', 'aisha@example.com'));
    expect(profile.copyWith(email: 'new@example.com').email, 'new@example.com');
  });
}
