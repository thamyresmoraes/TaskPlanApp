import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:taskPlanApp/views/task_list_view.dart';
import '../controllers/task_list_controller.dart';
import '../models/task_list_model.dart';

class TaskListScreen extends StatefulWidget {
  final User user;

  TaskListScreen(this.user);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}


class _TaskListScreenState extends State<TaskListScreen> {
  late TaskListModel _model;
  late TaskListController _controller;
  late TaskListView _view;

  @override
  void initState() {
    super.initState();
    _model = TaskListModel(widget.user);
    _controller = TaskListController(_model, TaskListView(
      model: _model,
      listNameController: TextEditingController(),
      createTaskList: () => _controller.createTaskList(),
      deleteTaskList: (index) => _controller.deleteTaskList(index), 
      logout: () => _view.logout(context),
    ));

    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.view;
  }
}
