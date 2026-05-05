/// Widget for displaying a single task in the task list.
///
/// This file defines [TaskTile], a [ListTile]-based widget that renders
/// a task's title, priority indicator, due date, completion checkbox, and
/// provides access to edit and delete actions via a popup menu.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/task_list_notifier.dart';

/// A list tile widget that displays a single task with all its details.
///
/// [TaskTile] renders:
/// - A colored left border or dot indicating the task's priority level
/// - The task title (with strikethrough if completed)
/// - The due date (if present)
/// - A checkbox for toggling completion status
/// - A popup menu (via long-press or trailing icon) with Edit and Delete actions
///
/// Completed tasks are displayed with muted colors and strikethrough text.
/// The delete action shows a confirmation dialog before proceeding.
///
/// Example usage:
/// ```dart
/// ListView.builder(
///   itemCount: tasks.length,
///   itemBuilder: (context, index) {
///     return TaskTile(
///       task: tasks[index],
///       onEdit: () => _navigateToEditScreen(tasks[index]),
///     );
///   },
/// )
/// ```
class TaskTile extends StatelessWidget {
  /// The task to display.
  final Task task;

  /// Callback invoked when the user selects the Edit action.
  ///
  /// This should typically navigate to the task form screen in edit mode.
  final VoidCallback onEdit;

  /// Creates a [TaskTile] widget.
  ///
  /// Both [task] and [onEdit] are required parameters.
  const TaskTile({
    super.key,
    required this.task,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = context.read<TaskListNotifier>();

    // Determine text style based on completion status
    final titleStyle = task.isCompleted
        ? theme.textTheme.bodyLarge?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          )
        : theme.textTheme.bodyLarge;

    final subtitleStyle = task.isCompleted
        ? theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          )
        : theme.textTheme.bodySmall;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: task.priority.color,
            width: 4.0,
          ),
        ),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => _toggleCompletion(context, notifier),
        ),
        title: Text(
          task.title,
          style: titleStyle,
        ),
        subtitle: task.dueDate != null
            ? Text(
                _formatDueDate(task.dueDate!),
                style: subtitleStyle,
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showPopupMenu(context, notifier),
        ),
        onLongPress: () => _showPopupMenu(context, notifier),
      ),
    );
  }

  /// Toggles the completion status of the task.
  ///
  /// Calls [TaskListNotifier.toggleCompletion] and shows a snackbar if
  /// an error occurs.
  Future<void> _toggleCompletion(
    BuildContext context,
    TaskListNotifier notifier,
  ) async {
    try {
      await notifier.toggleCompletion(task.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Shows a popup menu with Edit and Delete actions.
  ///
  /// The menu is displayed at the location of the trailing icon or where
  /// the user long-pressed.
  Future<void> _showPopupMenu(
      BuildContext context, TaskListNotifier notifier) async {
    final value = await showMenu<String>(
      context: context,
      position: _getMenuPosition(context),
      items: [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );

    if (!context.mounted) return;

    if (value == 'edit') {
      onEdit();
    } else if (value == 'delete') {
      _showDeleteConfirmation(context, notifier);
    }
  }

  /// Calculates the position for the popup menu.
  ///
  /// Positions the menu near the top-right of the screen, where the
  /// trailing icon is typically located.
  RelativeRect _getMenuPosition(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(
      button.size.topRight(Offset.zero),
      ancestor: overlay,
    );

    return RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx,
      position.dy,
    );
  }

  /// Shows a confirmation dialog before deleting the task.
  ///
  /// If the user confirms, calls [TaskListNotifier.deleteTask] and shows
  /// a snackbar on success or error.
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    TaskListNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await notifier.deleteTask(task.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete task: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Formats a due date for display in the subtitle.
  ///
  /// Returns a human-readable string representation of the date.
  /// For example: "Due: Jan 15, 2025"
  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final localDate = dueDate.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(localDate.year, localDate.month, localDate.day);

    if (dateOnly == today) {
      return 'Due: Today';
    } else if (dateOnly == tomorrow) {
      return 'Due: Tomorrow';
    } else {
      // Format as "Due: Jan 15, 2025"
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return 'Due: ${months[localDate.month - 1]} ${localDate.day}, ${localDate.year}';
    }
  }
}
