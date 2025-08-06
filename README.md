# Habit Tracker App

A modern, intuitive Flutter application designed to help users build and maintain healthy habits through daily tracking, progress monitoring, and intelligent insights. Transform your daily routines into lasting positive changes with our comprehensive habit management system.

## Screenshots

*[Add your app screenshots here to showcase the UI]*

## Features

### Core Functionality
- **User Profile Management**: Create and customize your personal profile with preferences and goals
- **Habit Management**: Create, edit, delete, and organize your habits with ease
- **Daily Tracking**: Simple one-tap marking of habits as complete or incomplete
- **Progress Monitoring**: Visual tracking of your habit completion rates and streaks
- **Smart Reminders**: Set customizable reminders to never miss your habits
- **Responsive Design**: Optimized experience across mobile phones and tablets

### Customization & UI
- **Theme Support**: Switch between light and dark modes
- **Color Schemes**: Multiple color themes to personalize your experience
- **Material Design**: Clean, modern interface following Material Design principles
- **Smooth Animations**: Engaging transitions and micro-interactions

### Analytics & Insights
- **Progress Charts**: Visual representation of your habit completion trends
- **Streak Tracking**: Monitor your longest and current streaks
- **Calendar View**: Monthly overview of your habit completions
- **Completion Statistics**: Detailed analytics on your habit performance

## Technology Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile development framework |
| **Dart** | Programming language |
| **Provider** | State management solution |
| **SharedPreferences** | Local data persistence |
| **Material Design Icons** | Comprehensive icon library |

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (Latest stable version)
- **Dart SDK** (Included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **iOS Simulator** (for iOS development) or **Android Emulator**
- **Git** for version control

## Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/kartich18/habit-tracker-app.git
cd habit-tracker-app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Verify Flutter Installation
```bash
flutter doctor
```

### 4. Run the Application
```bash
# For debug mode
flutter run

# For release mode
flutter run --release

# For specific platform
flutter run -d android
flutter run -d ios
```

## Project Structure

```
habit_tracker/
├── lib/
│   ├── models/          # Data models
│   ├── screens/         # UI screens
│   ├── widgets/         # Reusable components
│   ├── providers/       # State management
│   ├── services/        # Business logic
│   ├── utils/           # Utility functions
│   └── main.dart        # Entry point
├── assets/
│   ├── images/          # App images
│   └── icons/           # Custom icons
├── test/                # Unit tests
├── android/             # Android configuration
├── ios/                 # iOS configuration
└── pubspec.yaml         # Dependencies
```

## Usage Guide

### Getting Started
1. **Launch the app** and create your profile
2. **Add your first habit** by tapping the '+' button
3. **Set reminders** to stay consistent
4. **Track daily** by marking habits complete
5. **Monitor progress** through the analytics dashboard

### Creating Effective Habits
- Start with 1-3 habits to avoid overwhelm
- Make habits specific and measurable
- Set realistic daily goals
- Use the reminder feature strategically

## Configuration

### Customizing Themes
```dart
// Add custom color schemes in theme_data.dart
ThemeData customTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
);
```

### Local Storage
The app uses SharedPreferences for local data storage. Data is automatically saved and persists between app sessions.

## Testing

Run the test suite:
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Contribution Guidelines
- Follow Flutter/Dart style guidelines
- Write tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting

## Known Issues & Roadmap

### Current Limitations
- Offline-only storage (cloud sync planned)
- Limited export options

### Future Enhancements
- [ ] Cloud synchronization
- [ ] Social features and challenges
- [ ] Advanced analytics and insights
- [ ] Habit categories and tags
- [ ] Export data functionality
- [ ] Widget support for home screen

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Kartik** - [@kartich18](https://github.com/kartich18)

## Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI inspiration
- The open-source community for various packages used

## Support

If you encounter any issues or have questions:

1. **Check** the [Issues](https://github.com/kartich18/habit-tracker-app/issues) page
2. **Create** a new issue with detailed information
3. **Contact** the maintainer through GitHub

---

### Show Your Support

If this project helped you, please give it a star on GitHub!

### Connect With Us

- **GitHub**: [kartich18](https://github.com/kartich18)
- **Issues**: [Report a bug](https://github.com/kartich18/habit-tracker-app/issues)

---

*Built with ❤️ using Flutter*
