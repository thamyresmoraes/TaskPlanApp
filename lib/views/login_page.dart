import 'package:flutter/material.dart';
import 'package:taskPlanApp/views/registration_page.dart';
import '../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  final LoginController _controller = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Plan App')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('lib/assets/check_icon.png', width: 100, height: 100),
            TextField(
              controller: _controller.emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _controller.passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => _controller.login(context),
              child: Text('Entrar'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to registration page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: Text('Criar uma conta'),
            ),
          ],
        ),
      ),
    );
  }
}
