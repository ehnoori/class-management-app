# 📚 Class Evaluation App

A Flutter application for managing and evaluating university classes.

## 🎯 About the Project

This project is being developed with Flutter to create a simple and user-friendly system for managing classes and class evaluations.

## ✨ Features

- 🎓 Onboarding screen
- 🏠 Home page for class management
- 📝 Class information management
- ➕ Add a new class
- 📋 View and manage registered classes
- 🎨 Clean and responsive UI
- 📱 Responsive design using `MediaQuery`
- 🔤 Persian/Dari user interface
- 🧭 Bottom navigation
- 🏠 Home navigation item
- 📤 Output navigation item
- 🎨 Custom icons and colors
- 🖼️ Image assets
- 🔤 Persian Arabic font using `GoogleFonts`
- 💾 Local database using Isar
- 📦 Class data model
- 👥 Class member management
- 🔢 Class member count management
- 🗂️ Organized database and service structure

## 📱 Screens

### 1. Onboarding

Introduction screen displayed when the application starts.

### 2. Home

The main page for managing classes.

### 3. Class Management

Users can add new classes and view/manage registered classes.

### 4. Class Information

Users can enter:

- Class name
- Number of members
- Class members

## 🛠️ Technologies

- Flutter
- Dart
- Material Design
- Google Fonts
- MediaQuery
- Flutter Widgets
- Isar Database
- Isar Generator
- Build Runner

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
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   └── class_management_screen.dart
│
└── styles/
    └── class_form_style.dart

assets/
└── images/
    ├── photo_1.jpg
    ├── photo_2.jpg
    └── ...






    🚀 Today's Progress

Today, the following parts of the application were developed and improved:

🎨 UI Improvements
Created the onboarding screen.
Designed the main home page.
Created the class management UI.
Added a card for creating a new class.
Added a card for viewing and managing registered classes.
Added article/class icons.
Added custom icon colors.
Designed rounded icon backgrounds.
Added black borders around cards.
Improved Persian text alignment.
Placed the title and description on the right side.
Improved responsive sizing using MediaQuery.
Added bottom navigation.
Added Home and Output navigation items.
Added and organized image assets.
Used GoogleFonts.notoSansArabic for Persian text.
Improved the overall UI layout and spacing.
💾 Database Development
Added Isar as the local database.
Added ClassModel for storing class information.
Added automatic ID generation using Isar.
Added class name field.
Added member count field.
Added class members list.
Added Isar code generation using build_runner.
Generated class_model.g.dart.
Created IsarService for database management.
Organized database files into a separate database folder.
📂 Project Organization
Created a separate models folder.
Created a separate database folder.
Created a separate styles folder.
Created class_form_style.dart for reusable class form styling.
Created class_management_screen.dart for class management.
Separated UI, models, database, and styles for better project organization.
📌 Project Status

The project is currently under development.

The application currently includes the main UI, onboarding, class management interface, and the initial Isar database structure.

More features such as saving classes, displaying registered classes, managing class members, class evaluation, and additional screens will be added in future updates.

👨‍💻 Developer

Hamed Noori

📄 License

This project is for educational and learning purposes.