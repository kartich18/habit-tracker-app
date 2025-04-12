import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/storage_utils.dart';
import '../models/habit.dart';

class HabitService {
  static const String _habitsKey = 'habits';

  // Save habits to SharedPreferences
  Future<void> saveHabits(List<Habit> habits) async {
    final habitsJson = habits.map((habit) => habit.toJson()).toList();
    await StorageUtils.saveData(_habitsKey, jsonEncode(habitsJson));
  }

  Future<List<Habit>> loadHabits() async {
    try {
      final habitsString = await StorageUtils.getData(_habitsKey);
      if (habitsString == null || habitsString.isEmpty) {
        return [];
      }

      final habitsJson = jsonDecode(habitsString) as List<dynamic>;
      return habitsJson
          .map((json) => Habit.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading habits: $e');
      return [];
    }
  }

  // Add a new habit and save
  Future<void> addHabit(Habit habit, List<Habit> currentHabits) async {
    final habits = [...currentHabits, habit];
    await saveHabits(habits);
  }

  // Update an existing habit and save
  Future<void> updateHabit(
      Habit updatedHabit, List<Habit> currentHabits) async {
    final habits = currentHabits.map((habit) {
      if (habit.id == updatedHabit.id) {
        return updatedHabit;
      }
      return habit;
    }).toList();

    await saveHabits(habits);
  }

  // Delete a habit and save
  Future<void> deleteHabit(String habitId, List<Habit> currentHabits) async {
    final habits = currentHabits.where((habit) => habit.id != habitId).toList();
    await saveHabits(habits);
  }

  // Mark a habit as completed for today
  Future<void> markHabitAsCompleted(
      String habitId, List<Habit> currentHabits) async {
    final habits = currentHabits.map((habit) {
      if (habit.id == habitId) {
        habit.markAsCompleted();
      }
      return habit;
    }).toList();

    await saveHabits(habits);
  }

  // Unmark a habit as completed for today
  Future<void> unmarkHabitAsCompleted(
      String habitId, List<Habit> currentHabits) async {
    final habits = currentHabits.map((habit) {
      if (habit.id == habitId) {
        habit.unmarkAsCompleted();
      }
      return habit;
    }).toList();

    await saveHabits(habits);
  }
}
