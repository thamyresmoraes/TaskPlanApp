import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '/screens/login_page.dart';

class SucessoPage extends StatefulWidget {
  final String mensagem;
  final Future<Database> database;

  const SucessoPage({required this.mensagem, required this.database});

  @override
  _SucessoPageState createState() => _SucessoPageState();
}

class _SucessoPageState extends State<SucessoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem Vindo(a)!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? child) {
                return Opacity(
                  opacity: _animation.value,
                  child: Text(
                    widget.mensagem,
                    style: TextStyle(fontSize: 20),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
