# Blueprint: Student, Teacher, Subject, and Class Management Dashboard

## Overview

This document outlines the plan and features for a comprehensive management application built with Flutter and SQFlite. The application provides full CRUD (Create, Read, Update, Delete) functionality for student, teacher, subject, and class records, offering a centralized dashboard for easy navigation and management.

## Features Implemented

*   **Database Setup:**
    *   Uses the `sqflite` package for local database storage.
    *   Supports multiple tables for `students`, `teachers`, `subjects`, and `classes`.
    *   Each table includes appropriate columns for managing its respective entity.
*   **Data Models:**
    *   `Student` class: Represents student data (id, name, dob, phone, grade).
    *   `Teacher` class: Represents teacher data (id, name, subject, email, qualificationType, responsibleClassId).
    *   `Subject` class: Represents subject data (id, name, description, teacherId).
    *   `Class` class: Represents class data (id, name, teacherId, subjectId, time, room).
*   **State Management:**
    *   Utilizes the `provider` package for efficient and scalable state management across the application.
    *   Dedicated providers for each entity: `StudentProvider`, `TeacherProvider`, `SubjectProvider`, `ClassProvider`.
    *   `ThemeProvider` for managing light/dark mode.
*   **UI/UX:**
    *   **Dashboard Screen (`dashboard_screen.dart`):**
        *   Main entry point with a `TabBarView` to navigate between different management sections.
        *   Tabs for Students, Teachers, Subjects, and Classes.
    *   **Management Tabs (`students_tab.dart`, `teachers_tab.dart`, `subjects_tab.dart`, `classes_tab.dart`):**
        *   Each tab displays a list of its respective entities.
        *   Includes a search bar to filter entities by name (or other relevant fields).
        *   `FloatingActionButton` for adding new entities.
        *   `Card` and `ListTile` widgets for presenting entity details concisely.
        *   `IconButton` for editing and deleting individual records.
    *   **Add/Edit Screens (`add_edit_student_screen.dart`, `add_edit_teacher_screen.dart`, `add_edit_subject_screen.dart`, `add_edit_class_screen.dart`):**
        *   Dedicated screens for adding new records and modifying existing ones.
        *   User-friendly forms with `TextField` widgets for data input.
        *   `DropdownButton` or similar for selecting related entities (e.g., teacher for a class).
        *   Date pickers for date of birth.
        *   Validation for input fields.
    *   **Confirmation Dialogs:** Displays `AlertDialog` for confirming delete operations.
    *   **Snackbars:** Provides feedback for successful operations (e.g., "تم حذف الطالب بنجاح").
    *   **Theme Toggle:** An `IconButton` in the `AppBar` to switch between light and dark modes.
*   **Core Functionality:**
    *   **CRUD Operations:** Full Create, Read, Update, Delete functionality for all entities (Students, Teachers, Subjects, Classes).
    *   **Search Functionality:** Filter records within each tab using a search bar.
    *   **Data Persistence:** All data is stored locally using SQFlite.
    *   **Asynchronous Operations:** Proper handling of asynchronous database operations with `FutureBuilder` or similar patterns, ensuring UI responsiveness.
