// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class TrackProgressScreen extends StatefulWidget {
  const TrackProgressScreen({super.key});

  @override
  _TrackProgressScreenState createState() => _TrackProgressScreenState();
}

class _TrackProgressScreenState extends State<TrackProgressScreen> {
  final HabitService _habitService = HabitService();
  List<Habit> _habits = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
    });

    final habits = await _habitService.loadHabits();
    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  Map<DateTime, List<Habit>> _getHabitsByDay() {
    final Map<DateTime, List<Habit>> habitsMap = {};

    for (var habit in _habits) {
      for (var date in habit.completionDates) {
        final day = DateTime(date.year, date.month, date.day);
        habitsMap.putIfAbsent(day, () => []).add(habit);
      }
    }

    return habitsMap;
  }

  List<PieChartSectionData> _getPieChartData() {
    final completedCount = _habits.where((h) => h.isCompletedToday).length;
    final pendingCount = _habits.length - completedCount;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: completedCount.toDouble(),
        title: '$completedCount',
        radius: 40,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: pendingCount.toDouble(),
        title: '$pendingCount',
        radius: 40,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final habitsByDay = _getHabitsByDay();
    final selectedHabits =
        _selectedDay != null ? habitsByDay[_selectedDay] : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Progress'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendar Section
                Card(
                  margin: const EdgeInsets.all(8),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.now(),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) {
                      return habitsByDay[day] ?? [];
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Pie Chart Section
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Today\'s Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: _getPieChartData(),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Selected Day Habits
                if (_selectedDay != null && selectedHabits != null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedHabits.length,
                      itemBuilder: (context, index) {
                        final habit = selectedHabits[index];
                        return ListTile(
                          title: Text(habit.name),
                          subtitle: Text(habit.description),
                          trailing: const Icon(Icons.check_circle,
                              color: Colors.green),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
