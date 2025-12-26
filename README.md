# 📱 Daily Planner + Workout Tracker

A modern, feature-rich daily planner and workout tracking application built with Flutter. This app helps you organize your daily schedules, manage tasks, and track your workout routines - all in one place.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## ✨ Features

### 📅 Schedule Management
- Create and manage daily schedules with specific time slots
- Set recurring schedules for specific days of the week
- Toggle schedules on/off without deleting them
- Get notifications for upcoming scheduled events
- View all schedules for today at a glance

### ✅ Task Management
- Create tasks with due dates and priority levels (Low, Medium, High)
- Filter tasks by: Today, Upcoming, Completed, Priority
- Mark tasks as complete with a simple tap
- Get notified before task deadlines
- Track overdue tasks automatically

### 💪 Workout Tracking
- Plan weekly workout routines for each day
- Create custom workouts with multiple exercises
- Track exercise details: sets, reps, duration, weight
- Log completed workouts with actual duration and notes
- View weekly and monthly workout statistics
- Monitor workout completion with visual indicators
- Access complete workout history

### 🏠 Unified Home Dashboard
- See all today's activities in one place
- Filter view by Schedule, Task, or Workout
- Quick access to create new entries
- View key statistics and progress

## 📸 Screenshots

### Home Screen
<img src="assets/screenshots/home_screen.png" alt="Home Screen" width="80%"/>

*Main dashboard showing today's schedules, tasks, and workouts*

### Schedule Management
<img src="assets/screenshots/schedule_screen.png" alt="Schedule Screen" width="80%"/>

*Manage your daily schedules with recurring options*

### Task Management
<img src="assets/screenshots/task_screen.png" alt="Task Screen" width="80%"/>

*Organize tasks by priority and due date*

### Workout Tracking
<img src="assets/screenshots/workout_screen.png" alt="Workout Screen" width="80%"/>

*Weekly workout planner with status indicators*

### Workout Session
<img src="assets/screenshots/workout_session_screen.png" alt="Workout Session" width="80%"/>
<img src="assets/screenshots/workout_session2_screen.png" alt="Workout Session 2" width="80%"/>

*Complete your workouts step-by-step with live tracking*

### Workout History
<img src="assets/screenshots/workout_history_screen.png" alt="Workout History" width="80%"/>

*Track your workout progress over time*


## 🏗️ Architecture

This app follows clean architecture principles with a clear separation of concerns:
lib/
├── core/
│   ├── constants/       # App-wide constants
│   └── utils/          # Helper utilities
├── data/
│   ├── models/         # Data models
│   ├── repositories/   # Data layer logic
│   └── services/       # Database & Notification services
├── providers/          # State management (Provider pattern)
└── ui/
├── routes/         # Navigation (AutoRoute)
├── screens/        # App screens
├── widgets/        # Reusable UI components
└── theme/          # App theming

### Key Technologies

- **State Management:** Provider
- **Navigation:** AutoRoute
- **Local Database:** SQLite (sqflite)
- **Notifications:** flutter_local_notifications
- **Architecture:** MVVM with Repository pattern

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (Android 6.0+)
- iOS device or simulator (iOS 12.0+) [optional]

### Installation

1. **Clone the repository**
```bash
   git clone https://github.com/Asadell/routify_app.git
   cd routify_app
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Generate route files** (if using AutoRoute)
```bash
   dart run build_runner build -d
```

4. **Run the app**
```bash
   flutter run
```

## 📦 Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  change_app_package_name: ^1.5.0               # Change Android/iOS app package name easily
  auto_route: ^11.1.0                           # Navigation & route management
  flutter_animate: ^4.5.2                       # Easy & beautiful animations
  intl: ^0.20.2                                 # Date, number & localization formatting
  sqflite: ^2.4.2                               # Local SQLite database
  path: ^1.9.1                                  # File path utilities (used with SQLite etc.)
  provider: ^6.1.5+1                            # State management
  flutter_local_notifications: ^19.5.0          # Local notifications (Android & iOS)
  timezone: ^0.10.1                             # Timezone support for scheduling notifications
  sizer: ^3.1.3                                 # Responsive UI based on screen size
  iconsax_flutter: ^1.0.1                       # Iconsax icon pack
  flutter_launcher_icons: ^0.14.4               # Generate app launcher icons

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0                         # Recommended lint rules & best practices
  build_runner: ^2.10.4                         # Code generator runner (for auto_route, etc.)
  auto_route_generator: ^10.4.0                 # Code generator for AutoRoute
```

## 🎨 Design Philosophy

This app follows modern mobile design principles:

- **Clean & Minimal:** Distraction-free interface focused on functionality
- **Intuitive Navigation:** Bottom navigation for quick access to main features
- **Visual Feedback:** Clear status indicators and interactive elements
- **Responsive Design:** Adapts to different screen sizes
- **Consistent Theming:** Unified color scheme and typography throughout

### Color Scheme

- **Primary:** Blue (#2196F3) - Trust and productivity
- **Secondary:** Orange (#FF9800) - Energy and motivation
- **Success:** Green (#4CAF50) - Completed tasks
- **Error:** Red (#F44336) - Overdue items
- **Warning:** Amber (#FFC107) - Pending items

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| Android  | ✅ Supported |
| iOS      | ❌ Not Supported |
| Web      | ❌ Not Supported |
| Desktop  | ❌ Not Supported |

## 🔔 Notification Permissions

The app requires notification permissions to alert you about:
- Upcoming scheduled events
- Task deadlines
- Workout reminders

Permissions are requested on first launch and can be managed in app settings.

## 🗃️ Database Schema

### Schedules Table
```sql
CREATE TABLE schedules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  repeat_mon INTEGER DEFAULT 0,
  repeat_tue INTEGER DEFAULT 0,
  repeat_wed INTEGER DEFAULT 0,
  repeat_thu INTEGER DEFAULT 0,
  repeat_fri INTEGER DEFAULT 0,
  repeat_sat INTEGER DEFAULT 0,
  repeat_sun INTEGER DEFAULT 0,
  use_all_7_days INTEGER DEFAULT 0,
  enable_notification INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1,
  created_at TEXT,
  updated_at TEXT
);
```

### Tasks Table
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  due_date TEXT,
  priority TEXT,
  status TEXT DEFAULT 'pending',
  enable_notification INTEGER DEFAULT 0,
  created_at TEXT,
  updated_at TEXT
);
```

### Workouts Table
```sql
CREATE TABLE workouts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  estimated_duration INTEGER,
  notes TEXT,
  enable_notification INTEGER DEFAULT 0
);
```

### Exercises Table
```sql
CREATE TABLE exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  workout_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  sets INTEGER,
  reps INTEGER,
  duration_minutes INTEGER,
  weight REAL,
  FOREIGN KEY(workout_id) REFERENCES workouts(id) ON DELETE CASCADE
);
```

### Workout History Table
```sql
CREATE TABLE workout_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  workout_name TEXT NOT NULL,
  date TEXT NOT NULL,
  actual_duration INTEGER,
  notes TEXT
);
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@Asadell](https://github.com/Asadell)
- Email: asadell@uhuy.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for design guidelines
- All contributors who help improve this project

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Contact via email
- Check the [Wiki](https://github.com/Asadell/routify_app/wiki) for documentation

---

Made with ❤️ using Flutter