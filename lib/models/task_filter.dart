/// Enums for filtering and sorting tasks in the Todo List application.
///
/// This file defines the [TaskFilter] and [SortOrder] enums used throughout
/// the app to control which tasks are displayed and in what order.
library;

/// Controls which tasks are visible in the task list.
///
/// The filter determines which subset of tasks should be displayed to the user
/// based on their completion status.
enum TaskFilter {
  /// Display all tasks regardless of completion status.
  all,

  /// Display only tasks that are not yet completed (isCompleted == false).
  active,

  /// Display only tasks that have been completed (isCompleted == true).
  completed,
}

/// Determines the ordering of the task list.
///
/// The sort order controls how tasks are arranged when displayed to the user.
/// All sort orders use creation date as a secondary sort key to ensure stable,
/// deterministic ordering.
enum SortOrder {
  /// Sort tasks by creation date in descending order (newest first).
  ///
  /// The most recently created tasks appear at the top of the list.
  byCreationDate,

  /// Sort tasks by due date in ascending order (earliest first).
  ///
  /// Tasks with earlier due dates appear at the top. Tasks without a due date
  /// are placed at the end of the list.
  byDueDate,

  /// Sort tasks by priority in descending order (High → Medium → Low).
  ///
  /// High-priority tasks appear at the top, followed by medium-priority tasks,
  /// then low-priority tasks.
  byPriority,
}
