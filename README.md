# Flutter Todo List

A portfolio-quality mobile task management application built with Flutter and Dart, demonstrating clean architecture, comprehensive testing, and professional development practices.

## Overview

This Todo List application is designed to showcase modern Flutter development techniques and serve as both a functional task manager and an educational reference for developers learning Flutter. The app allows users to create, manage, and organize personal tasks with priorities, due dates, and completion tracking—all persisted locally on the device.

## Features

- ✅ **Task Management**: Create, edit, delete, and complete tasks
- 🎯 **Priority Levels**: Assign Low, Medium, or High priority to tasks with color-coded indicators
- 📅 **Due Dates**: Set optional deadlines for tasks
- 🔍 **Filtering**: View All, Active, or Completed tasks
- 📊 **Sorting**: Order tasks by creation date, due date, or priority
- 💾 **Local Persistence**: All data saved automatically to device storage
- 🎨 **Material Design 3**: Modern, clean UI following Flutter's latest design guidelines
- ✨ **Responsive UX**: Smooth animations, loading states, and error handling

## Architecture

The application follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│              UI Layer                   │  Flutter Widgets & Screens
├─────────────────────────────────────────┤
│           State Management              │  ChangeNotifier / Provider
├─────────────────────────────────────────┤
│          Service Layer                  │  TaskManager (business logic)
├─────────────────────────────────────────┤
│         Repository Layer                │  TaskRepository (storage abstraction)
├─────────────────────────────────────────┤
│          Storage Layer                  │  LocalFileStorage (JSON / dart:io)
└─────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Responsibility | Key Classes |
|-------|---------------|-------------|
| **UI** | Render widgets, capture user input, display state | `TaskListScreen`, `TaskFormScreen`, `TaskTile` |
| **State Management** | Hold observable state, coordinate UI ↔ Service | `TaskListNotifier` |
| **Service** | Business rules: create, update, delete, filter, sort | `TaskManager` |
| **Repository** | Abstract storage; swap implementations for tests | `TaskRepository`, `LocalTaskRepository` |
| **Storage** | Serialize/deserialize JSON; read/write to disk | `LocalFileStorage` |

### Key Design Principles

- **Testability**: Business logic isolated from UI and I/O for fast, deterministic testing
- **Maintainability**: Clear structure with single-responsibility components
- **Extensibility**: Abstract interfaces enable easy feature additions
- **Correctness**: Property-based testing validates universal invariants

## Project Structure

```
lib/
├── main.dart                           # App entry point, Provider setup
├── models/
│   ├── task.dart                       # Task data class + Priority enum
│   └── task_filter.dart                # Filter and SortOrder enums
├── repositories/
│   ├── task_repository.dart            # Abstract interface
│   └── local_task_repository.dart      # JSON file implementation
├── services/
│   └── task_manager.dart               # Business logic
├── providers/
│   └── task_list_notifier.dart         # ChangeNotifier for UI state
└── ui/
    ├── screens/
    │   ├── task_list_screen.dart       # Main task list view
    │   └── task_form_screen.dart       # Create/edit task form
    └── widgets/
        ├── task_tile.dart              # Individual task display
        ├── filter_bar.dart             # Filter chips (All/Active/Completed)
        ├── sort_menu.dart              # Sort order selector
        └── empty_state_widget.dart     # Empty list placeholder

test/
├── models/
│   └── task_test.dart                  # Task model tests + Property 1
├── services/
│   └── task_manager_test.dart          # Business logic tests + Properties 2-7
├── repositories/
│   └── local_task_repository_test.dart # Storage tests
└── ui/
    ├── task_list_screen_test.dart      # Widget tests
    └── task_form_screen_test.dart      # Form validation tests
```

## Setup and Installation

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- An IDE (VS Code, Android Studio, or IntelliJ IDEA)
- iOS Simulator / Android Emulator or a physical device

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd todo_list
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify installation**
   ```bash
   flutter doctor
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

   Or select a device in your IDE and press the Run button.

### Running Tests

Run all tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

Run specific test files:
```bash
flutter test test/models/task_test.dart
flutter test test/services/task_manager_test.dart
```

### Code Quality

Check for issues:
```bash
flutter analyze
```

Format code:
```bash
dart format lib/ test/
```

## Testing Strategy

The application uses a **dual testing approach**:

### Unit Tests
- Specific examples and edge cases
- Error condition handling
- Concrete regression prevention

### Property-Based Tests
- Universal correctness properties across all inputs
- Uses the [`fast_check`](https://pub.dev/packages/fast_check) library
- Minimum 100 iterations per property
- Validates invariants like serialization round-trips, filter partitioning, and sort stability

### Test Coverage

- **Models**: Serialization, validation, equality
- **Services**: Task CRUD operations, filtering, sorting
- **Repositories**: Storage I/O, error handling
- **UI**: Widget rendering, user interactions, form validation

## Screenshots

<!-- Add screenshots here to showcase the app's UI -->

### Main Task List
*Screenshot placeholder: Add an image showing the main task list with various tasks, priorities, and filters*

### Task Creation Form
*Screenshot placeholder: Add an image showing the task creation/editing form*

### Filtering and Sorting
*Screenshot placeholder: Add an image demonstrating the filter and sort functionality*

**To add screenshots:**
1. Take screenshots of the app running on a device or emulator
2. Save images to a `screenshots/` directory in the project root
3. Update the markdown above with image references:
   ```markdown
   ![Main Task List](screenshots/task_list.png)
   ```

## Technologies Used

- **Flutter**: UI framework
- **Dart**: Programming language
- **Provider**: State management
- **path_provider**: Local file system access
- **uuid**: Unique identifier generation
- **fast_check**: Property-based testing
- **mockito**: Mock generation for testing

## Contributing

This is a portfolio project, but suggestions and feedback are welcome! Feel free to:
- Open issues for bugs or feature requests
- Submit pull requests with improvements
- Use this code as a reference for your own projects

## License

This project is open source and available under the [MIT License](LICENSE).

## Contact

For questions or feedback, please reach out via:
- GitHub Issues: [Create an issue](../../issues)
- LinkedIn: [Your LinkedIn Profile]
- Email: [Your Email]

---

**Built with ❤️ using Flutter**
