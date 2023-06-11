// main.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

import '/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databasePath = await getDatabasesPath();
  final database = await openDatabase(
    Path.join(databasePath, 'app_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE usuarios(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, senha TEXT)',
      );
    },
    version: 1,
  );

  runApp(MyApp(database: Future.value(database)));
}

class MyApp extends StatelessWidget {
  final Future<Database> database;

  const MyApp({required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Cadastro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(database: database),
    );
  }
}
