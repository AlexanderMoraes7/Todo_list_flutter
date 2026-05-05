/// In-memory implementation of [TaskRepository] for testing.
///
/// This implementation stores tasks in memory without any file I/O,
/// making tests fast and deterministic.
library;

import 'package:todo_list/models/task.dart';
import 'package:todo_list/repositories/task_repository.dart';

/// In-memory task repository for testing purposes.
///
/// Stores tasks in a simple list without any persistence. Useful for
/// unit tests and widget tests that need to avoid file I/O.
class InMemoryTaskRepository implements TaskRepository {
  /// The in-memory storage for tasks.
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> loadAll() async {
    return List.from(_tasks);
  }

  @override
  Future<void> saveAll(List<Task> tasks) async {
    _tasks.clear();
    _tasks.addAll(tasks);
  }
}
