import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../services/data_analysis_service.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  _DataExportScreenState createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  final HabitService _habitService = HabitService();
  final DataAnalysisService _dataAnalysisService = DataAnalysisService();
  List<Habit> _habits = [];
  bool _isLoading = true;
  bool _isExporting = false;
  String? _exportError;
  
  // Export options
  bool _includeCompletionDates = true;
  bool _includeStreakData = true;
  bool _includeAllHabits = true;
  List<String> _selectedHabitIds = [];
  String _exportFormat = 'csv'; // 'csv' or 'excel'

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
      // Initialize selected habits
      _selectedHabitIds = habits.map((h) => h.id).toList();
    });
  }

  Future<void> _exportData() async {
    if (_habits.isEmpty) {
      setState(() {
        _exportError = 'No habits to export';
      });
      return;
    }

    setState(() {
      _isExporting = true;
      _exportError = null;
    });

    try {
      // Filter habits if not including all
      final habitsToExport = _includeAllHabits
          ? _habits
          : _habits.where((h) => _selectedHabitIds.contains(h.id)).toList();

      if (_exportFormat == 'csv') {
        await _dataAnalysisService.exportHabitsToCSV(habitsToExport);
      } else {
        await _dataAnalysisService.exportHabitsToExcel(habitsToExport);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_exportFormat.toUpperCase()} export successful')),
        );
      }
    } catch (e) {
      setState(() {
        _exportError = 'Export failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
              ? const Center(child: Text('No habits to export'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExportFormatSelector(),
                      const SizedBox(height: 24),
                      _buildExportOptionsCard(),
                      const SizedBox(height: 24),
                      if (!_includeAllHabits) ...[                        
                        _buildHabitSelector(),
                        const SizedBox(height: 24),
                      ],
                      _buildExportButton(),
                      if (_exportError != null) ...[                        
                        const SizedBox(height: 16),
                        Text(
                          _exportError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildExportFormatSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Format',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('CSV'),
                    subtitle: const Text('Simple spreadsheet format'),
                    value: 'csv',
                    groupValue: _exportFormat,
                    onChanged: (value) {
                      setState(() {
                        _exportFormat = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Excel'),
                    subtitle: const Text('Multiple sheets with details'),
                    value: 'excel',
                    groupValue: _exportFormat,
                    onChanged: (value) {
                      setState(() {
                        _exportFormat = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include Completion Dates'),
              subtitle: const Text('Export all individual completion dates'),
              value: _includeCompletionDates,
              onChanged: (value) {
                setState(() {
                  _includeCompletionDates = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Include Streak Data'),
              subtitle: const Text('Export current and best streak information'),
              value: _includeStreakData,
              onChanged: (value) {
                setState(() {
                  _includeStreakData = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Include All Habits'),
              subtitle: const Text('When disabled, you can select specific habits'),
              value: _includeAllHabits,
              onChanged: (value) {
                setState(() {
                  _includeAllHabits = value;
                  if (value) {
                    _selectedHabitIds = _habits.map((h) => h.id).toList();
                  }
                });
              },
            ),
          ],
        ),
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
            Text(
              'Select Habits to Export',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return CheckboxListTile(
                  title: Text(habit.name),
                  subtitle: Text(
                    '${habit.totalCompletions} completions · Created ${DateFormat('MMM d, yyyy').format(habit.createdAt)}',
                  ),
                  value: _selectedHabitIds.contains(habit.id),
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        _selectedHabitIds.add(habit.id);
                      } else {
                        _selectedHabitIds.remove(habit.id);
                      }
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedHabitIds = [];
                    });
                  },
                  child: const Text('Deselect All'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedHabitIds = _habits.map((h) => h.id).toList();
                    });
                  },
                  child: const Text('Select All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isExporting ? null : _exportData,
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.file_download),
        label: Text(_isExporting
            ? 'Exporting...'
            : 'Export as ${_exportFormat.toUpperCase()}'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}