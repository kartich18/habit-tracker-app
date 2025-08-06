// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import 'add_habit_screen.dart';
import 'habit_details_screen.dart';
import '../widgets/habit_list_item.dart';
import 'track_progress_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'profile_screen.dart';
import '../utils/storage_utils.dart';
import 'dart:convert';
import 'analytics_screen.dart';
import 'statistics_screen.dart';
import 'data_export_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _loadHabits();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = await StorageUtils.getUser();
    if (user != null) {
      setState(() {
        _userName = user.name;
      });
    }
  }

  Widget _buildEmptyState() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello, ${_userName.isNotEmpty ? _userName : 'there'}! 👋',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // In _buildEmptyState method, replace the sentiment_dissatisfied icon
                  Icon(MdiIcons.emoticonSadOutline,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No habits yet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add a new habit to start tracking',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddHabit(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Habit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  final HabitService _habitService = HabitService();
  List<Habit> _habits = [];
  bool _isLoading = true;

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

  Future<void> _markHabitAsCompleted(String habitId, bool completed) async {
    if (completed) {
      await _habitService.markHabitAsCompleted(habitId, _habits);
    } else {
      await _habitService.unmarkHabitAsCompleted(habitId, _habits);
    }
    await _loadHabits();
  }

  Future<void> _deleteHabit(String habitId) async {
    await _habitService.deleteHabit(habitId, _habits);
    await _loadHabits();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Habit Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        // In the AppBar actions list, add this before the existing icons:
        actions: [
          // In AppBar actions
          IconButton(
            icon: Icon(MdiIcons.accountCircle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            tooltip: 'Profile',
          ),
          IconButton(
            icon: Icon(MdiIcons.chartBar),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrackProgressScreen(),
                ),
              );
            },
            tooltip: 'Track Progress',
          ),
          IconButton(
            icon: Icon(MdiIcons.chartLine),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
            tooltip: 'Statistics',
          ),
          IconButton(
            icon: Icon(MdiIcons.chartMultiple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
            tooltip: 'Advanced Analytics',
          ),
          IconButton(
            icon: Icon(MdiIcons.fileExport),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DataExportScreen(),
                ),
              );
            },
            tooltip: 'Export Data',
          ),
          IconButton(
            icon: Icon(MdiIcons.refresh),
            onPressed: () {
              _loadingController.forward(from: 0);
              _loadHabits();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            ],
          ),
        ),
        child: _isLoading
            ? Center(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: const CircularProgressIndicator(),
                    );
                  },
                ),
              )
            : _habits.isEmpty
                ? _buildEmptyState()
                : AnimationLimiter(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: HabitListItem(
                                habit: _habits[index],
                                onToggle: (completed) => _markHabitAsCompleted(
                                    _habits[index].id, completed),
                                onTap: () => _navigateToDetails(_habits[index]),
                                onDelete: () => _deleteHabit(_habits[index].id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Future<void> _navigateToDetails(Habit habit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailsScreen(habit: habit),
      ),
    );
    if (result == true) {
      await _loadHabits();
    }
  }

  Future<void> _navigateToAddHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddHabitScreen(),
      ),
    );
    if (result == true) {
      await _loadHabits();
    }
  }

  Widget _buildFloatingActionButton() {
    if (_habits.isEmpty) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: _navigateToAddHabit,
      child: Icon(MdiIcons.plus), // Only use child property for the FAB icon
    );
  }
}
