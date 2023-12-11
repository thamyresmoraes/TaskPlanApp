import 'package:flutter/material.dart';
import 'package:taskPlanApp/controllers/registration_controller.dart';

class RegistrationView extends StatefulWidget {
  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final RegistrationController _controller = RegistrationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registration')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller.nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _controller.emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _controller.passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            DropdownButtonFormField(
              value: _controller.selectedGender,
              items: ['Female', 'Male', 'Other'].map((String gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _controller.selectedGender = value as String;
                });
              },
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            ElevatedButton(
              onPressed: () => _controller.register(context),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
