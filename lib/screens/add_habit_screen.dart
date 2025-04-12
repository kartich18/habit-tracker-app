// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _frequency = 'daily';
  bool _reminder = false;
  String _reminderTime = '08:00';
  final HabitService _habitService = HabitService();
  bool _isLoading = false;

  final List<String> _frequencies = [
    'daily',
    'weekly',
    'monthly',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final habit = Habit(
          name: _nameController.text,
          description: _descriptionController.text,
          frequency: _frequency,
          reminder: _reminder,
          reminderTime: _reminderTime,
        );

        final habits = await _habitService.loadHabits();
        await _habitService.addHabit(habit, habits);

        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context, true);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving habit: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      decoration: InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(MdiIcons.repeat), // replacing repeat
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
                      subtitle:
                          const Text('Get notified to complete this habit'),
                      value: _reminder,
                      onChanged: (bool value) {
                        setState(() {
                          _reminder = value;
                        });
                      },
                      secondary: Icon(MdiIcons.alarm), // replacing alarm
                    ),
                    if (_reminder) ...[
                      const SizedBox(height: 8),
                      ListTile(
                        title: const Text('Reminder Time'),
                        subtitle: Text(_reminderTime),
                        leading: Icon(
                            MdiIcons.clockOutline), // replacing access_time
                        trailing: Icon(MdiIcons.chevronRight,
                            size: 16), // replacing arrow_forward_ios
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
                    ElevatedButton.icon(
                      onPressed: _saveHabit,
                      icon: Icon(MdiIcons.contentSave), // replacing save
                      label: const Text('Save Habit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
