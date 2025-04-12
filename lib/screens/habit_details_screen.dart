// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  _HabitDetailsScreenState createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  late Habit _habit;
  final HabitService _habitService = HabitService();
  bool _isLoading = false;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _frequency;
  late bool _reminder;
  late String _reminderTime;

  final List<String> _frequencies = [
    'daily',
    'weekly',
    'monthly',
  ];

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _nameController = TextEditingController(text: _habit.name);
    _descriptionController = TextEditingController(text: _habit.description);
    _frequency = _habit.frequency;
    _reminder = _habit.reminder;
    _reminderTime = _habit.reminderTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _toggleHabitCompletion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final habits = await _habitService.loadHabits();
      if (_habit.isCompletedToday) {
        await _habitService.unmarkHabitAsCompleted(_habit.id, habits);
      } else {
        await _habitService.markHabitAsCompleted(_habit.id, habits);
      }

      // Reload the habit
      final updatedHabits = await _habitService.loadHabits();
      final updatedHabit = updatedHabits.firstWhere((h) => h.id == _habit.id);

      setState(() {
        _habit = updatedHabit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating habit: $e')),
      );
    }
  }

  Future<void> _updateHabit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create updated habit
        final updatedHabit = Habit(
          id: _habit.id,
          name: _nameController.text,
          description: _descriptionController.text,
          frequency: _frequency,
          reminder: _reminder,
          reminderTime: _reminderTime,
          completionDates: _habit.completionDates,
        );

        final habits = await _habitService.loadHabits();
        await _habitService.updateHabit(updatedHabit, habits);

        // Reload the habit
        final updatedHabits = await _habitService.loadHabits();
        final reloadedHabit =
            updatedHabits.firstWhere((h) => h.id == _habit.id);

        setState(() {
          _habit = reloadedHabit;
          _isLoading = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit updated successfully')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating habit: $e')),
        );
      }
    }
  }

  Widget _buildProgressChart() {
    // Get the last 7 days
    final now = DateTime.now();
    final dates = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day - 6 + index);
    });

    // Check if each date is in the completion dates
    final completedDays = dates.map((date) {
      return _habit.completionDates.any((completionDate) =>
          completionDate.year == date.year &&
          completionDate.month == date.month &&
          completionDate.day == date.day);
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1,
          barTouchData: BarTouchData(
            enabled: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < 7) {
                    final date = dates[index];
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        DateFormat('E').format(date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SideTitleWidget(
                    axisSide: AxisSide.bottom,
                    child: Text(''),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: completedDays[index] ? 1 : 0,
                  color: completedDays[index]
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDetailsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak and completion status
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.orange, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          '${_habit.currentStreak}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Text('Current Streak'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // In status icons
                        Icon(
                          _habit.isCompletedToday
                              ? MdiIcons.checkCircle // replacing check_circle
                              : MdiIcons
                                  .clockOutline, // replacing pending_actions
                          color: _habit.isCompletedToday
                              ? Colors.green
                              : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _habit.isCompletedToday ? 'Completed' : 'Pending',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('Today'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Habit details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.repeat),
                    title: const Text('Frequency'),
                    subtitle: Text(
                      _habit.frequency[0].toUpperCase() +
                          _habit.frequency.substring(1),
                    ),
                  ),
                  if (_habit.reminder) ...[
                    ListTile(
                      leading: const Icon(Icons.alarm),
                      title: const Text('Reminder'),
                      subtitle: Text(_habit.reminderTime),
                    ),
                  ],
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Created'),
                    subtitle: Text(
                        DateFormat('MMM d, yyyy').format(_habit.createdAt)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.check),
                    title: const Text('Total Completions'),
                    subtitle: Text('${_habit.completionDates.length} times'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress chart
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    'Last 7 Days',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildProgressChart(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleHabitCompletion,
                  icon:
                      Icon(_habit.isCompletedToday ? Icons.close : Icons.check),
                  label: Text(_habit.isCompletedToday
                      ? 'Unmark Today'
                      : 'Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _habit.isCompletedToday ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a habit name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              items: _frequencies.map((String frequency) {
                return DropdownMenuItem<String>(
                  value: frequency,
                  child: Text(
                    frequency[0].toUpperCase() + frequency.substring(1),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _frequency = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Set Reminder'),
              subtitle: const Text('Get notified to complete this habit'),
              value: _reminder,
              onChanged: (bool value) {
                setState(() {
                  _reminder = value;
                });
              },
              secondary: const Icon(Icons.alarm),
            ),
            if (_reminder) ...[
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Reminder Time'),
                subtitle: Text(_reminderTime),
                leading: const Icon(Icons.access_time),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(_reminderTime.split(':')[0]),
                      minute: int.parse(_reminderTime.split(':')[1]),
                    ),
                  );
                  if (picked != null) {
                    setState(() {
                      _reminderTime =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                      });
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _updateHabit,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                  ),
                ),
              ],
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
        title: Text(_habit.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Reset form values if canceling edit
                  _nameController.text = _habit.name;
                  _descriptionController.text = _habit.description;
                  _frequency = _habit.frequency;
                  _reminder = _habit.reminder;
                  _reminderTime = _habit.reminderTime;
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEditing
              ? _buildEditForm()
              : _buildDetailsView(),
    );
  }
}
