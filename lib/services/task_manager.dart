/// Business logic layer for task management operations.
///
/// This file defines the [TaskManager] class, which encapsulates all business
/// rules for creating, updating, deleting, filtering, and sorting tasks.
/// It operates on an in-memory task list and delegates persistence to a
/// [TaskRepository] implementation.
///
/// Also defines [TaskNotFoundException], a custom exception thrown when
/// attempting to operate on a task that does not exist.
library;

import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../models/task_filter.dart';
import '../repositories/task_repository.dart';

/// Exception thrown when a task operation references a non-existent task ID.
///
/// This exception is thrown by [TaskManager] methods that require finding
/// a specific task by ID (such as [TaskManager.updateTask],
/// [TaskManager.toggleCompletion], and [TaskManager.deleteTask]) when the
/// provided ID does not match any task in the current list.
class TaskNotFoundException implements Exception {
  /// The task ID that was not found.
  final String taskId;

  /// Creates a new [TaskNotFoundException] for the given [taskId].
  TaskNotFoundException(this.taskId);

  @override
  String toString() => 'TaskNotFoundException: Task with id "$taskId" not found';
}

/// Encapsulates all business logic for task management.
///
/// [TaskManager] maintains an in-memory list of tasks and coordinates with
/// a [TaskRepository] for persistence. It provides methods for:
/// - Loading tasks from storage
/// - Creating new tasks with validation
/// - Updating existing tasks
/// - Toggling task completion status
/// - Deleting tasks
/// - Filtering and sorting tasks
///
/// All mutating operations automatically persist changes via the repository.
///
/// Example usage:
/// ```dart
/// final repository = LocalTaskRepository();
/// final manager = TaskManager(repository);
///
/// await manager.load();
/// final task = manager.addTask(title: 'Buy groceries');
/// manager.toggleCompletion(task.id);
/// final activeTasks = manager.getFilteredAndSorted(
///   TaskFilter.active,
///   SortOrder.byDueDate,
/// );
/// ```
class TaskManager {
  /// The repository used for persisting tasks.
  final TaskRepository _repository;

  /// The in-memory list of all tasks.
  final List<Task> _tasks = [];

  /// UUID generator for creating unique task IDs.
  final Uuid _uuid = const Uuid();

  /// Creates a new [TaskManager] with the given [repository].
  ///
  /// The [repository] parameter is required and will be used for all
  /// persistence operations (loading and saving tasks).
  TaskManager(this._repository);

  /// Loads all tasks from the repository into memory.
  ///
  /// This method should be called once during application startup to
  /// populate the in-memory task list from persistent storage.
  ///
  /// Clears any existing in-memory tasks before loading. If the repository
  /// returns an empty list (e.g., on first launch or after storage corruption),
  /// the in-memory list will be empty.
  ///
  /// Returns a [Future] that completes when loading is finished.
  Future<void> load() async {
    _tasks.clear();
    final loadedTasks = await _repository.loadAll();
    _tasks.addAll(loadedTasks);
  }

  /// Creates and adds a new task to the list.
  ///
  /// Generates a unique UUID v4 identifier, sets the creation timestamp to
  /// the current UTC time, and applies default values for optional fields.
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
  ///
  /// The new task is automatically persisted via [_repository.saveAll] before
  /// this method returns.
  Future<Task> addTask({
    required String title,
    String? description,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) async {
    // Validate title: must not be empty or whitespace-only
    if (title.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty or whitespace-only');
    }

    // Create the new task with generated ID and current timestamp
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now().toUtc(),
      isCompleted: false,
    );

    // Add to in-memory list and persist
    _tasks.add(task);
    await _repository.saveAll(_tasks);

    return task;
  }

  /// Updates an existing task with new values.
  ///
  /// Finds the task with the given [id] and applies any non-null parameter
  /// values. Fields not provided (null) retain their current values.
  /// Sets the [updatedAt] timestamp to the current UTC time.
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
  ///
  /// The updated task is automatically persisted via [_repository.saveAll]
  /// before this method returns.
  Future<Task> updateTask(
    String id, {
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
  }) async {
    // Find the task by ID
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      throw TaskNotFoundException(id);
    }

    // Validate title if provided
    if (title != null && title.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty or whitespace-only');
    }

    // Apply updates using copyWith
    final updatedTask = _tasks[index].copyWith(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      updatedAt: DateTime.now().toUtc(),
    );

    // Replace in list and persist
    _tasks[index] = updatedTask;
    await _repository.saveAll(_tasks);

    return updatedTask;
  }

  /// Toggles the completion status of a task.
  ///
  /// If the task is currently incomplete, marks it as completed and sets
  /// the [completedAt] timestamp to the current UTC time.
  ///
  /// If the task is currently completed, marks it as incomplete and clears
  /// the [completedAt] timestamp.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the task to toggle (required).
  ///
  /// Returns the updated [Task] instance.
  ///
  /// Throws [TaskNotFoundException] if no task with the given [id] exists.
  ///
  /// The updated task is automatically persisted via [_repository.saveAll]
  /// before this method returns.
  Future<Task> toggleCompletion(String id) async {
    // Find the task by ID
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      throw TaskNotFoundException(id);
    }

    final task = _tasks[index];
    final now = DateTime.now().toUtc();

    // Toggle completion status and set/clear completedAt accordingly
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: task.isCompleted ? null : now,
      updatedAt: now,
    );

    // Replace in list and persist
    _tasks[index] = updatedTask;
    await _repository.saveAll(_tasks);

    return updatedTask;
  }

  /// Deletes a task from the list.
  ///
  /// Removes the task with the given [id] from the in-memory list and
  /// persists the change.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the task to delete (required).
  ///
  /// Throws [TaskNotFoundException] if no task with the given [id] exists.
  ///
  /// The updated task list is automatically persisted via [_repository.saveAll]
  /// before this method returns.
  Future<void> deleteTask(String id) async {
    // Find the task by ID
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      throw TaskNotFoundException(id);
    }

    // Remove from list and persist
    _tasks.removeAt(index);
    await _repository.saveAll(_tasks);
  }

  /// Returns a filtered and sorted view of the task list.
  ///
  /// First applies the [filter] to select which tasks to include, then
  /// sorts the result according to [sortOrder]. All sort orders use
  /// [createdAt] ascending as a secondary sort key to ensure stable,
  /// deterministic ordering.
  ///
  /// Parameters:
  /// - [filter]: Determines which tasks to include based on completion status.
  /// - [sortOrder]: Determines the primary ordering of the result.
  ///
  /// Returns a new [List] containing the filtered and sorted tasks.
  /// The original in-memory list is not modified.
  ///
  /// Filter behavior:
  /// - [TaskFilter.all]: Include all tasks
  /// - [TaskFilter.active]: Include only incomplete tasks (isCompleted == false)
  /// - [TaskFilter.completed]: Include only completed tasks (isCompleted == true)
  ///
  /// Sort order behavior:
  /// - [SortOrder.byCreationDate]: Sort by createdAt descending (newest first),
  ///   then by createdAt ascending for stability
  /// - [SortOrder.byDueDate]: Sort by dueDate ascending (earliest first),
  ///   tasks without due dates go last, then by createdAt ascending
  /// - [SortOrder.byPriority]: Sort by priority descending (High → Medium → Low),
  ///   then by createdAt ascending
  List<Task> getFilteredAndSorted(TaskFilter filter, SortOrder sortOrder) {
    // Apply filter
    List<Task> filtered;
    switch (filter) {
      case TaskFilter.all:
        filtered = List.from(_tasks);
        break;
      case TaskFilter.active:
        filtered = _tasks.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.completed:
        filtered = _tasks.where((task) => task.isCompleted).toList();
        break;
    }

    // Apply sort order
    switch (sortOrder) {
      case SortOrder.byCreationDate:
        // Sort by createdAt descending (newest first)
        // Secondary sort by createdAt ascending for stability (though redundant here)
        filtered.sort((a, b) {
          final comparison = b.createdAt.compareTo(a.createdAt);
          if (comparison != 0) return comparison;
          return a.createdAt.compareTo(b.createdAt); // Stable secondary sort
        });
        break;

      case SortOrder.byDueDate:
        // Sort by dueDate ascending (earliest first)
        // Tasks without due dates go last
        // Secondary sort by createdAt ascending for stability
        filtered.sort((a, b) {
          // Handle null due dates: nulls go last
          if (a.dueDate == null && b.dueDate == null) {
            return a.createdAt.compareTo(b.createdAt);
          }
          if (a.dueDate == null) return 1; // a goes after b
          if (b.dueDate == null) return -1; // a goes before b

          // Both have due dates: compare them
          final comparison = a.dueDate!.compareTo(b.dueDate!);
          if (comparison != 0) return comparison;

          // Same due date: use createdAt as secondary sort
          return a.createdAt.compareTo(b.createdAt);
        });
        break;

      case SortOrder.byPriority:
        // Sort by priority descending (High → Medium → Low)
        // Secondary sort by createdAt ascending for stability
        filtered.sort((a, b) {
          // Priority order: high (2) > medium (1) > low (0)
          final priorityComparison = b.priority.index.compareTo(a.priority.index);
          if (priorityComparison != 0) return priorityComparison;

          // Same priority: use createdAt as secondary sort
          return a.createdAt.compareTo(b.createdAt);
        });
        break;
    }

    return filtered;
  }
}
