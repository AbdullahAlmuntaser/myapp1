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
- **Named Routes:** Uses named routes for `GradesScreen` and `AttendanceScreen`, and for authentication (`/login`, `/register`).
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

**Objective:** Finally resolve the Dart SDK version mismatch and successfully run the Flutter application as a web server to display its interfaces within the IDE's preview.

**Steps:**
1.  **Update `.idx/dev.nix`:** Modified the `.idx/dev.nix` file to explicitly include `pkgs.flutter` and `pkgs.dart` in the `packages` list, ensuring Flutter and Dart are available in the workspace environment.
2.  **User Action Required (Reload Workspace):** Instructed the user to reload their workspace for the changes to the `.idx/dev.nix` file to take effect.
3.  **Initial `flutter doctor` Run:** Executed `flutter doctor` which revealed:
    *   Android toolchain: Some Android licenses not accepted.
    *   Linux toolchain: Missing `clang++`, `CMake`, `ninja`, `pkg-config`.
    *   Android Studio: Not installed.
4.  **Attempt to Accept Android Licenses:** Ran `flutter doctor --android-licenses` to accept pending Android SDK licenses.
5.  **Re-run `flutter doctor`:** Executed `flutter doctor` again to verify the resolution of Android license issues. This run still reported that Android licenses were not accepted, which was unexpected.
6.  **Fix `use_build_context_synchronously` issues:** Modified `lib/main.dart` to add `if (!mounted) return;` checks before `Provider.of(context)` calls after `await` operations to resolve `use_build_context_synchronously` lint warnings.
7.  **Run `flutter analyze`:** Executed `flutter analyze` which reported "No issues found!" indicating that all code quality issues have been addressed.
8.  **Attempt to Run Application on Android Emulator (Failed):** Executed `flutter run -d android` which failed due to an incorrect device ID. An available emulator `emulator-5554` was identified.
9.  **Attempt to Run Application on Chrome (Failed):** Executed `flutter run -d chrome` which failed because the IDE environment does not have a graphical X server to launch Chrome as a desktop application.
10. **Initial Run Application as Web Server (Failed to Display):** Executed `flutter run -d web-server --web-hostname 0.0.0.0 --web-port $PORT`. The command indicated it was long-running, but the application did not appear in the IDE's preview.
11. **Workspace Reload (User Action):** Instructed the user to reload the workspace after the previous web server attempt to ensure a clean state.
12. **Attempt to Rerun Web Server with `$PORT` (Failed):** Executed `flutter run -d web-server --web-hostname 0.0.0.0 --web-port $PORT` again after workspace reload. This failed because `$PORT` was not resolved to an actual port number.
13. **Attempt to Read `$PORT` Environment Variable:** Executed `echo $PORT` to check if the `$PORT` environment variable was accessible, which returned an empty string.
14. **Diagnose Web Preview Connection Failure:** Received user feedback that the web preview shows "Connection Failed".
15. **Check `.idx/mcp.json`:** Inspected the `.idx/mcp.json` file and found it to be empty, indicating missing Firebase MCP configurations.
16. **Add Firebase MCP Configuration:** Added the standard Firebase MCP configuration to `.idx/mcp.json` to ensure the core Firebase Studio environment is set up correctly.
17. **Workspace Reload (User Action):** Instructed the user to reload the workspace again to apply the `.idx/mcp.json` changes.
18. **Diagnose Dart SDK Version Mismatch (New Error):** After the last workspace reload, the Debug Console showed the error: "Error: The current Dart SDK version is 3.4.0. Because myapp requires SDK version ^3.8.1, version solving failed."
19. **Modify `.idx/dev.nix` to use Flutter's bundled Dart SDK (Initial Attempt):** Removed `pkgs.dart` from the `packages` list in `.idx/dev.nix`, relying instead on the Dart SDK version bundled with `pkgs.flutter`. This attempt did not resolve the Dart SDK version mismatch.
20. **Modify `.idx/dev.nix` to use `unstable` Nix channel for updated SDKs:** Changed the `channel` in `dev.nix` from `"stable-24.05"` to `"unstable"` to access more recent versions of Flutter and Dart, which should include the required SDK version. This change has been confirmed in the `dev.nix` file.
21. **Critical Next Action: Final Workspace Reload (User Action) and Patient Waiting:** After confirming the `dev.nix` channel change, a *final and critical* workspace reload is required. This time, it's essential to allow ample time for Nix to pull and configure the updated Flutter/Dart SDK from the `unstable` channel. This process is intensive and will likely take a long time. Upon completion, the IDE should attempt to start the web preview automatically. The user *must* wait patiently without any interaction during this reload and subsequent automated preview startup.
