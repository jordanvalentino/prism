import 'dart:async';

import 'package:kilat/app/models/Task.dart';
import 'package:kilat/app/models/Tasks.dart';
import 'package:kilat/app/networks/task_provider.dart';

class TaskRepository {
  final TaskProvider taskProvider;

  TaskRepository(this.taskProvider);

  Future<List<Task>> fetchAll(int accountId) {
    return taskProvider.fetchAll(accountId);
  }

  Future<int> add(Task task) {
    return taskProvider.add(task);
  }

  Future<bool> edit(Task task) {
    return taskProvider.edit(task);
  }

  Future<bool> delete(int id) {
    return taskProvider.delete(id);
  }
}
