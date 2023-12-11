import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_list_model.dart';
import '../models/user_model.dart';
import '../views/task_list_view.dart';

class LoginController {
  final LoginModel _model = LoginModel();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) async {
    UserModel user = UserModel(
      email: emailController.text,
      password: passwordController.text,
    );

    final UserCredential? userCredential = await _model.login(user.email, user.password);

    if (userCredential != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TaskListView(
            model: TaskListModel(userCredential.user!),
            listNameController: TextEditingController(),
            createTaskList: () {}, 
            deleteTaskList: (int index) {}, // Adicione a lógica necessária aqui
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Falhou'),
            content: Text('Email ou senha inválidos.'),
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
