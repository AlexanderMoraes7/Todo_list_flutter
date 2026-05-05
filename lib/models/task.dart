/// Data models for tasks in the Todo List application.
///
/// This file defines the [Priority] enum and the immutable [Task] class,
/// which represents a single to-do item with all its associated metadata.
library;

import 'package:flutter/material.dart';

/// The urgency level of a task.
///
/// Each priority level has an associated color for visual representation
/// in the UI (green for low, orange for medium, red for high).
enum Priority {
  /// Low priority task (displayed in green).
  low,

  /// Medium priority task (displayed in orange). This is the default priority.
  medium,

  /// High priority task (displayed in red).
  high;

  /// Returns the color associated with this priority level.
  ///
  /// - [low] returns green (Colors.green)
  /// - [medium] returns orange (Colors.orange)
  /// - [high] returns red (Colors.red)
  Color get color {
    switch (this) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }

  /// Parses a lowercase priority string into a [Priority] enum value.
  ///
  /// Throws [FormatException] if the string does not match a known priority.
  static Priority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        throw FormatException('Unknown priority string: $value');
    }
  }

  /// Returns the lowercase string representation of this priority.
  ///
  /// Used for JSON serialization.
  String toJsonString() {
    return name.toLowerCase();
  }
}

/// Immutable representation of a single to-do item.
///
/// All mutation operations return a new [Task] instance (copyWith pattern),
/// ensuring that state changes are explicit and traceable.
///
/// Tasks are uniquely identified by their [id] field (UUID v4) and contain
/// metadata about creation, updates, completion, priority, and optional due dates.
class Task {
  /// Unique identifier (UUID v4).
  final String id;

  /// Non-empty title of the task.
  final String title;

  /// Optional longer description providing additional details about the task.
  final String? description;

  /// Urgency level; defaults to [Priority.medium].
  final Priority priority;

  /// Optional deadline for the task.
  ///
  /// Stored as a UTC DateTime. When null, the task has no due date.
  final DateTime? dueDate;

  /// UTC timestamp of when the task was created.
  final DateTime createdAt;

  /// UTC timestamp of the most recent update, or null if never updated.
  final DateTime? updatedAt;

  /// Whether the task has been completed.
  final bool isCompleted;

  /// UTC timestamp of when the task was completed, or null if not completed.
  ///
  /// This field should be null when [isCompleted] is false, and non-null
  /// when [isCompleted] is true.
  final DateTime? completedAt;

  /// Creates a new [Task] instance.
  ///
  /// The [id], [title], and [createdAt] fields are required.
  /// The [priority] defaults to [Priority.medium] if not specified.
  /// The [isCompleted] defaults to false if not specified.
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.priority = Priority.medium,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
    this.isCompleted = false,
    this.completedAt,
  });

  /// Returns a copy of this task with the specified fields replaced.
  ///
  /// Any field not provided will retain its current value from this instance.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Serializes this task to a JSON-compatible map.
  ///
  /// - [priority] is stored as a lowercase string ("low", "medium", "high")
  /// - All [DateTime] fields are stored as ISO 8601 UTC strings
  /// - Nullable fields are stored as JSON null
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.toJsonString(),
      'dueDate': dueDate?.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toUtc().toIso8601String(),
    };
  }

  /// Deserializes a task from a JSON-compatible map.
  ///
  /// Throws [FormatException] if:
  /// - Required fields (id, title, createdAt, isCompleted) are missing
  /// - The priority string is not recognized
  /// - DateTime strings cannot be parsed
  factory Task.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (!json.containsKey('id') || json['id'] == null) {
      throw FormatException('Missing required field: id');
    }
    if (!json.containsKey('title') || json['title'] == null) {
      throw FormatException('Missing required field: title');
    }
    if (!json.containsKey('createdAt') || json['createdAt'] == null) {
      throw FormatException('Missing required field: createdAt');
    }
    if (!json.containsKey('isCompleted') || json['isCompleted'] == null) {
      throw FormatException('Missing required field: isCompleted');
    }

    // Parse priority with default fallback
    Priority priority = Priority.medium;
    if (json.containsKey('priority') && json['priority'] != null) {
      priority = Priority.fromString(json['priority'] as String);
    }

    // Parse DateTime fields
    DateTime? parseDueDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value as String).toUtc();
      } catch (e) {
        throw FormatException('Invalid dueDate format: $value');
      }
    }

    DateTime parseCreatedAt(dynamic value) {
      try {
        return DateTime.parse(value as String).toUtc();
      } catch (e) {
        throw FormatException('Invalid createdAt format: $value');
      }
    }

    DateTime? parseUpdatedAt(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value as String).toUtc();
      } catch (e) {
        throw FormatException('Invalid updatedAt format: $value');
      }
    }

    DateTime? parseCompletedAt(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value as String).toUtc();
      } catch (e) {
        throw FormatException('Invalid completedAt format: $value');
      }
    }

    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: priority,
      dueDate: parseDueDate(json['dueDate']),
      createdAt: parseCreatedAt(json['createdAt']),
      updatedAt: parseUpdatedAt(json['updatedAt']),
      isCompleted: json['isCompleted'] as bool,
      completedAt: parseCompletedAt(json['completedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.priority == priority &&
        other.dueDate == dueDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isCompleted == isCompleted &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      priority,
      dueDate,
      createdAt,
      updatedAt,
      isCompleted,
      completedAt,
    );
  }
}
