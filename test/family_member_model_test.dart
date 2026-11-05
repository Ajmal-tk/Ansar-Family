import 'package:ansar_family/models/family_member_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'reads optional household details and serializes database column names',
    () {
      final member = FamilyMemberModel.fromJson({
        'id': 'member-id',
        'user_id': 'user-id',
        'name': 'Aisha',
        'relation': 'Child',
        'age': 18,
        'gender': 'Female',
        'education': 'College / University',
        'work_status': 'Student',
        'marital_status': 'Single',
        'created_at': '2026-11-05T00:00:00.000Z',
      });

      expect(member.gender, 'Female');
      expect(member.education, 'College / University');
      expect(member.workStatus, 'Student');
      expect(member.maritalStatus, 'Single');
      expect(member.toJson(), containsPair('work_status', 'Student'));
      expect(member.toJson(), containsPair('marital_status', 'Single'));
    },
  );

  test('allows existing household records without optional details', () {
    final member = FamilyMemberModel.fromJson({
      'id': 'member-id',
      'user_id': 'user-id',
      'name': 'Aisha',
      'created_at': '2026-11-05T00:00:00.000Z',
    });

    expect(member.gender, isNull);
    expect(member.education, isNull);
    expect(member.workStatus, isNull);
    expect(member.maritalStatus, isNull);
  });
}
