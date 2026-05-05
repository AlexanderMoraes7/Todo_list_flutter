/// Main task list screen for the Todo List application.
///
/// This file defines [TaskListScreen], the primary screen that displays
/// all tasks with filtering, sorting, and management capabilities.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_filter.dart';
import '../../providers/task_list_notifier.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_bar.dart';
import '../widgets/sort_menu.dart';
import '../widgets/task_tile.dart';
import 'task_form_screen.dart';

/// The main screen displaying the filtered and sorted task list.
///
/// [TaskListScreen] is the primary UI of the Todo List application. It:
/// - Displays a loading indicator during initial data load
/// - Renders filter chips (All/Active/Completed) and a sort menu
/// - Shows a scrollable list of tasks using [TaskTile] widgets
/// - Displays contextual empty state messages when no tasks match the filter
/// - Provides a floating action button for creating new tasks
/// - Handles navigation to the task form screen for creation and editing
/// - Shows error snackbars when operations fail
///
/// The screen consumes [TaskListNotifier] to observe task list state and
/// automatically rebuilds when the state changes (tasks added, updated,
/// deleted, or filter/sort changed).
///
/// Example usage:
/// ```dart
/// MaterialApp(
///   home: TaskListScreen(),
/// )
/// ```
class TaskListScreen extends StatelessWidget {
  /// Creates a [TaskListScreen] widget.
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TaskListNotifier>();
    final tasks = notifier.tasks;
    final isLoading = notifier.isLoading;
    final activeFilter = notifier.activeFilter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          // Sort menu button
          SortMenu(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: FilterBar(),
        ),
      ),
      body: _buildBody(
        context: context,
        isLoading: isLoading,
        tasks: tasks,
        activeFilter: activeFilter,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTask(context),
        tooltip: 'Create new task',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the main body content based on loading and task list state.
  ///
  /// Shows a loading indicator while [isLoading] is true, an empty state
  /// widget when the task list is empty, or a scrollable list of tasks.
  Widget _buildBody({
    required BuildContext context,
    required bool isLoading,
    required List<dynamic> tasks,
    required TaskFilter activeFilter,
  }) {
    // Show loading indicator during initial load
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show empty state when no tasks match the current filter
    if (tasks.isEmpty) {
      return EmptyStateWidget(
        message: _getEmptyStateMessage(activeFilter),
      );
    }

    // Show task list
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          task: task,
          onEdit: () => _navigateToEditTask(context, task),
        );
      },
    );
  }

  /// Returns a contextual empty state message based on the active filter.
  ///
  /// Provides user-friendly messages that explain why the list is empty
  /// and what the user can do next.
  String _getEmptyStateMessage(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'No tasks yet. Tap + to create your first task!';
      case TaskFilter.active:
        return 'No active tasks. Time to relax!';
      case TaskFilter.completed:
        return 'No completed tasks yet. Start checking off your to-dos!';
    }
  }

  /// Navigates to the task form screen in create mode.
  ///
  /// Opens [TaskFormScreen] without a task parameter, allowing the user
  /// to create a new task. The screen is pushed onto the navigation stack
  /// and will pop when the user saves or cancels.
  Future<void> _navigateToCreateTask(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskFormScreen(),
      ),
    );
  }

  /// Navigates to the task form screen in edit mode.
  ///
  /// Opens [TaskFormScreen] with the given [task], allowing the user to
  /// edit its details. The screen is pushed onto the navigation stack and
  /// will pop when the user saves or cancels.
  Future<void> _navigateToEditTask(BuildContext context, dynamic task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );
  }
}
