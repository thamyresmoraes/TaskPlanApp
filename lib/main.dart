import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taskPlanApp/views/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TaskPlanApp());
}

class TaskPlanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(Theme.of(context)); // Adicione esta linha

    return MaterialApp(
      title: 'Task Plan App',
      theme: ThemeData(),
      home: LoginView(),
    );
  }
}
