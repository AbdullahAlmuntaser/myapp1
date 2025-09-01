# Blueprint: Student, Teacher, Subject, and Class Management Dashboard

## Overview

This document outlines the plan and features for a comprehensive management application built with Flutter and SQFlite. The application provides full CRUD (Create, Read, Update, Delete) functionality for student, teacher, subject, and class records, offering a centralized dashboard for easy navigation and management.

## Features Implemented

*   **Database Setup:**
    *   Uses the `sqflite` package for local database storage.
    *   Supports multiple tables for `students`, `teachers`, `subjects`, and `classes`.
    *   Each table includes appropriate columns for managing its respective entity.
*   **Data Models:**
    *   `Student` class: Represents student data (id, name, dob, phone, grade, email, password, classId).
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
    *   **Snackbars:** Provides feedback for successful operations (e.e.g., "تم حذف الطالب بنجاح").
    *   **Theme Toggle:** An `IconButton` in the `AppBar` to switch between light and dark modes.
*   **Core Functionality:**
    *   **CRUD Operations:** Full Create, Read, Update, Delete functionality for all entities (Students, Teachers, Subjects, Classes).
    *   **Search Functionality:** Filter records within each tab using a search bar.
    *   **Data Persistence:** All data is stored locally using SQFlite.
    *   **Asynchronous Operations:** Proper handling of asynchronous database operations with `FutureBuilder` or similar patterns, ensuring UI responsiveness.

## Current Requested Change: Enhancements to Students Page (واجهة الطلاب)

**Purpose:** To provide a more robust and feature-rich interface for viewing and managing student data, including new fields, improved filtering, responsive display, and comprehensive CRUD operations.

**Plan and Steps:**

1.  **Update Student Model (`lib/student_model.dart`):**
    *   Add new fields: `academicNumber` (الرقم الأكاديمي), `section` (الشعبة), `parentName` (ولي الأمر), `parentPhone` (هاتف ولي الأمر), `address` (العنوان), `status` (حالة الطالب - `bool` for active/inactive).

2.  **Update Database Helper (`lib/database_helper.dart`):**
    *   Modify `_onCreate` and `_onUpgrade` to include the new columns in the `students` table.
    *   Update SQL queries in `insertStudent`, `updateStudent`, and `queryStudents` to handle the new fields.

3.  **Update Student Provider (`lib/providers/student_provider.dart`):**
    *   Modify `addStudent` and `updateStudent` methods to accept and save the new student properties.
    *   Implement logic to check for unique email addresses before adding or updating a student.
    *   Enhance `searchStudents` to include filtering by `classId` (when a class is selected from a dropdown).

4.  **Update Add/Edit Student Screen (`lib/screens/add_edit_student_screen.dart`):**
    *   Replace the existing `TextFormField` for `classId` with a `DropdownButton` that dynamically loads available classes from `ClassProvider`.
    *   Add new `TextFormField` widgets for:
        *   `الرقم الأكاديمي` (Academic Number - required).
        *   `الشعبة` (Section - optional).
        *   `ولي الأمر` (Parent Name - optional).
        *   `هاتف ولي الأمر` (Parent Phone - optional).
        *   `العنوان` (Address - optional).
    *   Add a `DropdownButton` or `Switch` for `حالة الطالب` (Student Status - Active/Inactive).
    *   Implement robust validation for all new and existing fields, including unique email validation.
    *   Ensure all new UI texts are properly localized in Arabic.

5.  **Update Students Tab (`lib/screens/tabs/students_tab.dart`):**
    *   **Top Bar:**
        *   Integrate a `TextFormField` for text-based search.
        *   Implement a `DropdownButton` to filter students by selected class, dynamically fetching classes from `ClassProvider`.
    *   **Student Display:**
        *   For mobile devices (smaller screens), display students using a `ListView` of `Card` widgets. Each card will show student's image (placeholder initially), name, academic number, and class.
        *   For larger screens (e.g., web), display students using a `DataTable` to show more detailed information in a tabular format (including the new fields).
    *   **Actions per Student:** Integrate a `PopupMenuButton` or a row of `IconButton` widgets within each student entry (card/row) for 'تعديل' (Edit) and 'حذف' (Delete) actions.
    *   **Add Student Button:** Ensure a `FloatingActionButton` is available for 'إضافة طالب جديد' (Add New Student), which navigates to `AddEditStudentScreen`.

6.  **Implement Responsive Design:** Ensure smooth transitions and optimal layout presentation across various screen sizes (mobile and web) for the `StudentsTab`, especially concerning the `ListView` vs `DataTable` display.

7.  **Review and Enhance Localization:** Double-check all existing and newly added UI strings for accurate Arabic translation and appropriate use of contextual phrases.

8.  **Build and Test:** Perform a full application build and thorough testing to ensure all new features are functional, free of bugs, and that existing functionality remains intact. This includes testing data persistence, CRUD operations, search, filtering, and responsive UI behavior.
