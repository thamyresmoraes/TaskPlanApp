import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/sucesso_page.dart';

class LoginPage extends StatefulWidget {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  const LoginPage({
    Key? key,
    required this.firebaseAuth,
    required this.firestore,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  String _mensagemErro = '';

  Future<void> _efetuarLogin(BuildContext context) async {
    final nome = _nomeController.text;
    final senha = _senhaController.text;

    try {
      final UserCredential userCredential =
          await widget.firebaseAuth.signInWithEmailAndPassword(
        email: nome,
        password: senha,
      );

      final userId = userCredential.user!.uid;

      final snapshot =
          await widget.firestore.collection('usuarios').doc(userId).get();

      if (snapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SucessoPage(
              mensagem: 'Login Efetuado com sucesso!',
              firebaseAuth: widget.firebaseAuth,
              firestore: widget.firestore,
            ),
          ),
        );
      } else {
        setState(() {
          _mensagemErro = 'Usuário ou senha incorretos';
        });
      }
    } catch (e) {
      setState(() {
        _mensagemErro = 'Erro ao efetuar o login: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
              ),
            ),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _efetuarLogin(context),
              child: Text('Login'),
            ),
            SizedBox(height: 8.0),
            Text(
              _mensagemErro,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
