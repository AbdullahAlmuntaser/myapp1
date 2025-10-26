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

### UI/UX Enhancements

#### Classes Tab (`ClassesTab`)
- **Modern AppBar:** Updated AppBar design to align with Material Design 3, incorporating thematic colors and a centered title.
- **Enhanced Search Field:** Implemented a modern `TextField` for search with a clear button, hint text, and themed `OutlineInputBorder` for a polished look.
- **Improved Empty States:** Customized display for when no classes are available or no search results are found, featuring relevant icons and clear messages, with an option to clear search if applicable.
- **Interactive Class List (`_buildListView`):**
    - Each class is displayed in an `InkWell` wrapped `Card` for a more interactive and visually appealing item.
    - Actions (edit/delete) are moved into a `PopupMenuButton` to reduce visual clutter and provide a cleaner interface.
    - Text styles are applied from the app's theme for consistency.
- **Responsive Data Table (`_buildDataTable`):**
    - The table is now wrapped in a `Card` with rounded borders.
    - `headingTextStyle` and `dataTextStyle` are set using the app's theme.
    - Actions (edit/delete) are integrated into a `PopupMenuButton` for a consistent experience with the list view.
- **Thematic Floating Action Button:** The "Add Class" `FloatingActionButton.extended` now uses `primaryContainer` and `onPrimaryContainer` colors from the theme, providing a cohesive aesthetic.

#### Attendance Screen (`AttendanceScreen`)
- **Modern AppBar:** Updated AppBar design to align with Material Design 3, incorporating thematic colors and a centered title. Role-based actions (QR code generation for teachers/admins, QR code scanning for students) are implemented.
- **Enhanced Date Picker:** The date selection button is visually improved, and the `showDatePicker` dialog is themed to match the application's Material Design 3 aesthetic.
- **Refined Filter Dropdowns:**
    - Class, Subject, Teacher, and Lesson Number dropdowns are encapsulated within a custom `_buildFilterDropdown` widget.
    - These dropdowns now use `InputDecorator` with themed `OutlineInputBorder` for a modern, consistent, and user-friendly appearance.
    - Clear hint texts and messages for empty states are provided within the dropdowns.
- **Improved QR Code Functionality:**
    - **QR Code Display (`_showQrCodeDialog`):** The QR code generation dialog is redesigned with Material Design 3 aesthetics, including themed QR code colors (`dataModuleStyle`, `eyeFrameStyle`) and improved text presentation.
    - **QR Code Scanner (`_startScan`):** The scanner dialog is styled with rounded borders, and the scanning logic provides clear feedback (success/failure) to the user via `SnackBar` messages. Role-based visibility for scanner is ensured.
- **Clear Loading States:** Implemented a global loading indicator with a modal barrier when data is being fetched, especially when filters are selected, to provide clear user feedback.
- **Informative Empty States:** Custom `_buildEmptyState` widget provides clear, icon-accompanied messages for various scenarios where data is not available (e.g., no classes, no students, filters not selected, or specific instructions for students/teachers).
- **Attendance Status Update:** The `_setStudentAttendance` function now provides immediate `SnackBar` feedback upon successful status update and triggers a reload of attendance data to reflect changes.
- **Role-Based UI Logic:** The UI dynamically adjusts based on the `currentUser`'s role, showing relevant controls (e.g., filters and student list for teachers/admins, scanner button for students).

## Proposed Development Plan

### Phase 1: Local Authentication System
*   **Objective:** Implement a secure local authentication system using the existing SQLite database.
*   **Steps:**
    1.  **Add Dependencies:** Add the `crypto` package for password hashing and `shared_preferences` for session management to `pubspec.yaml`.
    2.  **Enhance User Model:** Update `lib/user_model.dart` to handle password hashing and verification logic.
    3.  **Modify Database Helper:**
        *   Update the `createUser` method in `lib/database_helper.dart` to hash the user's password before storing it.
        *   Create a `loginUser` method to verify user credentials against the stored hashed password.
    4.  **Implement Session Management:**
        *   Update `lib/services/local_auth_service.dart` to use `shared_preferences` to save the user's session upon successful login and clear it on logout.
    5.  **Refactor UI Screens:**
        *   Modify `lib/screens/register_screen.dart` to use the new `createUser` logic.
        *   Modify `lib/screens/login_screen.dart` to use the new `loginUser` logic and handle session creation.
    6.  **Update App Initializer:** Ensure `AppInitializer` in `lib/main.dart` correctly checks the session state from `shared_preferences` to direct users to the appropriate screen (`LoginScreen` or `DashboardScreen`).

### Phase 2: UI/UX Revamp & Advanced Features

#### Dashboard Enhancement
*   **Objective:** Modernize the `DashboardScreen` to be an interactive and informative hub, providing key insights at a glance.
*   **Steps:**
    1.  **Integrate Charting Library:** If not already present, add a charting library (e.g., `fl_chart`) to `pubspec.yaml` for data visualization.
    2.  **Data Retrieval for Dashboard:**
        *   Update `GradeProvider` and `AttendanceProvider` (or create new methods in `DatabaseHelper`) to fetch aggregate data required for dashboard charts (e.g., average grades by subject, attendance rates).
    3.  **Redesign `DashboardScreen` Layout:**
        *   Introduce a responsive layout that can display various widgets, such as:
            *   **Summary Cards:** Displaying counts of students, teachers, classes, and subjects.
            *   **Grade Distribution Chart:** A bar chart or pie chart showing grade distribution across subjects or classes.
            *   **Attendance Trend Chart:** A line chart showing attendance rates over time.
            *   **Upcoming Timetable:** A small widget displaying the next few classes from the timetable.
            *   **Quick Action Buttons:** For frequently used actions like "Add Student" or "Record Attendance".
    4.  **Implement Data Visualization:** Use the chosen charting library to render the fetched aggregate data visually on the dashboard.
    5.  **Role-Based Content:** Ensure that the content displayed on the dashboard is tailored to the `currentUser`'s role (admin, teacher, student, parent).

---
This blueprint will be updated as the project evolves.
