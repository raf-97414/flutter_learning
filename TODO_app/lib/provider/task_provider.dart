import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  // FIX: These were swapped!
  List<Task> get activeTasks =>
      _tasks.where((task) => !task.completed).toList();

  List<Task> get completedTasks =>
      _tasks.where((task) => task.completed).toList();

  void addTasks(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTaskCompletion(int id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.completed = !task.completed;
    notifyListeners();
  }

  void removeTasks(int id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Task? getTaskById(int id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // FIX: Wrong condition check
  void updateTasks(int id, Task updateTask) {
    int index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      // Was checking == -1 which is wrong!
      _tasks[index] = updateTask;
      notifyListeners();
    }
  }

  void updateTaskFields(
    int id, {
    String? title,
    String? description,
    DateTime? dueDate,
    bool? completed,
  }) {
    try {
      final task = _tasks.firstWhere((t) => t.id == id);
      if (title != null) task.title = title;
      if (description != null) task.description = description;
      if (dueDate != null) task.dueDate = dueDate;
      if (completed != null) task.completed = completed;
      notifyListeners();
    } catch (e) {
      debugPrint('Task not found: $id');
    }
  }

  void clearAllTasks() {
    _tasks.clear();
    notifyListeners();
  }

  void clearCompletedTasks() {
    _tasks.removeWhere((t) => t.completed);
    notifyListeners();
  }
}
