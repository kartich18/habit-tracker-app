// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartSeries;
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../services/data_analysis_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  final HabitService _habitService = HabitService();
  final DataAnalysisService _dataAnalysisService = DataAnalysisService();
  List<Habit> _habits = [];
  bool _isLoading = true;
  late TabController _tabController;
  
  // For category distribution
  final Map<String, int> _categoryDistribution = {};
  List<Map<String, dynamic>> _categoryData = [];
  
  // For weekly activity
  final Map<String, int> _weekdayDistribution = {};
  List<Map<String, dynamic>> _weekdayData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHabits();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
    });
    
    final habits = await _habitService.loadHabits();
    
    // Process data for visualizations
    _processCategoryDistribution(habits);
    _processWeekdayDistribution(habits);
    
    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }
  
  void _processCategoryDistribution(List<Habit> habits) {
    _categoryDistribution.clear();
    
    for (var habit in habits) {
      final category = habit.category ?? 'Uncategorized';
      _categoryDistribution[category] = (_categoryDistribution[category] ?? 0) + 1;
    }
    
    // Convert to list for chart
    _categoryData = _categoryDistribution.entries.map((entry) {
      return {
        'category': entry.key,
        'count': entry.value,
      };
    }).toList();
  }
  
  void _processWeekdayDistribution(List<Habit> habits) {
    // Initialize weekday counts (1 = Monday, 7 = Sunday)
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    // Initialize with zero counts
    for (var day in weekdays) {
      _weekdayDistribution[day] = 0;
    }
    
    for (var habit in habits) {
      for (var date in habit.completionDates) {
        // Get weekday (1-7) and convert to name
        final dayName = weekdays[date.weekday - 1];
        _weekdayDistribution[dayName] = (_weekdayDistribution[dayName] ?? 0) + 1;
      }
    }
    
    // Convert to list for chart
    _weekdayData = weekdays.asMap().entries.map((entry) {
      return {
        'day': entry.value,
        'dayNumber': entry.key + 1,
        'count': _weekdayDistribution[entry.value] ?? 0,
      };
    }).toList();
  }

  Widget _buildCompletionRateChart() {
    if (_habits.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No habits available'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Completion Rates'),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barGroups: _habits
                      .map((habit) => BarChartGroupData(
                            x: _habits.indexOf(habit),
                            barRods: [
                              BarChartRodData(
                                toY: habit.completionRate,
                                color: habit.categoryColor ?? Colors.blue,
                              ),
                            ],
                          ))
                      .toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _habits.length) {
                            final name = _habits[value.toInt()].name;
                            return Text(
                              name.length > 3 ? name.substring(0, 3) : name,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionChart() {
    if (_categoryData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No category data available'),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Habits by Category', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CircularSeries>[
                  PieSeries<Map<String, dynamic>, String>(
                    dataSource: _categoryData,
                    xValueMapper: (Map<String, dynamic> data, _) => data['category'] as String,
                    yValueMapper: (Map<String, dynamic> data, _) => data['count'] as int,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                    enableTooltip: true,
                    explode: true,
                    explodeIndex: 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeekdayActivityChart() {
    if (_weekdayData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No weekday activity data available'),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Activity by Day of Week', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Completions'),
                  labelFormat: '{value}',
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<Map<String, dynamic>, String>>[
                  ColumnSeries<Map<String, dynamic>, String>(
                    dataSource: _weekdayData,
                    xValueMapper: (Map<String, dynamic> data, _) => data['day'] as String,
                    yValueMapper: (Map<String, dynamic> data, _) => data['count'] as int,
                    name: 'Completions',
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        Theme.of(context).colorScheme.primary,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHabitCompletionTimeline() {
    if (_habits.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No habits available'),
          ),
        ),
      );
    }
    
    // Prepare data for timeline
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    
    // Create a list of all dates in the last 30 days
    final List<DateTime> dates = [];
    for (int i = 0; i < 30; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }
    
    // Create timeline data points
    final List<Map<String, dynamic>> timelineData = [];
    
    for (var date in dates) {
      int completions = 0;
      for (var habit in _habits) {
        if (habit.completionDates.any((d) => 
            d.year == date.year && 
            d.month == date.month && 
            d.day == date.day)) {
          completions++;
        }
      }
      
      timelineData.add({
        'date': date,
        'completions': completions,
      });
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('30-Day Completion Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat('MMM d'),
                  intervalType: DateTimeIntervalType.days,
                  interval: 5,
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Habits Completed'),
                  labelFormat: '{value}',
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<Map<String, dynamic>, DateTime>>[
                  SplineAreaSeries<Map<String, dynamic>, DateTime>(
                    dataSource: timelineData,
                    xValueMapper: (Map<String, dynamic> data, _) => data['date'] as DateTime,
                    yValueMapper: (Map<String, dynamic> data, _) => data['completions'] as int,
                    name: 'Completions',
                    markerSettings: const MarkerSettings(isVisible: true),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Completion Rates'),
            Tab(text: 'Categories'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Completion Rates
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildCompletionRateChart(),
                      const SizedBox(height: 16),
                      _buildWeekdayActivityChart(),
                    ],
                  ),
                ),
                
                // Tab 2: Categories
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildCategoryDistributionChart(),
                      const SizedBox(height: 16),
                      // Add more category-related charts here
                    ],
                  ),
                ),
                
                // Tab 3: Trends
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHabitCompletionTimeline(),
                      const SizedBox(height: 16),
                      // Add more trend-related charts here
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
