// Basic smoke test for the Todo List application.
//
// This test verifies that the app can be instantiated and the Provider setup
// works correctly. Comprehensive widget tests will be added in Task 11.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/providers/task_list_notifier.dart';
import 'package:todo_list/repositories/local_task_repository.dart';
import 'package:todo_list/services/task_manager.dart';

void main() {
  testWidgets('App smoke test - Provider setup', (WidgetTester tester) async {
    // Create the service instances
    final repository = LocalTaskRepository();
    final taskManager = TaskManager(repository);
    final taskListNotifier = TaskListNotifier(taskManager);

    // Build our app and trigger a frame
    await tester.pumpWidget(TodoApp(taskListNotifier: taskListNotifier));

    // Pump a few frames to allow initialization
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the app title is present in the AppBar
    expect(find.text('Todo List'), findsOneWidget);

    // Verify that the FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
