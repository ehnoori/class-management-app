# 📚 Class Evaluation App

A Flutter application for managing university classes, class members, student evaluations, and Excel reports.

Developed by **Hamed Noori**, a Computer Science student at Herat University.

## 📖 About the Project

Class Evaluation App is designed to simplify university class management and student evaluation. Users can create classes, register students, evaluate each student using a questionnaire, store results locally, and export evaluation reports to Excel.

The application provides a Persian/Dari right-to-left interface and is designed to be simple and user-friendly.

## ✨ Features

### 🎓 Application Interface
- Splash screen
- Onboarding screens
- Home dashboard
- Persian/Dari right-to-left layout
- Responsive interface using `MediaQuery`
- Custom colors, icons, and typography
- Bottom navigation

### 🏫 Class Management
- Create new classes
- Enter class names
- Enter teacher names
- Set class schedules
- Register multiple class members
- View registered classes
- Expand class cards to view members
- Delete classes and related evaluation data

### 👥 Student Management
- Display students registered in each class
- Select a student for evaluation
- Display evaluation status
- Prevent duplicate evaluations within the same class
- Allow the same student to be evaluated in different classes

### 📝 Student Evaluation
- Computer-related questionnaire
- Multiple question types, including choice, number, project, and text questions
- Navigate between questions
- Display evaluation progress
- Validate required answers
- Save evaluation results locally
- Associate each evaluation with its class and student

### 💾 Database
- Local data storage using Isar
- Automatic database ID generation
- Separate class and evaluation models
- Database operations organized in `IsarService`
- Retrieve evaluations by class and student
- Delete individual or class-related evaluations

### 📊 Excel Reports
- Export evaluation results to Excel
- Create a separate worksheet for evaluation results
- Include class information and evaluation statistics
- List all class members, including students who have not been evaluated
- Display student answers in the report
- Update the class report instead of creating a new file for every export

## 🔄 Application Workflow

```text
Splash Screen
      ↓
Onboarding
      ↓
Home Dashboard
      ↓
Create or Open a Class
      ↓
Select a Student
      ↓
Complete the Questionnaire
      ↓
Validate Answers
      ↓
Save Evaluation to Isar
      ↓
Update Excel Report
```

## 🖼️ Screenshots

Add screenshots of the actual application to the `screenshots/` directory.

Once these images exist in your repository, GitHub will display them in this section.

| Home Screen | Class Management |
|---|---|
| ![Home Screen](screenshots/home.png) | ![Class Management](screenshots/class_management.png) |

| Student Selection | Student Evaluation |
|---|---|
| ![Student Selection](screenshots/student_selection.png) | ![Student Evaluation](screenshots/evaluation.png) |

| Excel Report | Onboarding |
|---|---|
| ![Excel Report](screenshots/excel_report.png) | ![Onboarding](screenshots/onboarding.png) |

*Note: These image paths are placeholders. Add the corresponding screenshots before publishing this section.*

## 🛠️ Technologies

- **Flutter** — Cross-platform application development
- **Dart** — Programming language
- **Material Design** — User interface components
- **Isar** — Local database
- **Google Fonts** — Typography
- **Shared Preferences** — Local preferences
- **Excel package** — Excel report generation
- **OpenFilex** — Opening supported files
- **Path Provider** — Accessing application directories
- **Build Runner** — Code generation for Isar

## 📁 Project Structure

```text
lib/
├── main.dart
├── database/
│   └── isar_service.dart
├── models/
│   ├── class_model.dart
│   ├── class_model.g.dart
│   ├── evaluation_model.dart
│   └── evaluation_model.g.dart
├── screens/
│   ├── home_screen.dart
│   ├── class_management_screen.dart
│   ├── student_selection_screen.dart
│   ├── evaluation_screen.dart
│   └── splash_screen.dart
└── styles/
    └── class_form_style.dart

assets/
└── images/

screenshots/
├── home.png
├── class_management.png
├── student_selection.png
├── evaluation.png
├── excel_report.png
└── onboarding.png
```

*The structure above is illustrative. Keep only files and directories that actually exist in your project.*

## 🚀 Getting Started

### Prerequisites

Install the following tools:

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio or Visual Studio Code
- An Android emulator or a physical Android device

### Installation

Clone the repository:

```bash
git clone https://github.com/ehnoori/class_evaluation_app.git
```

Open the project directory:

```bash
cd class_evaluation_app
```

Install dependencies:

```bash
flutter pub get
```

If Isar generated files need to be regenerated, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Check the Flutter environment:

```bash
flutter doctor
```

Run the application:

```bash
flutter run
```

Run static analysis:

```bash
flutter analyze
```

Run automated tests:

```bash
flutter test
```

## 🧪 Testing Checklist

Before releasing a new version, verify the following:

- [ ] The application starts successfully.
- [ ] Onboarding and navigation work correctly.
- [ ] A new class can be created and saved.
- [ ] Class members appear correctly.
- [ ] A student can complete and submit an evaluation.
- [ ] Evaluation data remains available after restarting the app.
- [ ] A student cannot submit a second evaluation in the same class.
- [ ] The same student can be evaluated in another class.
- [ ] Different classes display only their own evaluation results.
- [ ] Excel reports contain the correct class and student information.
- [ ] Unevaluated students appear in Excel reports.
- [ ] Deleting a class handles its related evaluation records correctly.

## 🔜 Future Improvements

- Import questions from JSON or PDF
- Manage questions without modifying Dart source code
- Add evaluation history and detailed reports
- Improve student search and management
- Add more advanced statistics
- Expand automated testing
- Improve data backup and restore
- Consider cloud synchronization in a future version

## 👨‍💻 Developer

**Hamed Noori**

Computer Science Student  
Herat University

GitHub: [@ehnoori](https://github.com/ehnoori)

## 📄 License

This project is developed for educational and learning purposes.
