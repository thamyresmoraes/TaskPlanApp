// task_list_view.dart

import 'package:flutter/material.dart';
import '../models/task_list_model.dart';

class TaskListView extends StatelessWidget {
  final TaskListModel model;
  final TextEditingController listNameController;
  final Function createTaskList;
  final Function(int) deleteTaskList;

  TaskListView({
    required this.model,
    required this.listNameController,
    required this.createTaskList,
    required this.deleteTaskList,
  });

  void clearListName() {
    listNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task List App')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: listNameController,
                    decoration: InputDecoration(labelText: 'Insira o nome da lista'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => createTaskList(),
                  child: Text('Criar Lista'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: model.taskLists.length,
              itemBuilder: (context, index) {
                final taskListName = model.taskLists[index];

                return ListTile(
                  title: Text(taskListName),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteTaskList(index),
                  ),
                  onTap: () {
                    // Aqui você pode chamar um método no Controller se necessário
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
