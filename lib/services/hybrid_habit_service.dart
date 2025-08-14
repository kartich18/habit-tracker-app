import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/storage_utils.dart';
import '../models/habit.dart';
import 'firebase_service.dart';

class HybridHabitService {
  final FirebaseService _firebaseService = FirebaseService();
  static const String _habitsKey = 'habits';
  static const String _lastSyncKey = 'lastSync';

  // Save habits to both local storage and Firebase (if authenticated)
  Future<void> saveHabits(List<Habit> habits, {String? userId}) async {
    // Always save locally first for offline access
    await _saveHabitsLocally(habits);
    
    // If user is authenticated, sync to Firebase
    if (userId != null) {
      try {
        await _firebaseService.saveHabits(userId, habits);
        await _updateLastSync();
      } catch (e) {
        debugPrint('Failed to sync to Firebase: $e');
        // Continue with local storage only
      }
    }
  }

  // Load habits from local storage first, then sync from Firebase if available
  Future<List<Habit>> loadHabits({String? userId}) async {
    // Load from local storage first
    List<Habit> habits = await _loadHabitsLocally();
    
    // If user is authenticated and we haven't synced recently, try to sync from Firebase
    if (userId != null && await _shouldSyncFromFirebase()) {
      try {
        final cloudHabits = await _firebaseService.loadHabits(userId);
        if (cloudHabits.isNotEmpty) {
          // Merge cloud data with local data, preferring cloud data
          habits = _mergeHabits(habits, cloudHabits);
          await _saveHabitsLocally(habits);
          await _updateLastSync();
        }
      } catch (e) {
        debugPrint('Failed to sync from Firebase: $e');
        // Continue with local data
      }
    }
    
    return habits;
  }

  // Add a new habit
  Future<void> addHabit(Habit habit, List<Habit> currentHabits, {String? userId}) async {
    final habits = [...currentHabits, habit];
    await saveHabits(habits, userId: userId);
  }

  // Update an existing habit
  Future<void> updateHabit(Habit updatedHabit, List<Habit> currentHabits, {String? userId}) async {
    final habits = currentHabits.map((habit) {
      if (habit.id == updatedHabit.id) {
        return updatedHabit;
      }
      return habit;
    }).toList();

    await saveHabits(habits, userId: userId);
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId, List<Habit> currentHabits, {String? userId}) async {
    final habits = currentHabits.where((habit) => habit.id != habitId).toList();
    await saveHabits(habits, userId: userId);
  }

  // Mark a habit as completed
  Future<void> markHabitAsCompleted(String habitId, List<Habit> currentHabits, {String? userId}) async {
    final habits = currentHabits.map((habit) {
      if (habit.id == habitId) {
        habit.markAsCompleted();
      }
      return habit;
    }).toList();

    await saveHabits(habits, userId: userId);
  }

  // Unmark a habit as completed
  Future<void> unmarkHabitAsCompleted(String habitId, List<Habit> currentHabits, {String? userId}) async {
    final habits = currentHabits.map((habit) {
      if (habit.id == habitId) {
        habit.unmarkAsCompleted();
      }
      return habit;
    }).toList();

    await saveHabits(habits, userId: userId);
  }

  // Sync all data to Firebase
  Future<void> syncToFirebase(String userId, List<Habit> habits) async {
    try {
      await _firebaseService.saveHabits(userId, habits);
      await _updateLastSync();
    } catch (e) {
      throw Exception('Failed to sync to Firebase: $e');
    }
  }

  // Sync all data from Firebase
  Future<List<Habit>> syncFromFirebase(String userId) async {
    try {
      final habits = await _firebaseService.loadHabits(userId);
      await _saveHabitsLocally(habits);
      await _updateLastSync();
      return habits;
    } catch (e) {
      throw Exception('Failed to sync from Firebase: $e');
    }
  }

  // Backup data to Firebase Storage
  Future<String> backupData(String userId, List<Habit> habits) async {
    try {
      final data = jsonEncode(habits.map((h) => h.toJson()).toList());
      return await _firebaseService.backupData(userId, data);
    } catch (e) {
      throw Exception('Failed to backup data: $e');
    }
  }

  // Restore data from Firebase Storage
  Future<List<Habit>> restoreData(String backupUrl) async {
    try {
      final data = await _firebaseService.restoreData(backupUrl);
      final habitsJson = jsonDecode(data) as List<dynamic>;
      return habitsJson
          .map((json) => Habit.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to restore data: $e');
    }
  }

  // Check if we should sync from Firebase (avoid too frequent syncs)
  Future<bool> _shouldSyncFromFirebase() async {
    final lastSync = await StorageUtils.getData(_lastSyncKey);
    if (lastSync == null) return true;
    
    try {
      final lastSyncTime = DateTime.parse(lastSync);
      final now = DateTime.now();
      // Sync if it's been more than 5 minutes since last sync
      return now.difference(lastSyncTime).inMinutes > 5;
    } catch (e) {
      return true;
    }
  }

  // Update last sync timestamp
  Future<void> _updateLastSync() async {
    await StorageUtils.saveData(_lastSyncKey, DateTime.now().toIso8601String());
  }

  // Save habits locally
  Future<void> _saveHabitsLocally(List<Habit> habits) async {
    final habitsJson = habits.map((habit) => habit.toJson()).toList();
    await StorageUtils.saveData(_habitsKey, jsonEncode(habitsJson));
  }

  // Load habits locally
  Future<List<Habit>> _loadHabitsLocally() async {
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
      debugPrint('Error loading habits locally: $e');
      return [];
    }
  }

  // Merge local and cloud habits, preferring cloud data for conflicts
  List<Habit> _mergeHabits(List<Habit> localHabits, List<Habit> cloudHabits) {
    final Map<String, Habit> mergedMap = {};
    
    // Add local habits first
    for (var habit in localHabits) {
      mergedMap[habit.id] = habit;
    }
    
    // Override with cloud habits (preferring cloud data)
    for (var habit in cloudHabits) {
      mergedMap[habit.id] = habit;
    }
    
    return mergedMap.values.toList();
  }

  // Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final lastSync = await StorageUtils.getData(_lastSyncKey);
    final localHabits = await _loadHabitsLocally();
    
    return {
      'lastSync': lastSync,
      'localHabitCount': localHabits.length,
      'isOnline': true, // You can implement actual network check here
    };
  }
}
