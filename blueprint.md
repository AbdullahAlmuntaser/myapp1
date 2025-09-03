# Blueprint: School Management App

## Overview

This document outlines the plan and progress for creating a comprehensive School Management application using Flutter. The application will provide a user-friendly interface for managing students, teachers, classes, and subjects. The UI will be responsive, adapting to both mobile and desktop layouts.

## Implemented Style, Design, and Features

### Core Architecture
- **State Management:** Using the `provider` package for managing application state.
- **Database:** Local SQLite database managed via the `sqflite` package.
- **Navigation:** Tab-based navigation for the main sections of the app.
- **Theming:** A consistent theme with support for light and dark modes, managed by `ThemeProvider`.

### Implemented Features
- **Dashboard:** A central dashboard that hosts tabs for Students, Teachers, Classes, Subjects, Grades, Settings, and Reports.
- **Student Management:**
    - View a list of all students.
    - Add new students with details like name, class, parent info, etc.
    - Edit existing student information.
    - Delete students from the system.
    - Search and filter students.
- **Teacher Management:**
    - View a list of all teachers.
    - Add new teachers.
    - Edit existing teacher information.
    - Delete teachers.
    - Search and filter teachers.
- **Subject Management:**
    - View a list of all subjects.
    - Add new subjects.
    - Edit existing subjects.
    - Delete subjects.
    - Search and filter subjects.
- **Class Management:**
    - View a list of all classes.
    - Add new classes.
    - Edit existing class details.
    - Delete classes.
    - Search and filter classes.
- **Attendance Management:**
    - Record and view student attendance by date, class, subject, teacher, and lesson number.
    - Set attendance status (present, absent, late, excused).
- **Grade Management:**
    - View and manage grades for students. (Implemented as `GradesScreen` in `DashboardScreen`).

## Current Plans and Next Steps

This section details the next set of improvements and new features to be implemented.

### 1. Attendance Screen Improvements (`lib/screens/attendance_screen.dart`)

This plan focuses on enhancing the user experience, usability, and robustness of the existing attendance screen.

-   **Loading Indicators:** Implement a `_isLoading` state to display a `CircularProgressIndicator` during asynchronous data fetching operations (`_fetchInitialData`, `_loadAttendanceData`) to provide visual feedback to the user.
-   **Enhanced Initial Load and Empty State Handling:**
    -   Ensure that default selections for `_selectedClass`, `_selectedSubject`, and `_selectedTeacher` are only made if their respective data lists (`classProvider.classes`, `subjectProvider.subjects`, `teacherProvider.teachers`) are not empty.
    -   Provide clear and informative messages to the user when no classes, subjects, or teachers are available, rather than displaying empty dropdowns.
    -   Display a specific guidance message in the student list area if the primary filters (class, subject, teacher, and lesson number) have not yet been fully selected, prompting the user to make their selections.
-   **Improved User Guidance for Filter Selection:** Disable the student attendance status dropdowns for individual students until all necessary primary filters (date, class, subject, teacher, and lesson number) have been selected. This prevents users from attempting to set attendance without complete context.
-   **Refine Date Picker Label:** Simplify the display of the selected date in the `ElevatedButton.icon` to directly show the formatted `_selectedDate`, making it more concise and readable.

### 2. Timetable Screen Implementation

This plan outlines the creation of a new, dedicated screen for viewing and managing school timetables.

-   **File Creation:** Create a new Dart file, `lib/screens/timetable_screen.dart`, to encapsulate the UI and logic for the timetable functionality.
-   **Integration:** Integrate the `TimetableScreen` as a new, accessible tab within the `DashboardScreen`'s `BottomNavigationBar`, providing easy navigation for users.
-   **Data Management:**
    -   **Model:** Utilize the existing `lib/timetable_model.dart` to define the data structure for timetable entries.
    -   **Provider:** Create a new `lib/providers/timetable_provider.dart` to manage the state and business logic related to fetching, adding, editing, and deleting timetable entries. This provider will interact with the database.
-   **User Interface (UI) Design:**
    -   **Grid-based Layout:** Design a visually clear, grid-based layout for the timetable, with columns representing days of the week and rows representing lesson numbers or time slots.
    -   **Filtering:** Implement interactive dropdown filters for `class` and `teacher` at the top of the screen, allowing users to view timetables specific to a chosen class or teacher.
    -   **Slot Details:** Within each timetable slot in the grid, display essential details such as the subject name and either the teacher's name (when viewing a class timetable) or the class name (when viewing a teacher's timetable).