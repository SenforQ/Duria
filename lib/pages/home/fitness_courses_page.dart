import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FitnessCoursesPage extends StatefulWidget {
  const FitnessCoursesPage({super.key});

  @override
  State<FitnessCoursesPage> createState() => _FitnessCoursesPageState();
}

class _FitnessCoursesPageState extends State<FitnessCoursesPage> {
  static const String _kCourseProgress = 'fitness_course_progress';
  final List<_CourseItem> _courses = <_CourseItem>[
    _CourseItem(id: 'c1', name: 'Beginner Fat Burn', weeks: 2),
    _CourseItem(id: 'c2', name: 'Core Strength Builder', weeks: 3),
    _CourseItem(id: 'c3', name: 'Home HIIT Routine', weeks: 2),
    _CourseItem(id: 'c4', name: 'Posture & Mobility', weeks: 4),
  ];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_kCourseProgress);
    if (raw != null && raw.isNotEmpty) {
      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      for (final item in _courses) {
        final dynamic value = map[item.id];
        if (value is int) {
          item.progress = value.clamp(0, 100);
        }
      }
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> map = <String, int>{
      for (final c in _courses) c.id: c.progress,
    };
    await prefs.setString(_kCourseProgress, jsonEncode(map));
  }

  Future<void> _updateProgress(_CourseItem item, int delta) async {
    setState(() {
      item.progress = (item.progress + delta).clamp(0, 100);
    });
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fitness courses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._courses.map((course) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${course.weeks} weeks plan'),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: course.progress / 100,
                      borderRadius: BorderRadius.circular(999),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text('Progress: ${course.progress}%'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _updateProgress(course, -10),
                          child: const Text('-10%'),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: () => _updateProgress(course, 10),
                          child: const Text('+10%'),
                        ),
                        const Spacer(),
                        if (course.progress == 100)
                          const Chip(label: Text('Completed')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CourseItem {
  _CourseItem({
    required this.id,
    required this.name,
    required this.weeks,
    this.progress = 0,
  });

  final String id;
  final String name;
  final int weeks;
  int progress;
}
