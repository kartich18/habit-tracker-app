// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart'; // Add this import
import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  String name;
  String description;
  DateTime createdAt;
  String frequency; // daily, weekly, etc.
  List<DateTime> completionDates;
  bool reminder;
  String reminderTime;
  int? goalCount;
  Duration? goalDuration;
  String? category;
  Color? categoryColor;

  Habit({
    String? id,
    required this.name,
    required this.description,
    required this.frequency,
    this.reminder = false,
    this.reminderTime = '08:00',
    List<DateTime>? completionDates,
    this.category,
    this.categoryColor,
  })  : id = id ?? const Uuid().v4(),
        createdAt = DateTime.now(),
        completionDates = completionDates ?? [];

  bool get isCompletedToday {
    final today = DateTime.now();
    return completionDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  int get currentStreak {
    if (completionDates.isEmpty) return 0;

    // Sort dates in ascending order
    final sortedDates = [...completionDates]..sort((a, b) => a.compareTo(b));

    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    // Check if the habit was completed today or yesterday
    bool completedRecently = false;
    for (var date in sortedDates.reversed) {
      final habitDate = DateTime(date.year, date.month, date.day);
      if (habitDate
          .isAtSameMomentAs(DateTime(today.year, today.month, today.day))) {
        completedRecently = true;
        break;
      } else if (habitDate.isAtSameMomentAs(
          DateTime(yesterday.year, yesterday.month, yesterday.day))) {
        completedRecently = true;
        break;
      } else {
        break;
      }
    }

    if (!completedRecently) return 0;

    // Calculate streak
    int streak = 1;
    DateTime previousDate = sortedDates.last;

    for (int i = sortedDates.length - 2; i >= 0; i--) {
      final currentDate = sortedDates[i];
      final difference = previousDate.difference(currentDate).inDays;

      if (difference == 1) {
        streak++;
        previousDate = currentDate;
      } else if (difference > 1) {
        break;
      }
    }

    return streak;
  }

  int get weeklyStreak {
    if (completionDates.isEmpty) return 0;

    final sortedDates = [...completionDates]..sort((a, b) => a.compareTo(b));
    int streak = 0;
    DateTime? lastWeek;

    for (var date in sortedDates.reversed) {
      final weekStart =
          DateTime(date.year, date.month, date.day - date.weekday);

      if (lastWeek == null || weekStart.difference(lastWeek).inDays == 7) {
        streak++;
        lastWeek = weekStart;
      } else {
        break;
      }
    }
    return streak;
  }

  int get monthlyStreak {
    if (completionDates.isEmpty) return 0;

    final sortedDates = [...completionDates]..sort((a, b) => a.compareTo(b));
    int streak = 0;
    DateTime? lastMonth;

    for (var date in sortedDates.reversed) {
      final monthStart = DateTime(date.year, date.month);

      if (lastMonth == null ||
          (monthStart.year == lastMonth.year &&
              monthStart.month == lastMonth.month + 1) ||
          (monthStart.year == lastMonth.year + 1 &&
              monthStart.month == 1 &&
              lastMonth.month == 12)) {
        streak++;
        lastMonth = monthStart;
      } else {
        break;
      }
    }
    return streak;
  }

  void markAsCompleted() {
    final today = DateTime.now();
    if (!isCompletedToday) {
      completionDates.add(today);
    }
  }

  void unmarkAsCompleted() {
    final today = DateTime.now();
    completionDates.removeWhere((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  bool get isGoalAchieved {
    if (goalCount != null) {
      return completionDates.length >= goalCount!;
    }
    return false;
  }

  double get completionPercentage {
    if (goalCount != null && goalCount! > 0) {
      return completionDates.length / goalCount!;
    }
    return 0.0;
  }

  String get progressStatus {
    if (completionPercentage >= 1.0) {
      return 'Goal Achieved!';
    } else if (completionPercentage >= 0.75) {
      return 'Almost There!';
    } else if (completionPercentage >= 0.5) {
      return 'Halfway Done';
    } else if (completionPercentage > 0.0) {
      return 'Getting Started';
    }
    return 'Not Started';
  }

  Map<DateTime, bool> get completionCalendar {
    final calendar = <DateTime, bool>{};
    final now = DateTime.now();

    for (var i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      calendar[date] = completionDates.contains(date);
    }

    return calendar;
  }

  // Update toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'frequency': frequency,
      'completionDates':
          completionDates.map((date) => date.toIso8601String()).toList(),
      'reminder': reminder,
      'reminderTime': reminderTime,
      'goalCount': goalCount,
      'goalDuration': goalDuration?.inSeconds,
      'category': category,
      'categoryColor': categoryColor?.value,
    };
  }

  // Update fromJson
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      frequency: json['frequency'],
      reminder: json['reminder'] ?? false,
      reminderTime: json['reminderTime'] ?? '08:00',
      completionDates: (json['completionDates'] as List)
          .map((d) => DateTime.parse(d))
          .toList(), // Changed from toSet() to toList()
    );
  }

  // Add these methods for statistics
  double get completionRate {
    if (completionDates.isEmpty) return 0.0;
    final totalDays = DateTime.now().difference(createdAt).inDays + 1;
    return (completionDates.length / totalDays) * 100;
  }

  int get totalCompletions => completionDates.length;
}
