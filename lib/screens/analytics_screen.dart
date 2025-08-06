import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartSeries;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../services/data_analysis_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  final HabitService _habitService = HabitService();
  final DataAnalysisService _dataAnalysisService = DataAnalysisService();
  List<Habit> _habits = [];
  bool _isLoading = true;
  late TabController _tabController;
  Habit? _selectedHabit;
  Map<String, dynamic>? _trendData;
  List<Map<String, dynamic>> _correlations = [];

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
    
    if (mounted) {
      setState(() {
        _habits = habits;
        _isLoading = false;
        if (habits.isNotEmpty) {
          _selectedHabit = habits.first;
          _updateTrendData();
          _updateCorrelations();
        }
      });
    }
  }

  void _updateTrendData() {
    if (_selectedHabit != null && mounted) {
      setState(() {
        _trendData = _dataAnalysisService.calculateTrendData(_selectedHabit!);
      });
    }
  }

  void _updateCorrelations() {
    if (mounted) {
      setState(() {
        _correlations = _dataAnalysisService.calculateCorrelations(_habits);
      });
    }
  }

  void _exportData(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export as CSV'),
            onTap: () async {
              Navigator.pop(context);
              try {
                await _dataAnalysisService.exportHabitsToCSV(_habits);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CSV export successful')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text('Export as Excel'),
            onTap: () async {
              Navigator.pop(context);
              try {
                await _dataAnalysisService.exportHabitsToExcel(_habits);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Excel export successful')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _habits.isEmpty ? null : () => _exportData(context),
            tooltip: 'Export Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Trends'),
            Tab(text: 'Correlations'),
            Tab(text: 'Performance'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
              ? const Center(child: Text('No habits to analyze yet'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTrendsTab(),
                    _buildCorrelationsTab(),
                    _buildPerformanceTab(),
                  ],
                ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHabitSelector(),
          const SizedBox(height: 16),
          if (_selectedHabit != null && _trendData != null) ...[            
            _buildTrendCard(),
            const SizedBox(height: 16),
            _buildTrendChart(),
          ],
        ],
      ),
    );
  }

  Widget _buildHabitSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Habit to Analyze', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Habit>(
              value: _selectedHabit,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: _habits.map((habit) {
                return DropdownMenuItem<Habit>(
                  value: habit,
                  child: Text(habit.name),
                );
              }).toList(),
              onChanged: (Habit? newValue) {
                setState(() {
                  _selectedHabit = newValue;
                  _updateTrendData();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard() {
    final trend = _trendData!['trend'] as String;
    final percentageChange = _trendData!['percentageChange'] as String;
    final isPositive = _trendData!['isPositive'] as bool;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Analysis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 48,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trend,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (trend != 'No data' && trend != 'Stable')
                        Text(
                          '${isPositive ? '+' : '-'}$percentageChange% from previous period',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    final dataPoints = _trendData!['dataPoints'] as List<dynamic>;
    
    if (dataPoints.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Not enough data to display trend chart'),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Completion Trend',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat('MMM d'),
                  intervalType: DateTimeIntervalType.days,
                  interval: 7,
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Completions'),
                  majorGridLines: const MajorGridLines(width: 0.5),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<Map<String, dynamic>, DateTime>>[
                  LineSeries<Map<String, dynamic>, DateTime>(
                    dataSource: dataPoints.cast<Map<String, dynamic>>(),
                    xValueMapper: (Map<String, dynamic> data, _) => data['date'] as DateTime,
                    yValueMapper: (Map<String, dynamic> data, _) => data['count'] as int,
                    name: 'Completions',
                    markerSettings: const MarkerSettings(isVisible: true),
                    dataLabelSettings: const DataLabelSettings(isVisible: false),
                    enableTooltip: true,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  AreaSeries<Map<String, dynamic>, DateTime>(
                    dataSource: dataPoints.cast<Map<String, dynamic>>(),
                    xValueMapper: (Map<String, dynamic> data, _) => data['date'] as DateTime,
                    yValueMapper: (Map<String, dynamic> data, _) => data['count'] as int,
                    name: 'Trend',
                    borderColor: Theme.of(context).colorScheme.primary,
                    borderWidth: 2,
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

  Widget _buildCorrelationsTab() {
    if (_correlations.isEmpty) {
      return const Center(
        child: Text('Need at least two habits to analyze correlations'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _correlations.length,
      itemBuilder: (context, index) {
        final correlation = _correlations[index];
        final strength = correlation['strength'] as String;
        final isPositive = correlation['isPositive'] as bool;
        final correlationValue = correlation['correlation'] as double;
        
        Color strengthColor;
        if (strength == 'Strong') {
          strengthColor = isPositive ? Colors.green : Colors.red;
        } else if (strength == 'Moderate') {
          strengthColor = isPositive ? Colors.green.shade300 : Colors.orange;
        } else {
          strengthColor = Colors.grey;
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${correlation['habit1']} & ${correlation['habit2']}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: strengthColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$strength ${isPositive ? 'Positive' : 'Negative'}',
                        style: TextStyle(color: strengthColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SfLinearGauge(
                  minimum: -1,
                  maximum: 1,
                  interval: 0.5,
                  minorTicksPerInterval: 4,
                  axisLabelStyle: const TextStyle(fontSize: 12),
                  axisTrackStyle: const LinearAxisTrackStyle(thickness: 1),
                  markerPointers: [
                    LinearShapePointer(
                      value: correlationValue,
                      color: strengthColor,
                      width: 16,
                      height: 16,
                      shapeType: LinearShapePointerType.diamond,
                    ),
                  ],
                  ranges: const [
                    LinearGaugeRange(
                      startValue: -1,
                      endValue: -0.7,
                      color: Colors.red,
                      startWidth: 8,
                      endWidth: 8,
                    ),
                    LinearGaugeRange(
                      startValue: -0.7,
                      endValue: -0.4,
                      color: Colors.orange,
                      startWidth: 8,
                      endWidth: 8,
                    ),
                    LinearGaugeRange(
                      startValue: -0.4,
                      endValue: 0.4,
                      color: Colors.grey,
                      startWidth: 8,
                      endWidth: 8,
                    ),
                    LinearGaugeRange(
                      startValue: 0.4,
                      endValue: 0.7,
                      color: Colors.lightGreen,
                      startWidth: 8,
                      endWidth: 8,
                    ),
                    LinearGaugeRange(
                      startValue: 0.7,
                      endValue: 1,
                      color: Colors.green,
                      startWidth: 8,
                      endWidth: 8,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isPositive
                      ? 'These habits tend to be completed together.'
                      : 'When one habit is completed, the other tends not to be.',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceTab() {
    if (_habits.isEmpty) {
      return const Center(child: Text('No habits to analyze'));
    }
    
    // Sort habits by completion rate
    final sortedHabits = [..._habits];
    sortedHabits.sort((a, b) => b.completionRate.compareTo(a.completionRate));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallPerformanceCard(),
          const SizedBox(height: 16),
          _buildHabitPerformanceChart(sortedHabits),
          const SizedBox(height: 16),
          _buildStreakLeaderboard(sortedHabits),
        ],
      ),
    );
  }

  Widget _buildOverallPerformanceCard() {
    // Calculate overall stats
    int totalCompletions = 0;
    int totalHabits = _habits.length;
    double averageCompletionRate = 0;
    
    for (var habit in _habits) {
      totalCompletions += habit.totalCompletions;
      averageCompletionRate += habit.completionRate;
    }
    
    if (totalHabits > 0) {
      averageCompletionRate /= totalHabits;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Habits', totalHabits.toString()),
                _buildStatItem('Total Completions', totalCompletions.toString()),
                _buildStatItem('Avg. Completion Rate', '${averageCompletionRate.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildHabitPerformanceChart(List<Habit> sortedHabits) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Performance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Completion Rate (%)'),
                  majorGridLines: const MajorGridLines(width: 0.5),
                  maximum: 100,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<Habit, String>>[
                  BarSeries<Habit, String>(
                    dataSource: sortedHabits,
                    xValueMapper: (Habit habit, _) => habit.name,
                    yValueMapper: (Habit habit, _) => habit.completionRate,
                    name: 'Completion Rate',
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.outer,
                    ),
                    pointColorMapper: (Habit habit, _) => habit.categoryColor ?? Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakLeaderboard(List<Habit> habits) {
    // Sort by current streak
    final streakSorted = [...habits];
    streakSorted.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Streak Leaderboard',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: streakSorted.length > 5 ? 5 : streakSorted.length,
              itemBuilder: (context, index) {
                final habit = streakSorted[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: habit.categoryColor ?? Theme.of(context).colorScheme.primary,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(habit.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.currentStreak} days',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}