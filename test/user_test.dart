import 'package:taskPlanApp/models/user.dart';
import 'package:test/test.dart';

void main() {
  test('User should have a uid', () {
    final user = User(uid: '1234567890', name: "Tes", gender: 'Male');
    expect(user.uid, '1234567890');
  });

  test('User should have a name', () {
    final user = User(uid: '1234567890', name: 'John Doe', gender: 'Female');
    expect(user.name, 'John Doe');
  });

  test('User should have a gender', () {
    final user = User(uid: '1234567890', name: 'John Doe', gender: 'Male');
    expect(user.gender, 'Male');
  });
}
