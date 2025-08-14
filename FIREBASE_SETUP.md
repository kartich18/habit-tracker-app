# Firebase Setup Guide for Habit Tracker

This guide will help you set up Firebase for your Habit Tracker Flutter application.

## Prerequisites

- Flutter SDK installed
- Firebase account
- Google Cloud Console access

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "habit-tracker-app")
4. Choose whether to enable Google Analytics (recommended)
5. Click "Create project"

## Step 2: Enable Authentication

1. In your Firebase project, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" authentication
5. Click "Save"

## Step 3: Create Firestore Database

1. Go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a location for your database
5. Click "Done"

## Step 4: Set up Storage

1. Go to "Storage" in the left sidebar
2. Click "Get started"
3. Choose "Start in test mode" for development
4. Select a location for your storage
5. Click "Done"

## Step 5: Configure Security Rules

### Firestore Security Rules

Go to Firestore Database > Rules and update with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Users can access their own habits
      match /habits/{habitId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Storage Security Rules

Go to Storage > Rules and update with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only access their own backups
    match /backups/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 6: Get Configuration

1. Click the gear icon (⚙️) next to "Project Overview"
2. Select "Project settings"
3. Scroll down to "Your apps" section
4. Click the web icon (</>)
5. Register your app with a nickname
6. Copy the configuration object

## Step 7: Update Configuration Files

### Update `lib/firebase_options.dart`

Replace the placeholder values with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-actual-project.firebaseapp.com',
  storageBucket: 'your-actual-project.appspot.com',
  measurementId: 'your-actual-measurement-id',
);
```

### Update `web/index.html`

Replace the placeholder values in the Firebase config:

```javascript
const firebaseConfig = {
  apiKey: "your-actual-api-key",
  authDomain: "your-actual-project.firebaseapp.com",
  projectId: "your-actual-project-id",
  storageBucket: "your-actual-project.appspot.com",
  messagingSenderId: "your-actual-sender-id",
  appId: "your-actual-app-id",
  measurementId: "your-actual-measurement-id"
};
```

## Step 8: Install Dependencies

Run the following command to install Firebase dependencies:

```bash
flutter pub get
```

## Step 9: Test the Setup

1. Run your app: `flutter run -d chrome`
2. Try to create an account
3. Check Firebase Console to see if users are created
4. Verify data is being stored in Firestore

## Troubleshooting

### Common Issues

1. **"Firebase not initialized" error**
   - Ensure Firebase is initialized before running the app
   - Check that `firebase_options.dart` is properly configured

2. **Authentication not working**
   - Verify Email/Password authentication is enabled
   - Check security rules are not too restrictive

3. **Database access denied**
   - Ensure Firestore security rules allow authenticated users
   - Check that the user is properly authenticated

4. **Storage access denied**
   - Verify Storage security rules allow authenticated users
   - Check that the user ID matches the authenticated user

### Debug Mode

For development, you can temporarily use more permissive rules:

```javascript
// Firestore - Allow all authenticated users (DEV ONLY)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}

// Storage - Allow all authenticated users (DEV ONLY)
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ WARNING: Never use these permissive rules in production!**

## Production Considerations

1. **Security Rules**: Implement proper security rules before going live
2. **Authentication**: Consider adding additional sign-in methods (Google, Apple)
3. **Monitoring**: Set up Firebase Analytics and Crashlytics
4. **Backup**: Implement regular data backup strategies
5. **Cost Management**: Monitor Firebase usage and set up billing alerts

## Next Steps

After Firebase is set up, you can:

1. Add Google Sign-In authentication
2. Implement push notifications
3. Add real-time data synchronization
4. Set up automated backups
5. Implement user management features

## Support

If you encounter issues:

1. Check [Firebase Documentation](https://firebase.google.com/docs)
2. Review [FlutterFire Documentation](https://firebase.flutter.dev/)
3. Check Firebase Console for error logs
4. Verify your configuration matches the examples above
