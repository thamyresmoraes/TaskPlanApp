// task_list_controller.dart

import 'package:taskPlanApp/models/task_list_model.dart';
import '../views/task_list_view.dart';

class TaskListController {
  final TaskListModel model;
  final TaskListView view;

  TaskListController(this.model, this.view);

  Future<void> init() async {
    await model.loadTaskLists();
    
  }

  void createTaskList() {
    model.taskLists.add(view.listNameController.text);
    model.saveTaskLists();
    view.clearListName();
  }

  void deleteTaskList(int index) {
    model.taskLists.removeAt(index);
    model.saveTaskLists();
  }

  
  
  

}
