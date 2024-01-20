import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TaskPlanApp());
}

class TaskPlanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(Theme.of(context)); // Adicione esta linha

    return MaterialApp(
      title: 'Task Plan App',
      theme: ThemeData(),
      home: LoginPage(),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;

  CustomAppBar({required this.onLogout});

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Task Plan App'),
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: onLogout,
        ),
      ],
    );
  }
}

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Login successful, navigate to task list screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TaskListScreen(userCredential.user!)),
      );
    } catch (e) {
      // Login failed, show friendly error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid email or password.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Plan App')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('lib/assets/check_icon.png', width: 100, height: 100),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to registration page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedGender = 'Female'; // Set an initial value for the dropdown

  void showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _register(BuildContext context) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Set additional user information (name and gender) in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text,
        'gender': _selectedGender,
      });

      // Registration successful, navigate to task list screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TaskListScreen(userCredential.user!)),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Senha Fraca');
        showAlertDialog(
          context,
          'Senha fraca!',
          'Por favor, insira no mínimo 6 caracteres',
        );
      } else if (e.code == 'email-already-in-use') {
        print('E-mail já cadastrado');
        showAlertDialog(
          context,
          'Email já cadastrado',
          'Por favor, faça o seu login!',
        );
      }
    } catch (e) {
      // Registration failed, show friendly error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Registration Failed'),
            content: Text('Failed to create an account. Please try again.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registration')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            DropdownButtonFormField(
              value: _selectedGender,
              items: ['Female', 'Male', 'Other'].map((String gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value as String;
                });
              },
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            ElevatedButton(
              onPressed: () => _register(context),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  final User user;

  TaskListScreen(this.user);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _listNameController = TextEditingController();
  List<String> _taskLists = [];

  @override
  void initState() {
    super.initState();
    _loadTaskLists();
  }

  void _loadTaskLists() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();
    final data = snapshot.data();

    if (data != null) {
      // Load the user-specific task lists from Firestore
      setState(() {
        _taskLists = List<String>.from(data['taskLists'] ?? []);
      });
    }
  }

  void _saveTaskLists() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({
      'taskLists': _taskLists,
    });
  }

  void _createTaskList() async {
    final listName = _listNameController.text;

    if (listName.isNotEmpty) {
      setState(() {
        _taskLists.add(listName);
        _listNameController.clear();
        _saveTaskLists();
      });
    }
  }

  void _deleteTaskList(int index) async {
    setState(() {
      _taskLists.removeAt(index);
      _saveTaskLists();
    });
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate to the home page after successful logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TaskPlanApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onLogout: () => _logout(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _listNameController,
                    decoration: InputDecoration(labelText: 'List Name'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _createTaskList,
                  child: Text('Create List'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _taskLists.length,
              itemBuilder: (context, index) {
                final taskListName = _taskLists[index];

                return ListTile(
                  title: Text(taskListName),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTaskList(index),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsScreen(
                          widget.user,
                          taskListName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailsScreen extends StatefulWidget {
  final User user;
  final String taskListName;

  TaskDetailsScreen(this.user, this.taskListName);

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  List<String> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();
    final data = snapshot.data();

    if (data != null) {
      // Load the user-specific tasks from Firestore
      setState(() {
        _tasks =
            List<String>.from(data['taskLists_${widget.taskListName}'] ?? []);
      });
    }
  }

  void _saveTasks() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({
      'taskLists_${widget.taskListName}': _tasks,
    });
  }

  void _createTask() {
    final taskName = _taskNameController.text;

    if (taskName.isNotEmpty) {
      setState(() {
        _tasks.add(taskName);
        _taskNameController.clear();
        _saveTasks();
      });
    }
  }

  void _toggleTaskComplete(int index) {
    setState(() {
      _tasks[index] = _tasks[index].startsWith('✅')
          ? _tasks[index].substring(2)
          : '✅ ${_tasks[index]}';
      _saveTasks();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate to the home page after successful logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TaskPlanApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onLogout: () => _logout(context),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            ElevatedButton(
              onPressed: _createTask,
              child: Text('Add Task'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final taskName = _tasks[index];

                  return ListTile(
                    title: Text(taskName),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteTask(index),
                    ),
                    onTap: () => _toggleTaskComplete(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
