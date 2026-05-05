/// Local storage implementation of [TaskRepository].
///
/// This implementation persists tasks using [SharedPreferences], which works
/// across all Flutter platforms: Android, iOS, Web, macOS, Linux, and Windows.
///
/// Tasks are serialized as a JSON string and stored under a single key.
/// The repository handles various error conditions gracefully:
/// - Missing data: returns an empty list
/// - Malformed JSON: logs error and returns an empty list
/// - Individual task parsing failures: logs warning, skips entry, continues
/// - Write failures: rethrows exception for caller to handle
library;

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'task_repository.dart';

/// Local storage implementation of [TaskRepository] using [SharedPreferences].
///
/// Stores the complete task list as a JSON string under the key [_storageKey].
/// Works on all Flutter platforms including Web.
///
/// Example usage:
/// ```dart
/// final repository = LocalTaskRepository();
/// final tasks = await repository.loadAll();
/// await repository.saveAll(tasks);
/// ```
class LocalTaskRepository implements TaskRepository {
  /// The key used to store the task list in [SharedPreferences].
  static const String _storageKey = 'todo_list_tasks';

  @override
  Future<List<Task>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      // No data stored yet — return empty list on first launch
      if (jsonString == null || jsonString.trim().isEmpty) {
        developer.log(
          'No tasks found in storage, returning empty list',
          name: 'LocalTaskRepository',
        );
        return [];
      }

      // Parse the JSON string
      final dynamic jsonData;
      try {
        jsonData = json.decode(jsonString);
      } catch (e) {
        developer.log(
          'Failed to parse tasks JSON: $e. Returning empty list.',
          name: 'LocalTaskRepository',
          error: e,
        );
        return [];
      }

      // Validate that the root value is a list
      if (jsonData is! List) {
        developer.log(
          'Tasks JSON root is not a list, returning empty list',
          name: 'LocalTaskRepository',
        );
        return [];
      }

      // Parse each task entry, skipping any that are malformed
      final tasks = <Task>[];
      for (var i = 0; i < jsonData.length; i++) {
        try {
          final taskJson = jsonData[i];
          if (taskJson is! Map<String, dynamic>) {
            developer.log(
              'Task entry at index $i is not a JSON object, skipping',
              name: 'LocalTaskRepository',
              level: 900, // WARNING level
            );
            continue;
          }
          tasks.add(Task.fromJson(taskJson));
        } catch (e) {
          developer.log(
            'Failed to parse task at index $i: $e. Skipping entry.',
            name: 'LocalTaskRepository',
            error: e,
            level: 900, // WARNING level
          );
        }
      }

      developer.log(
        'Successfully loaded ${tasks.length} tasks from storage',
        name: 'LocalTaskRepository',
      );
      return tasks;
    } catch (e) {
      developer.log(
        'Unexpected error while loading tasks: $e. Returning empty list.',
        name: 'LocalTaskRepository',
        error: e,
      );
      return [];
    }
  }

  @override
  Future<void> saveAll(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(
        tasks.map((task) => task.toJson()).toList(),
      );
      await prefs.setString(_storageKey, jsonString);

      developer.log(
        'Successfully saved ${tasks.length} tasks to storage',
        name: 'LocalTaskRepository',
      );
    } catch (e) {
      developer.log(
        'Error while saving tasks: $e',
        name: 'LocalTaskRepository',
        error: e,
      );
      rethrow;
    }
  }
}
