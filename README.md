# Habit Tracker App

A comprehensive Flutter web application for tracking personal habits, analyzing progress, and maintaining consistency in daily routines. Built with modern Flutter architecture and Firebase backend integration.

## Features

### Core Functionality
- **Habit Management**: Create, edit, and track daily, weekly, and monthly habits
- **Progress Tracking**: Visual progress indicators and completion tracking
- **Data Analytics**: Comprehensive charts and statistics for habit performance
- **Data Export**: Export habit data to CSV and Excel formats
- **Theme Customization**: Personalizable color schemes and dark/light modes

### Authentication & Data
- **Firebase Integration**: Secure user authentication and cloud data storage
- **Hybrid Storage**: Intelligent local and cloud data synchronization
- **User Profiles**: Personalized user experience with profile management
- **Data Backup**: Automatic backup and restore functionality

### User Experience
- **Responsive Design**: Optimized for web and mobile platforms
- **Intuitive Interface**: Clean, modern Material Design 3 UI
- **Onboarding Flow**: Guided setup for new users
- **Guest Mode**: Use app without account creation

## Tech Stack

- **Frontend**: Flutter 3.x with Material Design 3
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider pattern
- **Charts**: fl_chart and Syncfusion Flutter packages
- **Data Export**: CSV and Excel export capabilities
- **Local Storage**: SharedPreferences for offline functionality

## Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Firebase project setup (see Firebase Setup section)

### Installation
1. Clone the repository
   ```bash
   git clone <repository-url>
   cd habit-tracker-app
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase (see Firebase Setup section)

4. Run the application
   ```bash
   flutter run -d chrome
   ```

## Firebase Setup

### 1. Create Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com/)
- Create a new project or select existing one
- Enable Authentication, Firestore Database, and Storage

### 2. Enable Authentication
- In Firebase Console, go to Authentication > Sign-in method
- Enable Email/Password authentication
- Configure additional providers if needed

### 3. Set Up Firestore
- Go to Firestore Database > Create database
- Start in test mode (update security rules later)
- Create collections for users and habits

### 4. Configure Storage
- Go to Storage > Get started
- Set up security rules for file uploads

### 5. Get Configuration
- Go to Project Settings > General
- Copy Firebase config for web platform
- Update `web/index.html` with your config

### 6. Security Rules
Update Firestore security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /habits/{habitId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Project Structure

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

## App Structure

### Authentication Flow
- Welcome screen with login/signup options
- Firebase authentication integration
- User profile creation and management
- Guest mode for non-authenticated users

### Data Management
- Local storage for offline functionality
- Cloud synchronization when authenticated
- Automatic backup and restore capabilities
- Data export in multiple formats

### Customization
- Theme selection during onboarding
- Color scheme personalization
- User preference storage
- Responsive design adaptation

## Analytics & Insights

### Progress Tracking
- Daily completion statistics
- Weekly and monthly trends
- Habit streak tracking
- Performance metrics

### Data Visualization
- Interactive charts and graphs
- Progress indicators
- Trend analysis
- Comparative statistics

### Export Capabilities
- CSV format for spreadsheet analysis
- Excel format with multiple sheets
- Comprehensive data export
- Backup and restore functionality

## Deployment

### Web Deployment
1. Build the web application
   ```bash
   flutter build web
   ```

2. Deploy to hosting service (Firebase Hosting, Netlify, Vercel)
3. Configure custom domain if needed
4. Set up SSL certificates

### Mobile Deployment
1. Build for target platform
   ```bash
   flutter build apk     # Android
   flutter build ios     # iOS
   ```

2. Follow platform-specific deployment guidelines
3. Test on multiple devices and screen sizes

## Contributing

### Development Guidelines
- Follow Flutter and Dart style guidelines
- Use meaningful commit messages
- Test changes thoroughly
- Update documentation as needed

### Code Quality
- Run `flutter analyze` before committing
- Follow established folder structure
- Use index files for clean imports
- Maintain consistent naming conventions

## Future Features

### Planned Enhancements
- Machine learning habit recommendations
- Social features and sharing
- Advanced analytics and insights
- Mobile app store deployment
- Integration with health apps
- Custom habit templates

### Technical Improvements
- Performance optimization
- Enhanced offline capabilities
- Advanced caching strategies
- Accessibility improvements
- Internationalization support

## Troubleshooting

### Common Issues
- **Firebase Configuration**: Ensure correct config in `web/index.html`
- **Authentication Errors**: Check Firebase Authentication settings
- **Data Sync Issues**: Verify Firestore security rules
- **Build Errors**: Run `flutter clean` and `flutter pub get`

### Support
- Check Flutter documentation
- Review Firebase console logs
- Verify network connectivity
- Test with different browsers

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design team for UI guidelines
- Open source community for packages and tools

---

Built with Flutter and Firebase. Designed for productivity and personal growth.

