import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databasePath = await getDatabasesPath();
  final database = await openDatabase(
    Path.join(databasePath!, 'app_database.db'),
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
      home: Builder(
        builder: (context) => HomePage(database: database),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Future<Database> database;

  const HomePage({required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App de Cadastro'),
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

class CadastroPage extends StatefulWidget {
  final Future<Database> database;

  const CadastroPage({required this.database});

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

class SucessoPage extends StatelessWidget {
  final String mensagem;
  final Future<Database> database;

  const SucessoPage({required this.mensagem, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sucesso'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(mensagem),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(database: database),
                ),
              );
            },
            child: const Text('Efetuar Login'),
          ),
        ],
      ),
    );
  }
}

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
