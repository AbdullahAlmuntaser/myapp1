
# Blueprint: School Management App

## Overview

This document outlines the plan and progress for creating a comprehensive School Management application using Flutter. The application will provide a user-friendly interface for managing students, teachers, classes, and subjects. The UI will be responsive, adapting to both mobile and desktop layouts.

## Implemented Style, Design, and Features

### Core Architecture
- **State Management:** Using the `provider` package for managing application state.
- **Database:** Local SQLite database managed via the `sqflite` package.
- **Navigation:** Tab-based navigation for the main sections of the app.
- **Theming:** A consistent theme with support for light and dark modes.

### Implemented Features
- **Dashboard:** A central dashboard that hosts tabs for Students, Teachers, Classes, and Subjects.
- **Student Management:**
    - View a list of all students.
    - Add new students with details like name, class, parent info, etc.
    - Edit existing student information.
    - Delete students from the system.
- **Subject Management:**
    - View a list of all subjects.
    - Add new subjects.
    - Edit existing subjects.
    - Delete subjects.
- **Class Management:**
    - View a list of all classes.
    - Add new classes.
    - Edit existing class details.
    - Delete classes.

## Current Task: Implement Teachers Page

This task focuses on creating the user interface and logic for managing teachers within the application.

### 1. Plan and User Interface (UI)

- **Purpose:** Display and manage data for all teachers in the system.
- **Components:**
    - **Top Bar:** Will contain a `TextFormField` for searching and a `DropdownButton` to filter by subject.
    - **"Add Teacher" Button:** A `FloatingActionButton` or `ElevatedButton` for adding new teachers.
    - **Data Display (Responsive):**
        - **Mobile:** A `ListView` of `Card`s. Each card will display the teacher's photo, name, and the subjects they teach.
        - **Large Screens:** A `DataTable` will be used to display the same data in a tabular format.
    - **Action Menu:** A `PopupMenuButton` or `IconButton` for each teacher, providing "Edit" and "Delete" options.

### 2. "Add Teacher" Logic

- **Trigger:** A dialog or a new page will appear upon pressing the "Add Teacher" button.
- **Input Fields:** The form will include `TextFormField`s for:
    - Full Name (Required)
    - Email (Required, Unique)
    - Password (Required)
    - A multi-select dropdown to assign subjects to the teacher.
- **On Save:** A new teacher account will be created in the local database with the provided details.

### 3. "Edit Teacher" Logic

- **Trigger:** The same "Add Teacher" form will be used, but it will be pre-filled with the data of the selected teacher.
- **Functionality:** Allows for the modification of all teacher data.
- **On Save:** The teacher's record in the database will be updated.
