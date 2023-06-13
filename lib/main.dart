import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  runApp(MyApp(firebaseAuth: firebaseAuth, firestore: firestore));
}

class MyApp extends StatelessWidget {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  const MyApp({
    Key? key,
    required this.firebaseAuth,
    required this.firestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Plan App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(
        firebaseAuth: firebaseAuth,
        firestore: firestore,
      ),
    );
  }
}
