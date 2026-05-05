/// Widget for filtering tasks by completion status.
///
/// This file defines [FilterBar], a widget that displays three filter chips
/// (All, Active, Completed) allowing users to control which tasks are visible
/// in the task list based on their completion status.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_filter.dart';
import '../../providers/task_list_notifier.dart';

/// A horizontal bar of filter chips for selecting task visibility.
///
/// [FilterBar] renders three [ChoiceChip] widgets representing the three
/// available filter options:
/// - **All**: Shows all tasks regardless of completion status
/// - **Active**: Shows only incomplete tasks
/// - **Completed**: Shows only completed tasks
///
/// The currently active filter is visually highlighted. When a user taps
/// a filter chip, the widget calls [TaskListNotifier.setFilter] to update
/// the visible task list.
///
/// Example usage:
/// ```dart
/// AppBar(
///   bottom: PreferredSize(
///     preferredSize: Size.fromHeight(60),
///     child: FilterBar(),
///   ),
/// )
/// ```
class FilterBar extends StatelessWidget {
  /// Creates a [FilterBar] widget.
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TaskListNotifier>();
    final activeFilter = notifier.activeFilter;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterChip(
            context: context,
            label: 'All',
            filter: TaskFilter.all,
            isSelected: activeFilter == TaskFilter.all,
            onSelected: () => notifier.setFilter(TaskFilter.all),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: 'Active',
            filter: TaskFilter.active,
            isSelected: activeFilter == TaskFilter.active,
            onSelected: () => notifier.setFilter(TaskFilter.active),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: 'Completed',
            filter: TaskFilter.completed,
            isSelected: activeFilter == TaskFilter.completed,
            onSelected: () => notifier.setFilter(TaskFilter.completed),
          ),
        ],
      ),
    );
  }

  /// Builds a single filter chip with the given parameters.
  ///
  /// Parameters:
  /// - [context]: The build context for accessing theme data.
  /// - [label]: The text label displayed on the chip.
  /// - [filter]: The [TaskFilter] value this chip represents.
  /// - [isSelected]: Whether this filter is currently active.
  /// - [onSelected]: Callback invoked when the chip is tapped.
  ///
  /// Returns a [ChoiceChip] widget styled according to the current theme
  /// and selection state.
  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required TaskFilter filter,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    );
  }
}
