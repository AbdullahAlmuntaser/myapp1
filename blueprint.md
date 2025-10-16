# Student Management System Blueprint

## Overview

This blueprint outlines the development and features of a Student Management System built with Flutter. The system aims to provide a comprehensive platform for managing students, classes, grades, attendance, timetables, teachers, and users, with a focus on Material Design 3 principles, robust state management, and an intuitive user interface.

## Style, Design, and Features Implemented

### Theming
- **Material Design 3:** The application adheres to Material Design 3 guidelines for a modern and consistent look and feel.
- **Color Scheme:** Uses `ColorScheme.fromSeed` with `Colors.deepPurple` as the primary seed color for both light and dark themes, ensuring harmonious and accessible color palettes.
- **Typography:** Custom `TextTheme` defined using `google_fonts` (specifically 'Amiri') for various text styles (display, headline, title, body, label), ensuring readability and aesthetic appeal.
- **Component Theming:** `AppBarTheme`, `ElevatedButtonThemeData`, `FloatingActionButtonThemeData`, `CardThemeData`, and `InputDecorationTheme` are customized to maintain a consistent UI across the application.
- **Dark/Light Mode:** Supports both light and dark themes, with `ThemeProvider` (using `ChangeNotifierProvider`) managing the theme mode (`ThemeMode.system`, `ThemeMode.light`, `ThemeMode.dark`).
- **Responsiveness:** Designed to be mobile-responsive and adapt to different screen sizes.

### State Management
- **Provider Package:** Utilizes the `provider` package for efficient and scalable state management.
- **ChangeNotifier Providers:**
    - `ThemeProvider`: Manages the application's theme.
    - `LocalAuthService`: Handles user authentication and user session.
    - `StudentProvider`: Manages student-related data and logic.
    - `TeacherProvider`: Manages teacher-related data and logic.
    - `ClassProvider`: Manages class-related data and logic.
    - `SubjectProvider`: Manages subject-related data and logic.
    - `GradeProvider`: Manages grade-related data and logic.
    - `AttendanceProvider`: Manages attendance records.
    - `TimetableProvider`: Manages timetable entries.
- **Database Integration:** `DatabaseHelper` manages interactions with the local SQLite database (`sqflite`), abstracting data access for providers.

### Navigation and Routing
- **Initial Route:** The `AppInitializer` widget determines the initial screen based on user authentication status. If a user is not authenticated, it navigates to the `RegisterScreen`. If authenticated, it directs to the `DashboardScreen` or a role-specific home screen.
- **Named Routes:** Uses named routes for `GradesScreen` and `AttendanceScreen`, and for authentication (`/login`, `/router`).
- **Bottom Navigation Bar:** `DashboardScreen` uses a `BottomNavigationBar` for easy navigation between main sections (tabs).

### Core Features (Screens and Tabs)
- **Login/Registration:**
    - `LoginScreen`: Allows existing users to log in.
    - `RegisterScreen`: Allows new users to create an account.
- **Dashboard (`DashboardScreen`):** The central hub of the application for authenticated users, featuring a `BottomNavigationBar` with the following tabs:
    - `StudentsTab`: To view, add, edit, and delete student information.
    - `ClassesTab`: To manage academic classes.
    - `SubjectsTab`: To manage subjects.
    - `TeachersTab`: To manage teacher profiles.
    - `GradesOverviewTab`: Provides an overview of student grades.
    - `GradesBulkEntryTab`: For efficient bulk entry of grades.
    - `ReportsTab`: For generating various reports.
    - `SettingsTab`: For application settings, including theme toggles.
- **Student Details:** `StudentDetailForParentScreen` (for parents).
- **Other Screens:** `AddEditClassScreen`, `AddEditGradeDialog`, `AddEditStudentScreen`, `AddEditSubjectScreen`, `AddEditTeacherScreen`, `AddEditTimetableScreen`, `AttendanceScreen`, `GradesScreen`, `ParentPortalScreen`, `TimetableScreen`.

### Internationalization (I18n)
- **Multi-language Support:** Configured for both English and Arabic, with Arabic as the default locale (`locale: const Locale('ar', '')`).

### Logging
- **dart:developer:** Utilizes `dart:developer` for structured logging throughout the application to aid in debugging and monitoring.

## Current Plan

**Objective:** Resolve remaining warnings from `flutter analyze` and ensure a clean project state.

**Steps:**
1.  **Update `.idx/dev.nix` (Initial Attempt):** Modified the `.idx/dev.nix` file to include `pkgs.flutter` and `pkgs.dart`.
2.  **User Reload Workspace:** User reloaded the workspace.
3.  **Initial `flutter doctor` Run:** Revealed Android toolchain issues, Linux toolchain issues, and missing Android Studio.
4.  **Attempt to Accept Android Licenses:** Ran `flutter doctor --android-licenses`.
5.  **Re-run `flutter doctor`:** Still reported unaccepted Android licenses.
6.  **Fix `use_build_context_synchronously`:** Modified `lib/main.dart` to add `if (!mounted) return;` checks.
7.  **Run `flutter analyze` (Post-fix):** Reported "No issues found!"
8.  **Attempt Android Emulator Run (Failed):** Incorrect device ID used.
9.  **Attempt Chrome Run (Failed):** IDE environment lacked graphical X server.
10. **Initial Web Server Run (Failed to Display):** `flutter run -d web-server --web-hostname 0.0.0.0 --web-port $PORT` command ran long, but no display.
11. **User Reload Workspace:** User reloaded the workspace.
12. **Rerun Web Server with `$PORT` (Failed):** `$PORT` not resolved.
13. **Read `$PORT` Environment Variable:** Returned empty string.
14. **Diagnose Web Preview Connection Failure:** User reported "Connection Failed".
15. **Check `.idx/mcp.json`:** Found to be empty.
16. **Add Firebase MCP Configuration:** Added standard Firebase MCP configuration to `.idx/mcp.json`.
17. **User Reload Workspace:** User reloaded the workspace.
18. **Diagnose Dart SDK Version Mismatch (Error):** Debug Console showed "Error: The current Dart SDK version is 3.4.0. Because myapp requires SDK version ^3.8.1, version solving failed."
19. **Modify `.idx/dev.nix` to use Flutter's bundled Dart SDK (Second Attempt):** Removed `pkgs.dart`.
20. **Modify `.idx/dev.nix` to use `unstable` Nix channel:** Changed `channel = "unstable";`.
21. **User Reload Workspace (Critical & Patient Wait):** User reloaded the workspace, which involved a significant wait for Nix to update the SDKs.
22. **Web Preview Successfully Launched:** The application successfully launched and is running in the web preview, allowing user interaction and navigation to the dashboard.
23. **Current Problem Diagnosis:**
    *   `flutter analyze` (after `unstable` channel update) reported `info` level issues related to deprecated API usage in `settings_tab.dart`.
24. **Next Action: Fix Deprecated API Usage and Rerun `flutter analyze`:** Address the `info` warnings by replacing deprecated properties in `lib/src/presentation/tabs/settings_tab.dart` and updating the `ThemeProvider` in `lib/main.dart`. After these fixes, `flutter analyze` will be run again to confirm a clean analysis.
