// screens/cadastro_page.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '/screens/sucesso_page.dart';

class CadastroPage extends StatefulWidget {
  final Future<Database> database;

  const CadastroPage({super.key, required this.database});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isCadastroEnabled = false;

  void _verificarCadastro() {
    final nome = _nomeController.text;
    final senha = _senhaController.text;

    setState(() {
      _isCadastroEnabled = nome.isNotEmpty && senha.isNotEmpty;
    });
  }

  Future<void> _efetuarCadastro(BuildContext context) async {
    final nome = _nomeController.text;
    final senha = _senhaController.text;

    final Database db = await widget.database;
    await db.insert(
      'usuarios',
      {'nome': nome, 'senha': senha},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SucessoPage(
            mensagem: 'Cadastrado com sucesso!', database: widget.database),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
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
              onChanged: (_) => _verificarCadastro(),
            ),
            TextField(
              key: Key('senha_textfield'),
              controller: _senhaController,
              decoration: const InputDecoration(
                labelText: 'Senha',
              ),
              obscureText: true,
              onChanged: (_) => _verificarCadastro(),
            ),
            ElevatedButton(
              key: Key('cadastrar_button'),
              onPressed:
                  _isCadastroEnabled ? () => _efetuarCadastro(context) : null,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
