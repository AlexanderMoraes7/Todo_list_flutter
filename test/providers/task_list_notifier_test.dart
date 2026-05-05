/// Unit tests for [TaskListNotifier].
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/models/task_filter.dart';
import 'package:todo_list/providers/task_list_notifier.dart';
import 'package:todo_list/services/task_manager.dart';

import '../helpers/in_memory_task_repository.dart';

void main() {
  group('TaskListNotifier', () {
    late InMemoryTaskRepository repository;
    late TaskManager taskManager;
    late TaskListNotifier notifier;

    setUp(() {
      repository = InMemoryTaskRepository();
      taskManager = TaskManager(repository);
      notifier = TaskListNotifier(taskManager);
    });

    test('initial state is correct', () {
      expect(notifier.tasks, isEmpty);
      expect(notifier.activeFilter, TaskFilter.all);
      expect(notifier.activeSortOrder, SortOrder.byCreationDate);
      expect(notifier.isLoading, false);
    });

    test('load sets isLoading correctly', () async {
      expect(notifier.isLoading, false);

      final loadFuture = notifier.load();
      // Note: We can't reliably test isLoading == true here because
      // the operation might complete too quickly in tests

      await loadFuture;
      expect(notifier.isLoading, false);
    });

    test('addTask adds a task and notifies listeners', () async {
      var notified = false;
      notifier.addListener(() {
        notified = true;
      });

      final task = await notifier.addTask(title: 'Test Task');

      expect(task.title, 'Test Task');
      expect(notifier.tasks, hasLength(1));
      expect(notifier.tasks.first.title, 'Test Task');
      expect(notified, true);
    });

    test('addTask with empty title throws ArgumentError', () async {
      expect(
        () => notifier.addTask(title: ''),
        throwsArgumentError,
      );
      expect(
        () => notifier.addTask(title: '   '),
        throwsArgumentError,
      );
    });

    test('updateTask updates a task and notifies listeners', () async {
      final task = await notifier.addTask(title: 'Original Title');
      var notified = false;
      notifier.addListener(() {
        notified = true;
      });

      final updated = await notifier.updateTask(
        task.id,
        title: 'Updated Title',
      );

      expect(updated.title, 'Updated Title');
      expect(notifier.tasks.first.title, 'Updated Title');
      expect(notified, true);
    });

    test('toggleCompletion toggles task completion and notifies listeners',
        () async {
      final task = await notifier.addTask(title: 'Test Task');
      expect(task.isCompleted, false);

      var notified = false;
      notifier.addListener(() {
        notified = true;
      });

      final toggled = await notifier.toggleCompletion(task.id);

      expect(toggled.isCompleted, true);
      expect(notifier.tasks.first.isCompleted, true);
      expect(notified, true);
    });

    test('deleteTask removes a task and notifies listeners', () async {
      final task = await notifier.addTask(title: 'Test Task');
      expect(notifier.tasks, hasLength(1));

      var notified = false;
      notifier.addListener(() {
        notified = true;
      });

      await notifier.deleteTask(task.id);

      expect(notifier.tasks, isEmpty);
      expect(notified, true);
    });

    test('setFilter changes filter and notifies listeners', () {
      var notified = false;
      notifier.addListener(() {
        notified = true;
      });

      notifier.setFilter(TaskFilter.active);

      expect(notifier.activeFilter, TaskFilter.active);
      expect(notified, true);
    });

    test('setFilter with same filter does not notify listeners', () {
      var notifyCount = 0;
      notifier.addListener(() {
        notifyCount++;
      });

      notifier.setFilter(TaskFilter.all); // Same as initial

      expect(notifyCount, 0);
    });

    test('setSortOrder changes sort order and notifies listeners', () {
      var notified = false;
      notifier.addListener(() {
        notified = true;
      });

      notifier.setSortOrder(SortOrder.byPriority);

      expect(notifier.activeSortOrder, SortOrder.byPriority);
      expect(notified, true);
    });

    test('setSortOrder with same order does not notify listeners', () {
      var notifyCount = 0;
      notifier.addListener(() {
        notifyCount++;
      });

      notifier.setSortOrder(SortOrder.byCreationDate); // Same as initial

      expect(notifyCount, 0);
    });

    test('tasks getter returns filtered and sorted tasks', () async {
      // Add some tasks
      await notifier.addTask(title: 'Task 1', priority: Priority.high);
      await notifier.addTask(title: 'Task 2', priority: Priority.low);
      final task3 = await notifier.addTask(title: 'Task 3', priority: Priority.medium);
      await notifier.toggleCompletion(task3.id);

      // Test filter
      notifier.setFilter(TaskFilter.active);
      expect(notifier.tasks, hasLength(2));

      notifier.setFilter(TaskFilter.completed);
      expect(notifier.tasks, hasLength(1));

      notifier.setFilter(TaskFilter.all);
      expect(notifier.tasks, hasLength(3));

      // Test sort order
      notifier.setSortOrder(SortOrder.byPriority);
      final sortedTasks = notifier.tasks;
      expect(sortedTasks[0].priority, Priority.high);
      expect(sortedTasks[1].priority, Priority.medium);
      expect(sortedTasks[2].priority, Priority.low);
    });
  });
}
