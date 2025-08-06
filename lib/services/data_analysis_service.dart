import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/habit.dart';

class DataAnalysisService {
  // Calculate trend data for a habit over time
  Map<String, dynamic> calculateTrendData(Habit habit) {
    if (habit.completionDates.isEmpty) {
      return {
        'trend': 'No data',
        'percentageChange': 0.0,
        'isPositive': false,
        'dataPoints': <Map<String, dynamic>>[],
      };
    }

    // Sort dates
    final sortedDates = [...habit.completionDates]..sort();
    
    // Group by week
    final Map<String, int> weeklyData = {};
    for (var date in sortedDates) {
      // Get the start of the week (Monday)
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      final weekKey = DateFormat('yyyy-MM-dd').format(startOfWeek);
      
      if (weeklyData.containsKey(weekKey)) {
        weeklyData[weekKey] = weeklyData[weekKey]! + 1;
      } else {
        weeklyData[weekKey] = 1;
      }
    }

    // Convert to list of data points for charts
    final dataPoints = weeklyData.entries.map((entry) {
      return {
        'week': entry.key,
        'count': entry.value,
        'date': DateTime.parse(entry.key),
      };
    }).toList();
    
    // Sort by date
    dataPoints.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    
    // Calculate trend (comparing last two weeks if available)
    String trend = 'Stable';
    double percentageChange = 0.0;
    bool isPositive = false;
    
    if (dataPoints.length >= 2) {
      final currentWeekCount = dataPoints.last['count'] as int;
      final previousWeekCount = dataPoints[dataPoints.length - 2]['count'] as int;
      
      if (previousWeekCount > 0) {
        percentageChange = ((currentWeekCount - previousWeekCount) / previousWeekCount) * 100;
        isPositive = percentageChange > 0;
        
        if (percentageChange > 10) {
          trend = 'Strong Improvement';
        } else if (percentageChange > 0) {
          trend = 'Improving';
        } else if (percentageChange < -10) {
          trend = 'Significant Decline';
        } else if (percentageChange < 0) {
          trend = 'Declining';
        }
      } else if (currentWeekCount > 0) {
        trend = 'New Activity';
        isPositive = true;
        percentageChange = 100.0;
      }
    } else if (dataPoints.isNotEmpty) {
      trend = 'New Activity';
      isPositive = true;
    }
    
    return {
      'trend': trend,
      'percentageChange': percentageChange.abs().toStringAsFixed(1),
      'isPositive': isPositive,
      'dataPoints': dataPoints,
    };
  }

  // Calculate correlation between habits
  List<Map<String, dynamic>> calculateCorrelations(List<Habit> habits) {
    final correlations = <Map<String, dynamic>>[];
    
    if (habits.length < 2) return correlations;
    
    for (int i = 0; i < habits.length; i++) {
      for (int j = i + 1; j < habits.length; j++) {
        final habit1 = habits[i];
        final habit2 = habits[j];
        
        final correlation = _calculateHabitCorrelation(habit1, habit2);
        
        correlations.add({
          'habit1': habit1.name,
          'habit2': habit2.name,
          'correlation': correlation,
          'strength': _getCorrelationStrength(correlation),
          'isPositive': correlation > 0,
        });
      }
    }
    
    // Sort by correlation strength (absolute value)
    correlations.sort((a, b) => b['correlation'].abs().compareTo(a['correlation'].abs()));
    
    return correlations;
  }
  
  // Helper method to calculate correlation between two habits
  double _calculateHabitCorrelation(Habit habit1, Habit habit2) {
    // Get all unique dates from both habits
    final allDates = <DateTime>{};
    allDates.addAll(habit1.completionDates);
    allDates.addAll(habit2.completionDates);
    
    if (allDates.isEmpty) return 0.0;
    
    // Create a 30-day window for analysis
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 30));
    
    // Create daily completion maps for both habits
    final Map<String, bool> habit1Completions = {};
    final Map<String, bool> habit2Completions = {};
    
    // Initialize all days in the window
    for (int i = 0; i <= 30; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      habit1Completions[dateKey] = false;
      habit2Completions[dateKey] = false;
    }
    
    // Mark completion days
    for (var date in habit1.completionDates) {
      if (date.isAfter(startDate) && date.isBefore(today.add(const Duration(days: 1)))) {
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        habit1Completions[dateKey] = true;
      }
    }
    
    for (var date in habit2.completionDates) {
      if (date.isAfter(startDate) && date.isBefore(today.add(const Duration(days: 1)))) {
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        habit2Completions[dateKey] = true;
      }
    }
    
    // Calculate correlation coefficient (phi coefficient for binary data)
    int bothCompleted = 0;
    int habit1OnlyCompleted = 0;
    int habit2OnlyCompleted = 0;
    int neitherCompleted = 0;
    
    habit1Completions.forEach((date, habit1Completed) {
      final habit2Completed = habit2Completions[date] ?? false;
      
      if (habit1Completed && habit2Completed) {
        bothCompleted++;
      } else if (habit1Completed && !habit2Completed) {
        habit1OnlyCompleted++;
      } else if (!habit1Completed && habit2Completed) {
        habit2OnlyCompleted++;
      } else {
        neitherCompleted++;
      }
    });
    
    // Calculate phi coefficient
    final numerator = (bothCompleted * neitherCompleted) - (habit1OnlyCompleted * habit2OnlyCompleted);
    final denominator = math.sqrt(
      (bothCompleted + habit1OnlyCompleted).toDouble() *
      (bothCompleted + habit2OnlyCompleted).toDouble() *
      (habit1OnlyCompleted + neitherCompleted).toDouble() *
      (habit2OnlyCompleted + neitherCompleted).toDouble()
    );
    
    if (denominator == 0) return 0.0;
    return numerator / denominator;
  }
  
  // Helper to interpret correlation strength
  String _getCorrelationStrength(double correlation) {
    final abs = correlation.abs();
    
    if (abs >= 0.7) {
      return 'Strong';
    } else if (abs >= 0.4) {
      return 'Moderate';
    } else if (abs >= 0.2) {
      return 'Weak';
    } else {
      return 'None';
    }
  }
  
  // Helper for square root calculation
  double sqrt(double value) {
    return value <= 0 ? 0 : math.sqrt(value);
  }

  // Export habits data to CSV
  Future<void> exportHabitsToCSV(List<Habit> habits) async {
    try {
      // Create CSV data
      List<List<dynamic>> csvData = [];
      
      // Add header row
      csvData.add([
        'Habit Name',
        'Description',
        'Created Date',
        'Frequency',
        'Total Completions',
        'Completion Rate (%)',
        'Current Streak',
        'Category',
      ]);
      
      // Add data rows
      for (var habit in habits) {
        csvData.add([
          habit.name,
          habit.description,
          DateFormat('yyyy-MM-dd').format(habit.createdAt),
          habit.frequency,
          habit.totalCompletions,
          habit.completionRate.toStringAsFixed(1),
          habit.currentStreak,
          habit.category ?? 'Uncategorized',
        ]);
      }
      
      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);
      
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/habit_tracker_export.csv';
      
      // Write to file
      final File file = File(path);
      await file.writeAsString(csv);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(path)],
        subject: 'Habit Tracker Data Export',
      );
    } catch (e) {
      debugPrint('Error exporting CSV: $e');
      rethrow;
    }
  }

  // Export habits data to Excel
  Future<void> exportHabitsToExcel(List<Habit> habits) async {
    try {
      // Create Excel workbook
      final excel = Excel.createExcel();
      
      // Create sheets
      final summarySheet = excel['Summary'];
      final detailsSheet = excel['Habit Details'];
      final completionsSheet = excel['Completion Dates'];
      
      // Add headers to summary sheet
      final summaryHeaders = [
        'Habit Name',
        'Description',
        'Created Date',
        'Frequency',
        'Total Completions',
        'Completion Rate (%)',
        'Current Streak',
        'Category',
      ];
      
      for (var i = 0; i < summaryHeaders.length; i++) {
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = TextCellValue(summaryHeaders[i])
          ..cellStyle = CellStyle(bold: true);
      }
      
      // Add data to summary sheet
      for (var i = 0; i < habits.length; i++) {
        final habit = habits[i];
        final rowIndex = i + 1;
        
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(habit.name);
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(habit.description);
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(DateFormat('yyyy-MM-dd').format(habit.createdAt));
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(habit.frequency);
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = IntCellValue(habit.totalCompletions);
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = TextCellValue(habit.completionRate.toStringAsFixed(1));
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = IntCellValue(habit.currentStreak);
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = TextCellValue(habit.category ?? 'Uncategorized');
      }
      
      // Add detailed completion dates to completions sheet
      final completionHeaders = ['Habit Name', 'Completion Date'];
      for (var i = 0; i < completionHeaders.length; i++) {
        completionsSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = TextCellValue(completionHeaders[i])
          ..cellStyle = CellStyle(bold: true);
      }
      
      int rowIndex = 1;
      for (var habit in habits) {
        for (var date in habit.completionDates) {
          completionsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            ..value = TextCellValue(habit.name);
          completionsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            ..value = TextCellValue(DateFormat('yyyy-MM-dd').format(date));
          rowIndex++;
        }
      }
      
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/habit_tracker_export.xlsx';
      
      // Save the Excel file
      final List<int>? excelBytes = excel.encode();
      if (excelBytes != null) {
        final File file = File(path);
        await file.writeAsBytes(excelBytes);
        
        // Share the file
        await Share.shareXFiles(
          [XFile(path)],
          subject: 'Habit Tracker Data Export',
        );
      }
    } catch (e) {
      debugPrint('Error exporting Excel: $e');
      rethrow;
    }
  }
}