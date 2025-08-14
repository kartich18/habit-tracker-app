# Habit Tracker

A modern Flutter application designed to help users build and maintain healthy habits through daily tracking and progress monitoring.

## 🚀 Features

- **User Authentication**: Secure login/signup with Firebase Authentication
- **Cloud Storage**: Data synchronization across devices using Firebase Firestore
- **User Profile Management**: Create and manage your personal profile
- **Habit Management**: Create, edit, and delete habits
- **Daily Tracking**: Mark habits as complete/incomplete
- **Progress Monitoring**: Track your habit completion rates
- **Advanced Analytics**: Comprehensive data analysis and visualization
- **Data Export**: Export habits to CSV and Excel formats
- **Customizable Themes**: Choose between light/dark modes and different color schemes
- **Reminders**: Set reminders for your habits
- **Responsive Design**: Works on both mobile and tablet devices
- **Offline Support**: Local storage with cloud synchronization

## 🔥 Firebase Integration

This app includes full Firebase integration for:

- **Authentication**: Email/password signup and login
- **Cloud Database**: Real-time habit data synchronization
- **Cloud Storage**: Backup and restore functionality
- **Cross-Device Sync**: Access your habits from any device

## 🛠️ Tech Stack

- **Frontend**: Flutter & Dart
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Charts**: FL Chart & Syncfusion Charts
- **Data Export**: CSV & Excel support
- **Icons**: Material Design Icons

## 📱 Getting Started

### Prerequisites

- Flutter (Latest Version)
- Dart SDK
- Firebase account
- Android Studio / VS Code
- iOS Simulator / Android Emulator / Web Browser

### Installation

1. Clone the repository:
```bash
git clone [your-repository-url]
```

2. Navigate to the project directory:
```bash
cd habit_tracker
```

3. Install dependencies:
```bash
flutter pub get
```

4. Set up Firebase:
   - Follow the [Firebase Setup Guide](FIREBASE_SETUP.md)
   - Update configuration files with your Firebase credentials

5. Run the app:
```bash
flutter run
```

## 🔧 Firebase Setup

Before running the app, you need to configure Firebase:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication, Firestore, and Storage
3. Update `lib/firebase_options.dart` with your config
4. Update `web/index.html` with your web config
5. Configure security rules for Firestore and Storage

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions.

## 📊 App Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models (User, Habit)
│   └── index.dart              # Export all models
├── providers/                   # State management (Theme, Auth)
│   └── index.dart              # Export all providers
├── services/                    # Business logic services
│   ├── habit_service.dart       # Basic habit operations
│   ├── firebase_service.dart    # Firebase integration
│   ├── hybrid_habit_service.dart # Smart local+cloud storage
│   ├── data_analysis_service.dart # Data processing & export
│   └── index.dart              # Export all services
├── utils/                       # Utility functions
│   └── storage_utils.dart      # Local storage operations
├── widgets/                     # Reusable UI components
│   ├── habit_list_item.dart    # Individual habit display
│   └── index.dart              # Export all widgets
└── screens/                     # UI screens (organized by feature)
    ├── welcome_screen.dart      # App entry point with auth options
    ├── index.dart               # Export all screen categories
    ├── auth/                    # Authentication screens
    │   ├── login_screen.dart    # User login
    │   ├── signup_screen.dart   # User registration
    │   ├── forgot_password_screen.dart # Password reset
    │   └── index.dart           # Export all auth screens
    ├── onboarding/              # User onboarding
    │   ├── onboarding_screen.dart # App introduction & theme
    │   ├── profile_creation_screen.dart # User profile setup
    │   └── index.dart           # Export all onboarding screens
    ├── main/                    # Core application screens
    │   ├── home_screen.dart     # Main dashboard
    │   ├── profile_screen.dart  # User profile management
    │   └── index.dart           # Export all main screens
    ├── habits/                  # Habit management
    │   ├── add_habit_screen.dart # Create new habits
    │   ├── habit_details_screen.dart # View & edit habits
    │   ├── track_progress_screen.dart # Track progress
    │   └── index.dart           # Export all habit screens
    └── analytics/               # Data analysis & reporting
        ├── analytics_screen.dart # Comprehensive analytics
        ├── statistics_screen.dart # Statistical charts
        ├── data_export_screen.dart # Export to CSV/Excel
        └── index.dart           # Export all analytics screens
```

## 🔐 Authentication Flow

1. **Welcome Screen**: Choose to sign up, sign in, or continue as guest
2. **Sign Up**: Create new account with email and password
3. **Sign In**: Login with existing credentials
4. **Password Reset**: Forgot password functionality
5. **Auto-login**: Persistent authentication state

## 💾 Data Management

- **Local Storage**: Habits stored locally for offline access
- **Cloud Sync**: Automatic synchronization when online
- **Data Backup**: Export habits to Firebase Storage
- **Conflict Resolution**: Cloud data takes precedence over local data

## 🎨 Customization

- **Theme Switching**: Light/dark mode toggle
- **Color Schemes**: Customizable primary colors
- **Responsive Layout**: Adapts to different screen sizes
- **Material Design 3**: Modern UI components

## 📈 Analytics & Insights

- **Habit Trends**: Track completion patterns over time
- **Streak Analysis**: Daily, weekly, and monthly streaks
- **Correlation Analysis**: Identify relationships between habits
- **Progress Tracking**: Goal achievement monitoring
- **Data Visualization**: Charts and graphs for insights

## 🚀 Deployment

### Web Deployment

1. Build the web app:
```bash
flutter build web
```

2. Deploy to Firebase Hosting:
```bash
firebase deploy
```

### Mobile Deployment

1. Build for Android:
```bash
flutter build apk
```

2. Build for iOS:
```bash
flutter build ios
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you encounter issues:

1. Check the [Firebase Setup Guide](FIREBASE_SETUP.md)
2. Review Firebase Console for error logs
3. Ensure all dependencies are properly installed
4. Verify Firebase configuration is correct

## 🔮 Future Features

- Google Sign-In authentication
- Push notifications
- Social features and sharing
- Advanced ML-powered insights
- Multi-language support
- Accessibility improvements

