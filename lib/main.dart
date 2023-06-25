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
    return MaterialApp(
      title: 'Task Plan App',
      theme: ThemeData(
        primaryColor: Colors.white,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF79BF83)),
      ),
      home: LoginPage(),
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
      Navigator.push(
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
            Image.asset('assets/check_icon.png', width: 100, height: 100),
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
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TaskListScreen(userCredential.user!)),
      );
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
  final List<String> _taskLists = [];

  @override
  void initState() {
    super.initState();
    _loadTaskLists();
  }

  void _loadTaskLists() async {
    final taskListDocs = await FirebaseFirestore.instance
        .collection('taskLists')
        .doc(widget.user.uid)
        .collection('lists')
        .get();

    setState(() {
      _taskLists
          .addAll(taskListDocs.docs.map((doc) => doc.data()['name'] as String));
    });
  }

  void _createTaskList() async {
    final listName = _listNameController.text;

    if (listName.isNotEmpty) {
      // Create a new task list
      await FirebaseFirestore.instance
          .collection('taskLists')
          .doc(widget.user.uid)
          .collection('lists')
          .add({'name': listName});

      // Clear the text field
      _listNameController.clear();

      // Update the task list state
      setState(() {
        _taskLists.add(listName);
      });
    }
  }

  void _deleteTaskList(int index) async {
    final taskListName = _taskLists[index];

    // Delete the task list from Firestore
    await FirebaseFirestore.instance
        .collection('taskLists')
        .doc(widget.user.uid)
        .collection('lists')
        .where('name', isEqualTo: taskListName)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    // Update the task list state
    setState(() {
      _taskLists.removeAt(index);
    });

    // Return to the task list screen
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Lists')),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsScreen(
                          widget.user,
                          taskListName,
                          onDelete: () => _deleteTaskList(index),
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
  final VoidCallback? onDelete;

  TaskDetailsScreen(this.user, this.taskListName, {this.onDelete});

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  final List<String> _tasks = [];

  void _createTask() {
    final taskName = _taskNameController.text;

    if (taskName.isNotEmpty) {
      setState(() {
        _tasks.add(taskName);
        _taskNameController.clear();
      });
    }
  }

  void _toggleTaskComplete(int index) {
    setState(() {
      _tasks[index] = _tasks[index].startsWith('✅')
          ? _tasks[index].substring(2)
          : '✅ ${_tasks[index]}';
    });
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskListName),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Delete Task List'),
                    content:
                        Text('Are you sure you want to delete this task list?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () {
                          // Delete the task list
                          widget.onDelete?.call();

                          // Navigate back to the task list screen
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
