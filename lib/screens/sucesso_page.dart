import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/home_page.dart';

class SucessoPage extends StatelessWidget {
  final String mensagem;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  const SucessoPage({
    Key? key,
    required this.mensagem,
    required this.firebaseAuth,
    required this.firestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sucesso'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mensagem),
            ElevatedButton(
              onPressed: () {
                firebaseAuth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      firebaseAuth: firebaseAuth,
                      firestore: firestore,
                    ),
                  ),
                );
              },
              child: Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
