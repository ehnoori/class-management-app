# 📚 Class Evaluation App

A Flutter application for managing and evaluating university classes.

## 🎯 About the Project

This project is being developed with Flutter to create a simple and user-friendly system for managing university classes, class members, and student evaluations.

The application allows users to create classes, save class information locally, select students, and evaluate students using simple computer-related questions.

## ✨ Features

* 🎓 Onboarding screen
* 🚀 Splash screen
* 🏠 Home page for class management
* 📝 Class information management
* ➕ Add a new class
* 📋 View and manage registered classes
* 👥 Class member management
* 🔢 Class member count management
* 👨‍🏫 Teacher name management
* 🏷️ Class type management
* 👤 Student selection
* ☑️ Select a student using Checkbox
* 📝 Student evaluation
* 💻 Computer-related evaluation questions
* ❓ 10 simple computer questions
* 🔘 4 options for each question
* ➡️ Next question navigation
* ⬅️ Previous question navigation
* 📊 Evaluation progress indicator
* 💾 Local data storage using Isar
* 🗂️ Organized database and service structure
* 🎨 Clean and responsive UI
* 📱 Responsive design using `MediaQuery`
* 🔤 Persian/Dari user interface
* 🧭 Bottom navigation
* 🏠 Home navigation item
* 📤 Output navigation item
* 🎨 Custom icons and colors
* 🖼️ Image assets
* 🔤 Persian/Arabic font using `GoogleFonts`
* 📦 Class data model
* 🆔 Automatic Isar ID generation

## 🔄 Application Flow

The main application flow is:

```text
Splash Screen
      ↓
Home
      ↓
Class Information
      ↓
Save Class
      ↓
Student Selection
      ↓
Select One Student
      ↓
Evaluation
      ↓
10 Computer Questions
      ↓
4 Options for Each Question
      ↓
Submit Evaluation
```

## 📱 Screens

### 1. 🚀 Splash Screen

The splash screen is displayed when the application starts and provides an initial loading experience.

### 2. 🎓 Onboarding

Introduction screens that explain the application when the user starts the application.

### 3. 🏠 Home

The main page for managing classes.

Users can:

* Create a new class
* View registered classes
* Navigate between Home and Output sections

### 4. 📝 Class Management

Users can enter and manage class information.

The class form includes:

* Class name
* Teacher name
* Class type
* Class members
* Number of members

### 5. 👥 Student Selection

After saving a class, all members of that class are displayed.

The user can select one student using a Checkbox and continue to the evaluation screen.

### 6. 💻 Student Evaluation

The selected student is evaluated using 10 simple computer-related questions.

Each question contains four answer options.

The evaluation screen includes:

* Student name
* Class information
* Current question number
* Progress indicator
* Four answer options
* Next button
* Previous button
* Submit evaluation button

## 💾 Database Development

Isar is used as the local database for storing class information.

### ClassModel

The class model currently contains:

```dart
@collection
class ClassModel {
  Id id = Isar.autoIncrement;

  late String className;

  late String teacherName;

  late String classType;

  List<String> members = [];
}
```

The model stores:

* Automatic ID
* Class name
* Teacher name
* Class type
* List of class members

### IsarService

An `IsarService` is used to manage the local Isar database.

The database structure is separated from the UI to keep the project organized and maintainable.

## 🧠 Evaluation System

The current evaluation system contains 10 basic computer questions.

Example topics include:

* What is a computer?
* Input devices
* Output devices
* Operating systems
* Keyboard
* Mouse
* Files
* Internet
* Storage devices

Each question contains four possible answers.

The user must select an answer before moving to the next question.

## 🛠️ Technologies

* Flutter
* Dart
* Material Design
* Google Fonts
* MediaQuery
* Flutter Widgets
* Isar Database
* Isar Generator
* Build Runner
* Shared Preferences

## 📁 Project Structure

```text
lib/
│
├── main.dart
│
├── database/
│   └── isar_service.dart
│
├── models/
│   ├── class_model.dart
│   └── class_model.g.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── class_management_screen.dart
│   ├── student_selection_screen.dart
│   ├── evaluation_screen.dart
│   └── splash_screen.dart
│
└── styles/
    └── class_form_style.dart
│
assets/
└── images/
    ├── photo_1.jpg
    ├── photo_2.jpg
    └── photo_3.jpg
```

## 🎨 UI Improvements

The following UI improvements have been implemented:

* Created onboarding screens
* Created splash screen
* Designed the main home page
* Created class management UI
* Added a card for creating a new class
* Added a card for viewing registered classes
* Added article/class icons
* Added custom icon colors
* Designed rounded icon backgrounds
* Added borders around cards
* Improved Persian text alignment
* Placed titles and descriptions on the right side
* Improved responsive sizing using `MediaQuery`
* Added bottom navigation
* Added Home and Output navigation items
* Added and organized image assets
* Used `GoogleFonts.notoSansArabic`
* Designed student selection UI
* Designed evaluation UI
* Added question progress indicator
* Added answer option cards
* Improved overall UI layout and spacing

## 💾 Database Features

The database development includes:

* Added Isar as the local database
* Added `ClassModel`
* Added automatic ID generation
* Added class name
* Added teacher name
* Added class type
* Added class members
* Added member list management
* Added Isar code generation
* Generated `class_model.g.dart`
* Created `IsarService`
* Organized database files into a separate folder

## 📂 Project Organization

The project is organized into separate sections:

* `screens/` — Application screens and UI
* `models/` — Data models
* `database/` — Isar database and database services
* `styles/` — Reusable UI styles
* `assets/` — Images and other application resources

This structure helps keep the project clean, organized, and easier to maintain as new features are added.

## 🚀 Current Project Status

The project is currently under active development.

The application currently includes:

* Splash screen
* Onboarding
* Home page
* Class management
* Class information
* Class member management
* Isar local database
* Student selection
* Student evaluation screen
* 10 simple computer questions
* Four answer options for each question
* Navigation between evaluation questions

### 🔜 Future Improvements

Planned features include:

* 📊 Calculate student evaluation scores
* 💾 Save evaluation results to Isar
* 📋 Display evaluation history
* 📈 Show student performance
* 📊 Generate evaluation reports
* 📤 Export evaluation results
* 📑 Generate Excel reports
* 🔍 Search classes and students
* ✏️ Edit class information
* 🗑️ Delete classes
* 👤 Manage individual student information
* 📊 Improve the Output section

## 👨‍💻 Developer

**Hamed Noori**

Computer Science Student
Herat University

## 📄 License

This project is for educational and learning purposes.
