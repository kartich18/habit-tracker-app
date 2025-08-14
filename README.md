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
├── models/          # Data models (User, Habit)
├── providers/       # State management (Theme, Auth)
├── screens/         # UI screens
│   ├── auth/        # Authentication screens
│   ├── onboarding/  # User onboarding
│   └── main/        # Main app screens
├── services/        # Business logic services
├── utils/           # Utility functions
└── widgets/         # Reusable UI components
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

