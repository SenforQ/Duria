import 'package:flutter/material.dart';
import 'dart:async';

import '../athletes/coach_media_widgets.dart';
import '../../services/training_activity_stats.dart';

const List<CourseItem> recommendedCourses = <CourseItem>[
  CourseItem(
    title: 'Full Body Starter',
    level: 'Beginner',
    duration: '30 min',
    description: 'A balanced full-body intro course for daily fitness habit.',
    cover: 'assets/stat_today_sport.png',
    goal: 'Build full-body baseline strength and mobility.',
    calories: '180-260 kcal',
    equipment: <String>['Yoga Mat', 'Light Dumbbells', 'Water Bottle'],
    steps: <CourseStep>[
      CourseStep(name: 'Warm-up Walk', minutes: 5, detail: 'Brisk walk and arm circles.'),
      CourseStep(name: 'Bodyweight Squat', minutes: 8, detail: 'Keep knees tracking over toes.'),
      CourseStep(name: 'Push-up + Plank', minutes: 10, detail: 'Alternate push-up sets with plank holds.'),
      CourseStep(name: 'Cool Down Stretch', minutes: 7, detail: 'Stretch legs, chest and back slowly.'),
    ],
  ),
  CourseItem(
    title: 'Cardio Fat Burn',
    level: 'Intermediate',
    duration: '25 min',
    description: 'Cardio-focused training to improve endurance and burn fat.',
    cover: 'assets/daily_plan_run_bg.png',
    goal: 'Improve cardio capacity and increase calorie burn.',
    calories: '220-320 kcal',
    equipment: <String>['Treadmill or Open Space', 'Training Shoes'],
    steps: <CourseStep>[
      CourseStep(name: 'Dynamic Warm-up', minutes: 4, detail: 'Hip openers and leg swings.'),
      CourseStep(name: 'Steady Run', minutes: 8, detail: 'Maintain moderate pace with nasal breathing.'),
      CourseStep(name: 'HIIT Intervals', minutes: 9, detail: '30s fast + 30s easy cycles.'),
      CourseStep(name: 'Walk Recovery', minutes: 4, detail: 'Slow walk to lower heart rate.'),
    ],
  ),
  CourseItem(
    title: 'Core Strength Pro',
    level: 'Advanced',
    duration: '35 min',
    description: 'Core-focused plan with stability and strength progression.',
    cover: 'assets/daily_plan_jumping_bg.png',
    goal: 'Enhance core strength, posture and trunk stability.',
    calories: '200-290 kcal',
    equipment: <String>['Yoga Mat', 'Resistance Band'],
    steps: <CourseStep>[
      CourseStep(name: 'Activation Prep', minutes: 6, detail: 'Dead bug and glute bridge activation.'),
      CourseStep(name: 'Plank Complex', minutes: 10, detail: 'Front plank + side plank holds.'),
      CourseStep(name: 'Core Circuit', minutes: 12, detail: 'Mountain climbers, hollow hold, reverse crunch.'),
      CourseStep(name: 'Mobility Finish', minutes: 7, detail: 'Spine rotation and hip flexor stretch.'),
    ],
  ),
];

class RecommendedCoursesPage extends StatelessWidget {
  const RecommendedCoursesPage({
    super.key,
    this.appBarTitle = 'Recommended courses',
    this.circleBackButton = false,
  });

  final String appBarTitle;
  final bool circleBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: circleBackButton ? const CoachCircleBackButton() : null,
        automaticallyImplyLeading: !circleBackButton,
        title: Text(
          appBarTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: recommendedCourses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final course = recommendedCourses[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CourseDetailPage(
                      course: course,
                      circleBackButton: circleBackButton,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: Image.asset(
                      course.cover,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${course.level} · ${course.duration}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course.description,
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CourseItem {
  const CourseItem({
    required this.title,
    required this.level,
    required this.duration,
    required this.description,
    required this.cover,
    required this.goal,
    required this.calories,
    required this.equipment,
    required this.steps,
  });

  final String title;
  final String level;
  final String duration;
  final String description;
  final String cover;
  final String goal;
  final String calories;
  final List<String> equipment;
  final List<CourseStep> steps;
}

class CourseStep {
  const CourseStep({
    required this.name,
    required this.minutes,
    required this.detail,
  });

  final String name;
  final int minutes;
  final String detail;
}

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({
    super.key,
    required this.course,
    this.circleBackButton = false,
  });

  final CourseItem course;
  final bool circleBackButton;

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  Timer? _timer;
  bool _running = false;
  int _elapsedSeconds = 0;

  int get _totalSeconds =>
      widget.course.steps.fold<int>(0, (sum, step) => sum + step.minutes * 60);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    if (_elapsedSeconds >= _totalSeconds) {
      setState(() => _elapsedSeconds = 0);
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_elapsedSeconds >= _totalSeconds) {
        _timer?.cancel();
        setState(() => _running = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course completed!')),
        );
        final int mins = widget.course.steps.fold<int>(
          0,
          (a, s) => a + s.minutes,
        );
        if (mins > 0) {
          unawaited(
            TrainingActivityStatsService.recordSession(
              minutes: mins,
              source: TrainingActivitySource.recommendedCourse,
            ),
          );
        }
        return;
      }
      setState(() => _elapsedSeconds++);
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _elapsedSeconds = 0;
    });
  }

  String _format(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int? get _currentStepIndex {
    if (_elapsedSeconds >= _totalSeconds) return null;
    var cursor = 0;
    for (var i = 0; i < widget.course.steps.length; i++) {
      final next = cursor + widget.course.steps[i].minutes * 60;
      if (_elapsedSeconds >= cursor && _elapsedSeconds < next) return i;
      cursor = next;
    }
    return null;
  }

  _StepStatus _statusOfStep(int index) {
    var cursor = 0;
    for (var i = 0; i < widget.course.steps.length; i++) {
      final end = cursor + widget.course.steps[i].minutes * 60;
      if (i == index) {
        if (_elapsedSeconds >= end) return _StepStatus.done;
        if (_elapsedSeconds >= cursor && _elapsedSeconds < end) {
          return _StepStatus.current;
        }
        return _StepStatus.todo;
      }
      cursor = end;
    }
    return _StepStatus.todo;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    final double progress = _totalSeconds == 0
        ? 0.0
        : (_elapsedSeconds / _totalSeconds).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        leading: widget.circleBackButton ? const CoachCircleBackButton() : null,
        automaticallyImplyLeading: !widget.circleBackButton,
        title: Text(
          c.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(c.cover, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration:
                        BoxDecoration(color: Colors.black.withValues(alpha: 0.40)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${c.level} · ${c.duration}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.goal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calories: ${c.calories}'),
                  const SizedBox(height: 6),
                  Text('Equipment: ${c.equipment.join(', ')}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timer: ${_format(_elapsedSeconds)} / ${_format(_totalSeconds)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _toggleTimer,
                        child: Text(_running ? 'Pause' : 'Start'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: _reset, child: const Text('Reset')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Steps & Time',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...List<Widget>.generate(c.steps.length, (index) {
            final step = c.steps[index];
            final status = _statusOfStep(index);
            final statusText = switch (status) {
              _StepStatus.current => 'In Progress',
              _StepStatus.done => 'Done',
              _StepStatus.todo => 'Todo',
            };
            final statusColor = switch (status) {
              _StepStatus.current => Theme.of(context).colorScheme.primary,
              _StepStatus.done => Colors.green,
              _StepStatus.todo => Colors.grey,
            };
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: statusColor.withValues(alpha: 0.4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}. ${step.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Chip(label: Text(statusText)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Time: ${step.minutes} min'),
                    const SizedBox(height: 4),
                    Text(step.detail, style: TextStyle(color: Colors.grey[700])),
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

enum _StepStatus { todo, current, done }
