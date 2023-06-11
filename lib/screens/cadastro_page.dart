import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/sucesso_page.dart';

class CadastroPage extends StatefulWidget {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  const CadastroPage({
    Key? key,
    required this.firebaseAuth,
    required this.firestore,
  }) : super(key: key);

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  String _mensagemErro = '';

  Future<void> _efetuarCadastro(BuildContext context) async {
    final nome = _nomeController.text;
    final senha = _senhaController.text;

    try {
      final UserCredential userCredential =
          await widget.firebaseAuth.createUserWithEmailAndPassword(
        email: nome,
        password: senha,
      );

      final userId = userCredential.user!.uid;

      await widget.firestore.collection('usuarios').doc(userId).set({
        'nome': nome,
        'senha': senha,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SucessoPage(
            mensagem: 'Cadastrado com sucesso!',
            firebaseAuth: widget.firebaseAuth,
            firestore: widget.firestore,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _mensagemErro = 'Erro ao cadastrar o usuário: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Usuário'),
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
              onPressed: () => _efetuarCadastro(context),
              child: Text('Cadastrar'),
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
