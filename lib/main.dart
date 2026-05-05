/// Entry point for the Flutter Todo List application.
///
/// This file sets up the application's dependency injection and state management
/// using the Provider package. It creates the core service instances
/// ([LocalTaskRepository], [TaskManager], [TaskListNotifier]) and exposes them
/// to the widget tree via [ChangeNotifierProvider].
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_list_notifier.dart';
import 'repositories/local_task_repository.dart';
import 'services/task_manager.dart';
import 'ui/screens/task_list_screen.dart';

/// Application entry point.
///
/// Creates the core service instances and runs the app with Provider setup.
void main() {
  // Create the repository layer (local file-based storage)
  final repository = LocalTaskRepository();

  // Create the business logic layer (task manager)
  final taskManager = TaskManager(repository);

  // Create the state management layer (notifier for UI)
  final taskListNotifier = TaskListNotifier(taskManager);

  runApp(TodoApp(taskListNotifier: taskListNotifier));
}

/// Root widget of the Todo List application.
///
/// Sets up the [ChangeNotifierProvider] to expose [TaskListNotifier] to the
/// entire widget tree, enabling any descendant widget to access and observe
/// task state changes.
class TodoApp extends StatelessWidget {
  /// The task list notifier that manages application state.
  final TaskListNotifier taskListNotifier;

  /// Creates a [TodoApp] with the given [taskListNotifier].
  const TodoApp({super.key, required this.taskListNotifier});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: taskListNotifier,
      child: MaterialApp(
        title: 'Todo List',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const TodoAppHome(),
      ),
    );
  }
}

/// Home screen wrapper that loads tasks on startup.
///
/// This widget calls [TaskListNotifier.load] during initialization to populate
/// the task list from persistent storage. It displays a loading indicator while
/// tasks are being loaded, then shows the main application content.
class TodoAppHome extends StatefulWidget {
  /// Creates a [TodoAppHome].
  const TodoAppHome({super.key});

  @override
  State<TodoAppHome> createState() => _TodoAppHomeState();
}

class _TodoAppHomeState extends State<TodoAppHome> {
  @override
  void initState() {
    super.initState();
    // Load tasks from storage on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskListNotifier>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return the main task list screen
    return const TaskListScreen();
  }
}
