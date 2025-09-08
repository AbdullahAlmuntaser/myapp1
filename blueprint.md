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

**Objective:** Run the Flutter application and view its interfaces.

**Steps:**
1.  **Initial Attempt (Web - Failed):** Attempted to run the application on the web using `flutter run -d web`, but encountered issues with device recognition and web renderer options in the Firebase Studio environment.
2.  **Revised Plan (Android Emulator):** Due to issues with web preview, the current plan is to run the application on an available Android emulator.
3.  **Execution:** Run the command `flutter run -d emulator-5554` to launch the application on the Android emulator.

