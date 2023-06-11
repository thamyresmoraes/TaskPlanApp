// screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '/screens/cadastro_page.dart';
import '/screens/login_page.dart';

class HomePage extends StatelessWidget {
  final Future<Database> database;

  const HomePage({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskPlanApp'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              key: Key('cadastrar_button'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        CadastroPage(database: database),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Cadastrar'),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              key: Key('entrar_button'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        LoginPage(database: database),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
