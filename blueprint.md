# Blueprint: Student Management Dashboard

## Overview

This document outlines the plan and features for a student management application built with Flutter and SQFlite. The application will provide full CRUD (Create, Read, Update, Delete) functionality for student records.

## Features Implemented

*   **Database Setup:**
    *   Uses the `sqflite` package for local database storage.
    *   A `students` table is created with the following columns: `id` (INTEGER PRIMARY KEY), `name` (TEXT), `dob` (TEXT), `phone` (TEXT), `grade` (TEXT).
*   **Student Model:**
    *   A `Student` class to represent the data structure.
*   **UI/UX:**
    *   A main screen (`HomeScreen`) to display a list of all students.
    *   A dedicated screen (`AddEditStudentScreen`) for adding new students and editing existing ones.
    *   A search bar on the main screen to filter students by name.
    *   User-friendly forms with validation.
    *   Confirmation dialog before deleting a student.
*   **Core Functionality:**
    *   **Create:** Add new student records to the database.
    *   **Read:** Fetch and display all student records.
    *   **Update:** Modify the details of an existing student.
    *   **Delete:** Remove a student's record from the database.
    *   **Search:** Find students by their name.

## Current Plan

1.  **Add Dependencies:** Add `sqflite` and `path_provider` to the `pubspec.yaml` file.
2.  **Create Database Helper:** Implement a `DatabaseHelper` class to manage all database interactions (CRUD operations).
3.  **Create Student Model:** Define the `Student` data model.
4.  **Build UI Screens:**
    *   Create the `HomeScreen` to list and search for students.
    *   Create the `AddEditStudentScreen` form for data entry.
5.  **Integrate Logic:** Connect the UI with the database helper to make the application fully functional.
6.  **Refine and Test:** Ensure all features work as expected and the UI is responsive.
