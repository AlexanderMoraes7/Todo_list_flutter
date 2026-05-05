/// A widget that displays an empty state message when the task list is empty.
///
/// This widget shows a centered icon and text to provide feedback to the user
/// when there are no tasks to display. The message can be customized based on
/// the current filter context (all, active, or completed tasks).
library;

import 'package:flutter/material.dart';

/// Displays a centered empty state with an icon and message.
///
/// Used in [TaskListScreen] to provide contextual feedback when the filtered
/// task list contains no items. The message should be tailored to the active
/// filter to help users understand why the list is empty.
///
/// Example usage:
/// ```dart
/// EmptyStateWidget(
///   message: 'No active tasks. Time to relax!',
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// Creates an empty state widget.
  ///
  /// The [message] parameter is optional. If not provided, a generic message
  /// will be displayed. For better UX, provide a contextual message based on
  /// the active filter:
  /// - For 'all' filter: A generic message encouraging task creation
  /// - For 'active' filter: A message indicating no incomplete tasks
  /// - For 'completed' filter: A message indicating no completed tasks
  const EmptyStateWidget({
    super.key,
    this.message,
  });

  /// The message to display below the icon.
  ///
  /// If null, a default generic message will be shown.
  final String? message;

  /// Returns the default message when no custom message is provided.
  String get _defaultMessage => 'No tasks yet. Tap + to create your first task!';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayMessage = message ?? _defaultMessage;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
