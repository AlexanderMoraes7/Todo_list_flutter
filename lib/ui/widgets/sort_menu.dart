/// Widget for selecting task sort order.
///
/// This file defines [SortMenu], a widget that displays a popup menu button
/// allowing users to choose how tasks should be ordered in the task list.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_filter.dart';
import '../../providers/task_list_notifier.dart';

/// A popup menu button for selecting task sort order.
///
/// [SortMenu] renders a [PopupMenuButton] with three sort options:
/// - **By Creation Date**: Shows newest tasks first
/// - **By Due Date**: Shows tasks with earliest due dates first
/// - **By Priority**: Shows high-priority tasks first
///
/// The currently active sort order is visually indicated with a checkmark.
/// When a user selects a sort option, the widget calls
/// [TaskListNotifier.setSortOrder] to update the task list ordering.
///
/// Example usage:
/// ```dart
/// AppBar(
///   actions: [
///     SortMenu(),
///   ],
/// )
/// ```
class SortMenu extends StatelessWidget {
  /// Creates a [SortMenu] widget.
  const SortMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TaskListNotifier>();
    final activeSortOrder = notifier.activeSortOrder;

    return PopupMenuButton<SortOrder>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort tasks',
      onSelected: (SortOrder sortOrder) {
        notifier.setSortOrder(sortOrder);
      },
      itemBuilder: (BuildContext context) => [
        _buildMenuItem(
          sortOrder: SortOrder.byCreationDate,
          label: 'By Creation Date',
          icon: Icons.access_time,
          isSelected: activeSortOrder == SortOrder.byCreationDate,
        ),
        _buildMenuItem(
          sortOrder: SortOrder.byDueDate,
          label: 'By Due Date',
          icon: Icons.calendar_today,
          isSelected: activeSortOrder == SortOrder.byDueDate,
        ),
        _buildMenuItem(
          sortOrder: SortOrder.byPriority,
          label: 'By Priority',
          icon: Icons.flag,
          isSelected: activeSortOrder == SortOrder.byPriority,
        ),
      ],
    );
  }

  /// Builds a single popup menu item with the given parameters.
  ///
  /// Parameters:
  /// - [sortOrder]: The [SortOrder] value this menu item represents.
  /// - [label]: The text label displayed in the menu item.
  /// - [icon]: The icon displayed before the label.
  /// - [isSelected]: Whether this sort order is currently active.
  ///
  /// Returns a [PopupMenuItem] widget with a checkmark indicator when selected.
  PopupMenuItem<SortOrder> _buildMenuItem({
    required SortOrder sortOrder,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return PopupMenuItem<SortOrder>(
      value: sortOrder,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          if (isSelected)
            const Icon(
              Icons.check,
              size: 20,
            ),
        ],
      ),
    );
  }
}
