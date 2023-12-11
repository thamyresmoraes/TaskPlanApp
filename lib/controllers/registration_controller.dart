import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskPlanApp/models/registration_model.dart';
import 'package:taskPlanApp/views/task_list_screen.dart';

class RegistrationController {
  final RegistrationModel _model = RegistrationModel();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedGender = 'Female';

  void register(BuildContext context) async {
    final UserCredential? userCredential = await _model.registerUser(
      emailController.text,
      passwordController.text,
      nameController.text,
      selectedGender,
    );

    if (userCredential != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskListScreen(userCredential.user!)),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Registration Failed'),
            content: Text('Failed to create an account. Please try again.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }
}
