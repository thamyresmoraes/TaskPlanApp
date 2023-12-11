import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String email;
  final String password;

  UserModel({
    required this.email,
    required this.password,
  });
}

class LoginModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      return null;
    }
  }
}
