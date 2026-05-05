/// Task creation and editing screen for the Todo List application.
///
/// This file defines [TaskFormScreen], a form-based screen that handles
/// both creating new tasks and editing existing ones. The screen uses
/// Flutter's Form widget with validation to ensure data integrity.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/task_list_notifier.dart';

/// A form screen for creating new tasks or editing existing ones.
///
/// [TaskFormScreen] operates in two modes:
/// - **Create mode**: When [task] is null, the form is empty and submitting
///   creates a new task.
/// - **Edit mode**: When [task] is provided, all fields are pre-populated
///   with the task's current values and submitting updates the existing task.
///
/// The form includes:
/// - Title field (required, validated for empty/whitespace input)
/// - Description field (optional)
/// - Priority dropdown (defaults to medium)
/// - Due date picker (optional)
///
/// On successful submission, the screen calls the appropriate method on
/// [TaskListNotifier] and pops the navigation stack.
///
/// Example usage:
/// ```dart
/// // Create mode:
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => TaskFormScreen()),
/// );
///
/// // Edit mode:
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => TaskFormScreen(task: existingTask)),
/// );
/// ```
class TaskFormScreen extends StatefulWidget {
  /// The task to edit, or null to create a new task.
  ///
  /// When null, the form operates in create mode with empty fields.
  /// When non-null, the form operates in edit mode with pre-populated fields.
  final Task? task;

  /// Creates a new [TaskFormScreen].
  ///
  /// Parameters:
  /// - [task]: Optional task to edit. If null, the screen operates in create mode.
  /// - [key]: Optional widget key.
  const TaskFormScreen({
    super.key,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  /// Form key for validation and submission handling.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the title text field.
  late final TextEditingController _titleController;

  /// Controller for the description text field.
  late final TextEditingController _descriptionController;

  /// The currently selected priority level.
  late Priority _selectedPriority;

  /// The currently selected due date, or null if no date is set.
  DateTime? _selectedDueDate;

  /// Whether a save operation is currently in progress.
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing task values (edit mode) or empty (create mode)
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');

    // Initialize priority and due date from existing task or defaults
    _selectedPriority = widget.task?.priority ?? Priority.medium;
    _selectedDueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Returns true if the screen is in edit mode (editing an existing task).
  bool get _isEditMode => widget.task != null;

  /// Validates the title field.
  ///
  /// Returns an error message if the title is empty or contains only whitespace.
  /// Returns null if the title is valid.
  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    return null;
  }

  /// Handles form submission.
  ///
  /// Validates the form, then either creates a new task or updates the
  /// existing task depending on the mode. Shows a snackbar on error and
  /// pops the navigation stack on success.
  Future<void> _handleSubmit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Prevent multiple simultaneous submissions
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final notifier = context.read<TaskListNotifier>();
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final descriptionOrNull = description.isEmpty ? null : description;

      if (_isEditMode) {
        // Edit mode: update existing task
        await notifier.updateTask(
          widget.task!.id,
          title: title,
          description: descriptionOrNull,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
        );
      } else {
        // Create mode: add new task
        await notifier.addTask(
          title: title,
          description: descriptionOrNull,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
        );
      }

      // Success - pop the screen
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Shows a date picker dialog and updates the selected due date.
  ///
  /// The date picker allows selecting any date from today onwards.
  /// If the user cancels the picker, the due date remains unchanged.
  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? initialDate : now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  /// Clears the selected due date.
  void _clearDueDate() {
    setState(() {
      _selectedDueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Task' : 'New Task'),
        actions: [
          // Save button in app bar
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _handleSubmit,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
              ),
              validator: _validateTitle,
              textInputAction: TextInputAction.next,
              autofocus: !_isEditMode, // Auto-focus in create mode
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),

            // Priority dropdown
            DropdownButtonFormField<Priority>(
              initialValue: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      // Color indicator
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: priority.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Priority name
                      Text(
                        priority.name[0].toUpperCase() + priority.name.substring(1),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (priority) {
                      if (priority != null) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),

            // Due date picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Due Date'),
                subtitle: _selectedDueDate != null
                    ? Text(
                        '${_selectedDueDate!.year}-${_selectedDueDate!.month.toString().padLeft(2, '0')}-${_selectedDueDate!.day.toString().padLeft(2, '0')}',
                      )
                    : const Text('No due date set'),
                trailing: _selectedDueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _isSaving ? null : _clearDueDate,
                        tooltip: 'Clear due date',
                      )
                    : null,
                onTap: _isSaving ? null : _pickDueDate,
                enabled: !_isSaving,
              ),
            ),
            const SizedBox(height: 24),

            // Save button (alternative to app bar button)
            ElevatedButton(
              onPressed: _isSaving ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditMode ? 'Update Task' : 'Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}
