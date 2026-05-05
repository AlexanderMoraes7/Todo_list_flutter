/// State management layer for the task list UI.
///
/// This file defines [TaskListNotifier], a [ChangeNotifier] that bridges
/// the [TaskManager] business logic layer and the Flutter widget tree.
/// It exposes observable state (tasks, filter, sort order, loading status)
/// and provides methods for all task operations that automatically notify
/// listeners when state changes.
library;

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../models/task_filter.dart';
import '../services/task_manager.dart';

/// ChangeNotifier that bridges [TaskManager] and the Flutter widget tree.
///
/// [TaskListNotifier] maintains the current UI state (active filter, sort order,
/// loading status) and exposes the filtered/sorted task list. It delegates all
/// business logic to [TaskManager] and handles error cases gracefully.
///
/// All mutating operations automatically call [notifyListeners] to trigger
/// UI updates. Exceptions from [TaskManager] (such as [TaskNotFoundException])
/// and storage errors are caught and can be surfaced to the UI via error
/// callbacks or snackbars.
///
/// Example usage:
/// ```dart
/// // In main.dart or app setup:
/// final repository = LocalTaskRepository();
/// final manager = TaskManager(repository);
/// final notifier = TaskListNotifier(manager);
///
/// // In a widget:
/// final notifier = context.watch<TaskListNotifier>();
/// final tasks = notifier.tasks;
/// ```
class TaskListNotifier extends ChangeNotifier {
  /// The task manager that handles business logic and persistence.
  final TaskManager _taskManager;

  /// The currently active filter determining which tasks are visible.
  TaskFilter _activeFilter = TaskFilter.all;

  /// The currently active sort order determining task arrangement.
  SortOrder _activeSortOrder = SortOrder.byCreationDate;

  /// Whether a load operation is currently in progress.
  bool _isLoading = false;

  /// Creates a new [TaskListNotifier] with the given [taskManager].
  ///
  /// The [taskManager] parameter is required and will be used for all
  /// task operations and persistence.
  TaskListNotifier(this._taskManager);

  /// Returns the current filtered and sorted list of tasks.
  ///
  /// This list is computed on-demand from [TaskManager] using the current
  /// [activeFilter] and [activeSortOrder]. The returned list is a new
  /// instance and modifications to it will not affect the underlying data.
  List<Task> get tasks {
    return _taskManager.getFilteredAndSorted(_activeFilter, _activeSortOrder);
  }

  /// Returns the currently active filter.
  ///
  /// This determines which tasks are visible in the UI based on their
  /// completion status.
  TaskFilter get activeFilter => _activeFilter;

  /// Returns the currently active sort order.
  ///
  /// This determines how tasks are arranged in the UI.
  SortOrder get activeSortOrder => _activeSortOrder;

  /// Returns whether a load operation is currently in progress.
  ///
  /// The UI can use this to display a loading indicator during initial
  /// data load.
  bool get isLoading => _isLoading;

  /// Loads all tasks from storage into memory.
  ///
  /// This method should be called once during application startup to
  /// populate the task list from persistent storage. Sets [isLoading]
  /// to true during the operation and false when complete.
  ///
  /// Notifies listeners when loading starts and when it completes
  /// (successfully or with an error).
  ///
  /// If loading fails due to storage errors, the error is caught and
  /// logged, but not rethrown. The task list will be empty and the UI
  /// will display the empty state.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _taskManager.load();
    } catch (e) {
      // Log the error but don't rethrow - let the UI handle empty state
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates and adds a new task to the list.
  ///
  /// Delegates to [TaskManager.addTask] with the provided parameters.
  /// Automatically notifies listeners after the task is created and persisted.
  ///
  /// Parameters:
  /// - [title]: The task title (required). Must not be empty or whitespace-only.
  /// - [description]: Optional longer description of the task.
  /// - [priority]: The urgency level. Defaults to [Priority.medium] if not specified.
  /// - [dueDate]: Optional deadline for the task.
  ///
  /// Returns the newly created [Task] instance.
  ///
  /// Throws [ArgumentError] if [title] is empty or contains only whitespace.
  /// Storage exceptions are caught, logged, and rethrown so the UI can
  /// display an error message.
  Future<Task> addTask({
    required String title,
    String? description,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) async {
    try {
      final task = await _taskManager.addTask(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      notifyListeners();
      return task;
    } catch (e) {
      // Log and rethrow so UI can show error
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  /// Updates an existing task with new values.
  ///
  /// Delegates to [TaskManager.updateTask] with the provided parameters.
  /// Automatically notifies listeners after the task is updated and persisted.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the task to update (required).
  /// - [title]: New title for the task (optional).
  /// - [description]: New description for the task (optional).
  /// - [priority]: New priority level (optional).
  /// - [dueDate]: New due date (optional).
  ///
  /// Returns the updated [Task] instance.
  ///
  /// Throws [TaskNotFoundException] if no task with the given [id] exists.
  /// Throws [ArgumentError] if [title] is provided but is empty or whitespace-only.
  /// Storage exceptions are caught, logged, and rethrown so the UI can
  /// display an error message.
  Future<Task> updateTask(
    String id, {
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
  }) async {
    try {
      final task = await _taskManager.updateTask(
        id,
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      notifyListeners();
      return task;
    } on TaskNotFoundException {
      // Log and rethrow so UI can show error
      debugPrint('Task not found: $id');
      rethrow;
    } catch (e) {
      // Log and rethrow storage exceptions
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  /// Toggles the completion status of a task.
  ///
  /// Delegates to [TaskManager.toggleCompletion]. If the task is currently
  /// incomplete, marks it as completed. If the task is currently completed,
  /// marks it as incomplete.
  ///
  /// Automatically notifies listeners after the task is updated and persisted.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the task to toggle (required).
  ///
  /// Returns the updated [Task] instance.
  ///
  /// Throws [TaskNotFoundException] if no task with the given [id] exists.
  /// Storage exceptions are caught, logged, and rethrown so the UI can
  /// display an error message.
  Future<Task> toggleCompletion(String id) async {
    try {
      final task = await _taskManager.toggleCompletion(id);
      notifyListeners();
      return task;
    } on TaskNotFoundException {
      // Log and rethrow so UI can show error
      debugPrint('Task not found: $id');
      rethrow;
    } catch (e) {
      // Log and rethrow storage exceptions
      debugPrint('Error toggling task completion: $e');
      rethrow;
    }
  }

  /// Deletes a task from the list.
  ///
  /// Delegates to [TaskManager.deleteTask]. Removes the task with the given
  /// [id] from the list and persists the change.
  ///
  /// Automatically notifies listeners after the task is deleted and the
  /// change is persisted.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the task to delete (required).
  ///
  /// Throws [TaskNotFoundException] if no task with the given [id] exists.
  /// Storage exceptions are caught, logged, and rethrown so the UI can
  /// display an error message.
  Future<void> deleteTask(String id) async {
    try {
      await _taskManager.deleteTask(id);
      notifyListeners();
    } on TaskNotFoundException {
      // Log and rethrow so UI can show error
      debugPrint('Task not found: $id');
      rethrow;
    } catch (e) {
      // Log and rethrow storage exceptions
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  /// Sets the active filter and updates the visible task list.
  ///
  /// Changes which tasks are displayed based on their completion status.
  /// Automatically notifies listeners to trigger a UI update.
  ///
  /// Parameters:
  /// - [filter]: The new filter to apply (all, active, or completed).
  void setFilter(TaskFilter filter) {
    if (_activeFilter != filter) {
      _activeFilter = filter;
      notifyListeners();
    }
  }

  /// Sets the active sort order and updates the task list arrangement.
  ///
  /// Changes how tasks are ordered in the UI. Automatically notifies
  /// listeners to trigger a UI update.
  ///
  /// Parameters:
  /// - [sortOrder]: The new sort order to apply (by creation date, due date, or priority).
  void setSortOrder(SortOrder sortOrder) {
    if (_activeSortOrder != sortOrder) {
      _activeSortOrder = sortOrder;
      notifyListeners();
    }
  }
}
