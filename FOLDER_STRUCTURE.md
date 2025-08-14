# Habit Tracker App - Folder Structure Documentation

## 📁 **Project Organization Overview**

This document outlines the organized folder structure of the Habit Tracker Flutter application, designed for maintainability, scalability, and clear separation of concerns.

## 🏗️ **Root Structure**

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models
├── providers/                   # State management
├── services/                    # Business logic
├── utils/                       # Utility functions
├── widgets/                     # Reusable UI components
└── screens/                     # UI screens (organized by feature)
```

## 📱 **Screens Organization**

### **1. Authentication (`lib/screens/auth/`)**
- **Purpose**: User authentication and account management
- **Files**:
  - `login_screen.dart` - User login with Firebase
  - `signup_screen.dart` - User registration
  - `forgot_password_screen.dart` - Password reset
  - `index.dart` - Export all auth screens

### **2. Onboarding (`lib/screens/onboarding/`)**
- **Purpose**: User introduction and profile setup
- **Files**:
  - `onboarding_screen.dart` - App introduction and theme selection
  - `profile_creation_screen.dart` - User profile setup
  - `index.dart` - Export all onboarding screens

### **3. Main App (`lib/screens/main/`)**
- **Purpose**: Core application screens
- **Files**:
  - `home_screen.dart` - Main dashboard and habit overview
  - `profile_screen.dart` - User profile management
  - `index.dart` - Export all main screens

### **4. Habit Management (`lib/screens/habits/`)**
- **Purpose**: Habit creation, editing, and tracking
- **Files**:
  - `add_habit_screen.dart` - Create new habits
  - `habit_details_screen.dart` - View and edit habit details
  - `track_progress_screen.dart` - Track habit progress over time
  - `index.dart` - Export all habit screens

### **5. Analytics (`lib/screens/analytics/`)**
- **Purpose**: Data analysis, statistics, and reporting
- **Files**:
  - `analytics_screen.dart` - Comprehensive habit analytics
  - `statistics_screen.dart` - Statistical charts and insights
  - `data_export_screen.dart` - Export data to CSV/Excel
  - `index.dart` - Export all analytics screens

### **6. Entry Point (`lib/screens/`)**
- **Purpose**: Main navigation and routing
- **Files**:
  - `welcome_screen.dart` - App entry point with auth options
  - `index.dart` - Export all screen categories

## 🔧 **Services Organization (`lib/services/`)**

### **Business Logic Services**
- **`habit_service.dart`** - Basic habit CRUD operations (local storage)
- **`firebase_service.dart`** - Firebase integration (auth, database, storage)
- **`hybrid_habit_service.dart`** - Smart service combining local and cloud storage
- **`data_analysis_service.dart`** - Data processing and export functionality

## 📊 **Models Organization (`lib/models/`)**

### **Data Models**
- **`user.dart`** - User profile and authentication data
- **`habit.dart`** - Habit data structure and business logic

## 🎯 **Providers Organization (`lib/providers/`)**

### **State Management**
- **`theme_provider.dart`** - App theme and color management
- **`auth_provider.dart`** - Authentication state management

## 🧩 **Widgets Organization (`lib/widgets/`)**

### **Reusable UI Components**
- **`habit_list_item.dart`** - Individual habit display component

## 🛠️ **Utils Organization (`lib/utils/`)**

### **Utility Functions**
- **`storage_utils.dart`** - Local storage operations and data persistence

## 📋 **Import Patterns**

### **Using Index Files (Recommended)**
```dart
// Clean, organized imports
import 'package:habit_tracker/screens/index.dart';
import 'package:habit_tracker/services/index.dart';
import 'package:habit_tracker/models/index.dart';
```

### **Direct File Imports**
```dart
// For specific screens
import 'package:habit_tracker/screens/auth/login_screen.dart';
import 'package:habit_tracker/screens/habits/add_habit_screen.dart';
```

## 🔄 **Navigation Flow**

```
Welcome Screen
├── Authentication Flow
│   ├── Login → Home
│   ├── Signup → Home
│   └── Forgot Password
├── Onboarding Flow
│   ├── App Introduction
│   ├── Theme Selection
│   └── Profile Creation → Home
└── Guest Mode
    ├── Onboarding
    └── Profile Creation (Optional) → Home

Home Screen
├── Habit Management
│   ├── Add Habit
│   ├── Edit Habit
│   └── Track Progress
├── Analytics
│   ├── View Statistics
│   ├── Data Analysis
│   └── Export Data
└── Profile Management
```

## 📈 **Benefits of This Structure**

### **1. Scalability**
- Easy to add new features in appropriate categories
- Clear separation prevents feature overlap
- Modular design supports team development

### **2. Maintainability**
- Related functionality grouped together
- Easy to locate specific features
- Clear import paths reduce confusion

### **3. Code Organization**
- Logical grouping by functionality
- Consistent naming conventions
- Index files provide clean imports

### **4. Development Workflow**
- Developers can work on specific features
- Clear boundaries between different areas
- Easy to understand app architecture

## 🚀 **Adding New Features**

### **New Screen Category**
1. Create new folder in `lib/screens/`
2. Add `index.dart` for exports
3. Update main `lib/screens/index.dart`

### **New Service**
1. Add to `lib/services/`
2. Update `lib/services/index.dart`
3. Import where needed

### **New Model**
1. Add to `lib/models/`
2. Update `lib/models/index.dart`
3. Use in services and screens

## 📝 **Best Practices**

### **1. File Naming**
- Use snake_case for file names
- Descriptive names that indicate purpose
- Consistent with existing patterns

### **2. Import Organization**
- Use index files for clean imports
- Group related imports together
- Remove unused imports regularly

### **3. Folder Structure**
- Keep related functionality together
- Don't nest too deeply (max 3-4 levels)
- Use clear, descriptive folder names

### **4. Code Organization**
- One class per file (when possible)
- Group related methods together
- Use consistent formatting

## 🔍 **Troubleshooting**

### **Common Issues**
1. **Import Errors**: Check if file paths are correct after moving
2. **Missing Exports**: Ensure index.dart files export all necessary files
3. **Circular Dependencies**: Avoid importing files that create circular references

### **Verification Commands**
```bash
# Check for compilation errors
flutter analyze

# Check for unused imports
flutter analyze --no-fatal-infos

# Run tests to ensure functionality
flutter test
```

## 📚 **Additional Resources**

- **Flutter Documentation**: [flutter.dev](https://flutter.dev)
- **Dart Style Guide**: [dart.dev/guides/language/effective-dart/style](https://dart.dev/guides/language/effective-dart/style)
- **Provider Pattern**: [pub.dev/packages/provider](https://pub.dev/packages/provider)

---

*This structure is designed to grow with your application while maintaining clean, organized code that's easy to understand and maintain.*
