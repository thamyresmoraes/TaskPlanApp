// screens/login_page.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '/screens/sucesso_page.dart';

class LoginPage extends StatefulWidget {
  final Future<Database> database;

  const LoginPage({required this.database});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isSenhaVisivel = false;
  String _mensagemErro = '';

  Future<void> _efetuarLogin() async {
    final nome = _nomeController.text;
    final senha = _senhaController.text;

    if (widget.database == null) {
      setState(() {
        _mensagemErro = 'Banco de dados não disponível.';
      });
      return;
    }

    final Database db = await widget.database;
    final List<Map<String, dynamic>> usuarios = await db.query(
      'usuarios',
      where: 'nome = ? AND senha = ?',
      whereArgs: [nome, senha],
    );

    if (usuarios.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SucessoPage(
              mensagem: 'Login Efetuado com sucesso!',
              database: widget.database),
        ),
      );
    } else {
      setState(() {
        _mensagemErro = 'Usuário ou senha incorretos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              key: Key('nome_textfield'),
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
            ),
            TextField(
              key: Key('senha_textfield'),
              controller: _senhaController,
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isSenhaVisivel ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSenhaVisivel = !_isSenhaVisivel;
                    });
                  },
                ),
              ),
              obscureText: !_isSenhaVisivel,
            ),
            ElevatedButton(
              key: Key('entrar_button'),
              onPressed: _efetuarLogin,
              child: const Text('Entrar'),
            ),
            Text(
              _mensagemErro,
              key: Key('mensagem_erro'),
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
