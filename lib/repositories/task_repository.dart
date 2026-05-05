/// Abstract contract for task persistence.
///
/// This interface defines the operations required to load and save tasks
/// to persistent storage. Concrete implementations can target different
/// storage backends such as the file system, SQLite, or an in-memory
/// store for testing.
///
/// The repository pattern abstracts storage details from business logic,
/// enabling easy testing and flexibility to swap storage implementations
/// without changing the rest of the application.
library;

import '../models/task.dart';

/// Abstract interface for task persistence operations.
///
/// Implementations of this interface are responsible for serializing and
/// deserializing tasks to and from persistent storage.
abstract class TaskRepository {
  /// Loads all persisted tasks from storage.
  ///
  /// Returns an empty list if no data exists or if the storage is empty.
  /// Implementations should handle missing files or empty storage gracefully
  /// by returning an empty list rather than throwing an exception.
  ///
  /// If the storage contains malformed data, implementations may choose to:
  /// - Skip invalid entries and return the valid tasks
  /// - Log warnings for debugging purposes
  /// - Return an empty list if the entire storage is corrupted
  ///
  /// Returns a [Future] that completes with a [List] of [Task] objects.
  Future<List<Task>> loadAll();

  /// Persists the complete task list to storage.
  ///
  /// This operation replaces any previously stored data with the provided
  /// task list. The [tasks] parameter contains the complete list of tasks
  /// to be persisted.
  ///
  /// Implementations should:
  /// - Serialize the task list to the appropriate storage format
  /// - Write the data atomically when possible to prevent corruption
  /// - Rethrow I/O exceptions so callers can handle storage failures
  ///
  /// Parameters:
  /// - [tasks]: The complete list of tasks to persist. May be empty.
  ///
  /// Returns a [Future] that completes when the save operation finishes.
  /// Throws storage-specific exceptions (e.g., IOException) on failure.
  Future<void> saveAll(List<Task> tasks);
}
