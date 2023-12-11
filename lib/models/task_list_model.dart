import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskListModel {
  final User user;
  List<String> taskLists = [];

  TaskListModel(this.user);

  Future<void> loadTaskLists() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snapshot.data();

    if (data != null) {
      taskLists = List<String>.from(data['taskLists'] ?? []);
    }
  }

  Future<void> saveTaskLists() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'taskLists': taskLists,
    });
  }
}
