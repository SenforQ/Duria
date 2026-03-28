import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/training_activity_stats.dart';
import '../../services/workout_music_service.dart';
import '../../widgets/workout_music_consent_dialog.dart';

class DailyCheckinPage extends StatefulWidget {
  const DailyCheckinPage({super.key});

  @override
  State<DailyCheckinPage> createState() => _DailyCheckinPageState();
}

class _DailyCheckinPageState extends State<DailyCheckinPage> {
  static const String _kLastDate = 'daily_checkin_last_date';
  static const String _kStreak = 'daily_checkin_streak';
  static const String _kHistory = 'daily_checkin_history';
  static const String _kProjects = 'daily_checkin_projects_v3';
  static const String _kTotalElapsed = 'daily_checkin_total_elapsed_v3';
  static const String _pageHeaderBg = 'assets/stat_daily_checkin.png';
  static const List<String> _projectCardBgs = <String>[
    'assets/daily_plan_stretch_bg.png',
    'assets/daily_plan_run_bg.png',
    'assets/daily_plan_jumping_bg.png',
  ];

  static const List<_ProjectSeed> _defaultProjects = <_ProjectSeed>[
    _ProjectSeed(name: 'Stretch', minutes: 2),
    _ProjectSeed(name: 'Run', minutes: 5),
    _ProjectSeed(name: 'Jumping jacks', minutes: 5),
  ];

  int _streak = 0;
  String _lastDate = '';
  final List<String> _history = <String>[];
  final List<_CheckinProject> _projects = <_CheckinProject>[];

  int _totalElapsedSeconds = 0;
  bool _isRunning = false;
  Timer? _ticker;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  DateTime _parse(String value) {
    final parts = value.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _lastDate = prefs.getString(_kLastDate) ?? '';
    _streak = prefs.getInt(_kStreak) ?? 0;
    _totalElapsedSeconds = prefs.getInt(_kTotalElapsed) ?? 0;

    final String historyRaw = prefs.getString(_kHistory) ?? '[]';
    final List<dynamic> arr = jsonDecode(historyRaw) as List<dynamic>;
    _history
      ..clear()
      ..addAll(arr.map((e) => e.toString()));

    final String projectRaw = prefs.getString(_kProjects) ?? '';
    if (projectRaw.isEmpty) {
      _projects
        ..clear()
        ..addAll(
          _defaultProjects.map(
            (e) => _CheckinProject(name: e.name, durationMinutes: e.minutes),
          ),
        );
    } else {
      final List<dynamic> list = jsonDecode(projectRaw) as List<dynamic>;
      _projects
        ..clear()
        ..addAll(
          list.map(
            (e) => _CheckinProject.fromJson(e as Map<String, dynamic>),
          ),
        );
      if (_projects.isEmpty) {
        _projects.addAll(
          _defaultProjects.map(
            (e) => _CheckinProject(name: e.name, durationMinutes: e.minutes),
          ),
        );
      }
    }

    _normalizeDefaultPlanDurations();

    if (_totalElapsedSeconds > _totalPlanSeconds) {
      _totalElapsedSeconds = _totalPlanSeconds;
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastDate, _lastDate);
    await prefs.setInt(_kStreak, _streak);
    await prefs.setString(_kHistory, jsonEncode(_history));
    await prefs.setString(
      _kProjects,
      jsonEncode(_projects.map((e) => e.toJson()).toList()),
    );
    await prefs.setInt(_kTotalElapsed, _totalElapsedSeconds);
  }

  Future<void> _checkIn() async {
    final int totalPlan = _totalPlanSeconds;
    final bool workoutCompleted =
        totalPlan > 0 && _totalElapsedSeconds >= totalPlan;
    if (!workoutCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please finish all workout projects before check-in.',
          ),
        ),
      );
      return;
    }

    final String today = _today();
    if (_lastDate == today) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already checked in today.')),
      );
      return;
    }

    if (_lastDate.isNotEmpty) {
      final DateTime last = _parse(_lastDate);
      final DateTime current = _parse(today);
      final int diff = current.difference(last).inDays;
      _streak = diff == 1 ? _streak + 1 : 1;
    } else {
      _streak = 1;
    }
    _lastDate = today;
    _history.insert(0, today);
    if (_history.length > 14) {
      _history.removeRange(14, _history.length);
    }
    await _save();
    final int mins = _totalPlanSeconds ~/ 60;
    if (mins > 0) {
      await TrainingActivityStatsService.recordSession(
        minutes: mins,
        source: TrainingActivitySource.dailyCheckin,
      );
    }
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Check-in successful! Streak: $_streak days')),
    );
  }

  Future<void> _addProjectDialog() async {
    String nameValue = '';
    String minuteValue = '5';
    String? customImageRelPath;
    String tutorialSummaryValue = '';
    String tutorialStepsValue = '';
    String tutorialTipsValue = '';
    final bool? added = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Add Project',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(ctx)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.45),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Project Name',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            initialValue: '',
                            onChanged: (v) => nameValue = v,
                            decoration: const InputDecoration(
                              hintText: 'e.g. jump rope',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Duration (minutes)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            initialValue: '5',
                            onChanged: (v) => minuteValue = v,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 5',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Background Image',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: 110,
                              width: double.infinity,
                              child: customImageRelPath == null
                                  ? Image.asset(
                                      _projectCardBgs[_projects.length %
                                          _projectCardBgs.length],
                                      fit: BoxFit.cover,
                                    )
                                  : FutureBuilder<File?>(
                                      future: _fileForRelativePath(
                                        customImageRelPath,
                                      ),
                                      builder: (context, snapshot) {
                                        final file = snapshot.data;
                                        if (file != null) {
                                          return Image.file(
                                            file,
                                            fit: BoxFit.cover,
                                          );
                                        }
                                        return Image.asset(
                                          _projectCardBgs[_projects.length %
                                              _projectCardBgs.length],
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final x = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (x == null) return;
                              final root =
                                  await getApplicationDocumentsDirectory();
                              final rel =
                                  'daily_checkin/project_${DateTime.now().millisecondsSinceEpoch}.jpg';
                              final dest = File(p.join(root.path, rel));
                              await dest.parent.create(recursive: true);
                              await File(x.path).copy(dest.path);
                              setSheetState(() => customImageRelPath = rel);
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Custom Image'),
                          ),
                          if (customImageRelPath != null) ...[
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  setSheetState(() => customImageRelPath = null),
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('Use Default Image'),
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Text(
                            'Tutorial Summary',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            initialValue: '',
                            onChanged: (v) => tutorialSummaryValue = v,
                            decoration: const InputDecoration(
                              hintText: 'Short tutorial summary',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tutorial Steps (one step per line)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            initialValue: '',
                            onChanged: (v) => tutorialStepsValue = v,
                            minLines: 3,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              hintText: 'Step 1\\nStep 2\\nStep 3',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tutorial Tips (one tip per line)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            initialValue: '',
                            onChanged: (v) => tutorialTipsValue = v,
                            minLines: 2,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Tip 1\\nTip 2',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    final String name = nameValue.trim();
    final int minutes = int.tryParse(minuteValue.trim()) ?? 0;
    final List<String> customSteps = tutorialStepsValue
        .split('\\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final List<String> customTips = tutorialTipsValue
        .split('\\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (added != true || name.isEmpty || minutes <= 0) return;

    setState(() {
      _projects.add(
        _CheckinProject(
          name: name,
          durationMinutes: minutes,
          customImageRelPath: customImageRelPath,
          customTutorialSummary: tutorialSummaryValue.trim().isEmpty
              ? null
              : tutorialSummaryValue.trim(),
          customTutorialSteps: customSteps,
          customTutorialTips: customTips,
        ),
      );
    });
    await _save();
  }

  Future<void> _deleteProject(int index) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: const Text('Delete this project permanently?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (ok != true) return;

    final int removedSeconds = _projects[index].durationMinutes * 60;
    final int projectStart = _startSecondOfIndex(index);

    setState(() {
      _projects.removeAt(index);
      if (_totalElapsedSeconds > projectStart) {
        _totalElapsedSeconds = (_totalElapsedSeconds - removedSeconds).clamp(0, _totalPlanSeconds);
      }
      if (_totalElapsedSeconds > _totalPlanSeconds) {
        _totalElapsedSeconds = _totalPlanSeconds;
      }
      if (_projects.isEmpty) {
        _pauseTimer();
        _totalElapsedSeconds = 0;
      }
    });
    await _save();
  }

  Future<void> _moveProject(int index, int newIndex) async {
    if (newIndex < 0 || newIndex >= _projects.length) return;
    setState(() {
      final item = _projects.removeAt(index);
      _projects.insert(newIndex, item);
    });
    await _save();
  }

  int get _totalPlanSeconds {
    return _projects.fold<int>(0, (sum, e) => sum + e.durationMinutes * 60);
  }

  int _startSecondOfIndex(int index) {
    var sum = 0;
    for (var i = 0; i < index; i++) {
      sum += _projects[i].durationMinutes * 60;
    }
    return sum;
  }

  int _endSecondOfIndex(int index) {
    return _startSecondOfIndex(index) + _projects[index].durationMinutes * 60;
  }

  int? get _currentIndex {
    if (_projects.isEmpty) return null;
    if (_totalElapsedSeconds >= _totalPlanSeconds) return null;
    var cursor = 0;
    for (var i = 0; i < _projects.length; i++) {
      final next = cursor + _projects[i].durationMinutes * 60;
      if (_totalElapsedSeconds >= cursor && _totalElapsedSeconds < next) {
        return i;
      }
      cursor = next;
    }
    return null;
  }

  _ProjectStatus _statusOf(int index) {
    final int start = _startSecondOfIndex(index);
    final int end = _endSecondOfIndex(index);
    if (_totalElapsedSeconds >= end) return _ProjectStatus.done;
    if (_totalElapsedSeconds >= start && _totalElapsedSeconds < end) {
      return _ProjectStatus.current;
    }
    return _ProjectStatus.upcoming;
  }

  Future<void> _onStartTimingPressed() async {
    if (_projects.isEmpty) {
      return;
    }
    if (_isRunning) {
      return;
    }
    final int total = _totalPlanSeconds;
    final bool freshOrNewCycle = _totalElapsedSeconds == 0 ||
        (total > 0 && _totalElapsedSeconds >= total);
    if (freshOrNewCycle) {
      final bool useMusic = await showWorkoutMusicConsentDialog(context);
      if (!mounted) {
        return;
      }
      if (useMusic) {
        await WorkoutMusicService.instance.playPreset();
      }
      if (!mounted) {
        return;
      }
    }
    _startTimer();
  }

  void _startTimer() {
    if (_projects.isEmpty) return;
    if (_totalElapsedSeconds >= _totalPlanSeconds) {
      _totalElapsedSeconds = 0;
    }
    _ticker?.cancel();
    setState(() => _isRunning = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_isRunning) return;
      if (_totalElapsedSeconds >= _totalPlanSeconds) {
        _pauseTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All projects completed.')),
        );
        return;
      }
      setState(() {
        _totalElapsedSeconds++;
      });
      _save();
    });
  }

  void _pauseTimer() {
    _ticker?.cancel();
    setState(() => _isRunning = false);
    _save();
  }

  Future<void> _resetAllTimer() async {
    setState(() {
      _totalElapsedSeconds = 0;
      _isRunning = false;
    });
    _ticker?.cancel();
    await _save();
  }

  String _formatSeconds(int seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = seconds % 60;
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _bgForProject(int index) {
    final String name = _projects[index].name;
    if (name.contains('拉伸') || name.toLowerCase().contains('stretch')) {
      return 'assets/daily_plan_stretch_bg.png';
    }
    if (name.contains('跑') || name.toLowerCase().contains('run')) {
      return 'assets/daily_plan_run_bg.png';
    }
    if (name.contains('开合跳') || name.toLowerCase().contains('jump')) {
      return 'assets/daily_plan_jumping_bg.png';
    }
    return _projectCardBgs[index % _projectCardBgs.length];
  }

  Future<File?> _fileForRelativePath(String? rel) async {
    if (rel == null || rel.isEmpty) return null;
    final root = await getApplicationDocumentsDirectory();
    final file = File(p.join(root.path, rel));
    if (await file.exists()) return file;
    return null;
  }

  Widget _projectBackgroundWidget(int index) {
    final project = _projects[index];
    if (project.customImageRelPath != null) {
      return FutureBuilder<File?>(
        future: _fileForRelativePath(project.customImageRelPath),
        builder: (context, snapshot) {
          final file = snapshot.data;
          if (file != null) {
            return Image.file(file, fit: BoxFit.cover);
          }
          return Image.asset(_bgForProject(index), fit: BoxFit.cover);
        },
      );
    }
    return Image.asset(_bgForProject(index), fit: BoxFit.cover);
  }

  _WorkoutTutorial _tutorialForProject(_CheckinProject project) {
    if (project.customTutorialSummary != null &&
        project.customTutorialSummary!.isNotEmpty) {
      return _WorkoutTutorial(
        title: '${project.name} Tutorial',
        summary: project.customTutorialSummary!,
        steps: project.customTutorialSteps.isNotEmpty
            ? project.customTutorialSteps
            : const <String>[
                'Follow your custom routine step by step.',
                'Keep steady breathing and controlled movement.',
              ],
        tips: project.customTutorialTips.isNotEmpty
            ? project.customTutorialTips
            : const <String>[
                'Focus on form first, then intensity.',
                'Stop if you feel sharp pain.',
              ],
      );
    }

    final name = project.name;
    final lower = name.toLowerCase();
    if (name.contains('拉伸') || lower.contains('stretch')) {
      return const _WorkoutTutorial(
        title: 'Stretching Tutorial',
        summary: 'Improve flexibility and reduce injury risk.',
        steps: <String>[
          'Stand upright, feet shoulder-width apart.',
          'Raise one arm and bend to the opposite side slowly.',
          'Hold each side for 20-30 seconds.',
          'Repeat for hips, hamstrings, and calves.',
        ],
        tips: <String>[
          'Keep breathing steadily; do not hold breath.',
          'Move to mild tension, never to pain.',
          'Maintain smooth and controlled motion.',
        ],
      );
    }
    if (name.contains('跑') || lower.contains('run')) {
      return const _WorkoutTutorial(
        title: 'Running Tutorial',
        summary: 'Build cardio endurance with safe pacing.',
        steps: <String>[
          'Start with 2-3 minutes brisk walking warm-up.',
          'Run at an easy pace for 60-90 seconds.',
          'Keep torso upright and shoulders relaxed.',
          'Land softly under your body and keep cadence steady.',
        ],
        tips: <String>[
          'Use talk-test intensity for aerobic training.',
          'Hydrate before and after workout.',
          'If pain occurs, slow down and check form.',
        ],
      );
    }
    if (name.contains('开合跳') || lower.contains('jump')) {
      return const _WorkoutTutorial(
        title: 'Jumping Jacks Tutorial',
        summary: 'A quick full-body HIIT movement.',
        steps: <String>[
          'Stand straight with feet together and arms by sides.',
          'Jump feet wider than shoulders while raising arms overhead.',
          'Jump back to start position with controlled landing.',
          'Keep rhythm: 30-40 seconds work, 20 seconds rest.',
        ],
        tips: <String>[
          'Land softly with knees slightly bent.',
          'Engage core to protect lower back.',
          'Scale intensity by reducing jump height if needed.',
        ],
      );
    }
    return const _WorkoutTutorial(
      title: 'Tutorial',
      summary: 'No tips added yet',
      steps: <String>[],
      tips: <String>[],
    );
  }

  Future<void> _showTutorialSheet(_CheckinProject project) async {
    final tutorial = _tutorialForProject(project);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  tutorial.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tutorial.summary,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Steps',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...List<Widget>.generate(tutorial.steps.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('${i + 1}. ${tutorial.steps[i]}'),
                  );
                }),
                const SizedBox(height: 8),
                const Text(
                  'Tips',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...tutorial.tips.map((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('- $tip'),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  void _normalizeDefaultPlanDurations() {
    if (_projects.length < 3) return;
    final String n0 = _projects[0].name;
    final String n1 = _projects[1].name;
    final String n2 = _projects[2].name;
    final bool matchDefaultSequence =
        (n0.contains('拉伸') ||
            n0.toLowerCase().contains('stretch')) &&
        (n1.contains('跑') ||
            n1.toLowerCase().contains('run') ||
            n1 == 'Run') &&
        (n2.contains('开合跳') ||
            n2.toLowerCase().contains('jump'));
    if (!matchDefaultSequence) return;
    _projects[0].durationMinutes = 2;
    _projects[1].durationMinutes = 5;
    _projects[2].durationMinutes = 5;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bool checkedToday = _lastDate == _today();
    final int totalPlan = _totalPlanSeconds;
    final bool workoutCompleted =
        totalPlan > 0 && _totalElapsedSeconds >= totalPlan;
    final double progress = totalPlan == 0 ? 0 : (_totalElapsedSeconds / totalPlan).clamp(0, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily check-in',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _addProjectDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add Project',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _pageHeaderBg,
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Current Streak: $_streak days',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last check-in: ${_lastDate.isEmpty ? 'No record' : _lastDate}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: checkedToday || !workoutCompleted ? null : _checkIn,
            child: Text(
              checkedToday
                  ? 'Checked In Today'
                  : workoutCompleted
                      ? 'Check In Now'
                      : 'Finish Workout To Check In',
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'One Total Timer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elapsed: ${_formatSeconds(_totalElapsedSeconds)} / ${_formatSeconds(totalPlan)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _isRunning ? _pauseTimer : _onStartTimingPressed,
                        child: Text(_isRunning ? 'Pause' : 'Start Timing'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _resetAllTimer,
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Projects (Ordered)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (_projects.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No project yet. Tap + to add one.'),
            ),
          ...List<Widget>.generate(_projects.length, (index) {
            final p = _projects[index];
            final status = _statusOf(index);
            final Color bgColor = switch (status) {
              _ProjectStatus.current => Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.16),
              _ProjectStatus.done => Colors.green.withValues(alpha: 0.14),
              _ProjectStatus.upcoming => Colors.transparent,
            };
            final Color borderColor = switch (status) {
              _ProjectStatus.current => Theme.of(context).colorScheme.primary,
              _ProjectStatus.done => Colors.green,
              _ProjectStatus.upcoming => Colors.grey.withValues(alpha: 0.25),
            };
            final String statusText = switch (status) {
              _ProjectStatus.current => 'In Progress',
              _ProjectStatus.done => 'Completed',
              _ProjectStatus.upcoming => 'Upcoming',
            };
            final tutorial = _tutorialForProject(p);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 190,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _projectBackgroundWidget(index),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: status == _ProjectStatus.current ? 0.35 : 0.45,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: bgColor.withValues(alpha: 0.30),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${index + 1}. ${p.name}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: status == _ProjectStatus.current
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                              Chip(label: Text(statusText)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tutorial.summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const Spacer(),
                          const Spacer(),
                          Text(
                            'Duration: ${p.durationMinutes} min',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                onPressed: index == 0
                                    ? null
                                    : () => _moveProject(index, index - 1),
                                icon: const Icon(Icons.arrow_upward),
                                tooltip: 'Move Up',
                                color: Colors.white,
                              ),
                              IconButton(
                                onPressed: index == _projects.length - 1
                                    ? null
                                    : () => _moveProject(index, index + 1),
                                icon: const Icon(Icons.arrow_downward),
                                tooltip: 'Move Down',
                                color: Colors.white,
                              ),
                              IconButton(
                                onPressed: () => _deleteProject(index),
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete',
                                color: Colors.white,
                              ),
                              const Spacer(),
                              OutlinedButton.icon(
                                onPressed: () => _showTutorialSheet(p),
                                icon: const Icon(Icons.menu_book_outlined),
                                label: const Text('Tutorial'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'Recent Records',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ..._history.map((date) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(date),
            );
          }),
        ],
      ),
    );
  }
}

enum _ProjectStatus {
  upcoming,
  current,
  done,
}

class _ProjectSeed {
  const _ProjectSeed({required this.name, required this.minutes});

  final String name;
  final int minutes;
}

class _CheckinProject {
  _CheckinProject({
    required this.name,
    required this.durationMinutes,
    this.customImageRelPath,
    this.customTutorialSummary,
    List<String>? customTutorialSteps,
    List<String>? customTutorialTips,
  })  : customTutorialSteps = customTutorialSteps ?? <String>[],
        customTutorialTips = customTutorialTips ?? <String>[];

  factory _CheckinProject.fromJson(Map<String, dynamic> json) {
    return _CheckinProject(
      name: json['name']?.toString() ?? 'Project',
      durationMinutes: json['durationMinutes'] is int
          ? json['durationMinutes'] as int
          : int.tryParse(json['durationMinutes']?.toString() ?? '') ?? 5,
      customImageRelPath: json['customImageRelPath']?.toString(),
      customTutorialSummary: json['customTutorialSummary']?.toString(),
      customTutorialSteps: (json['customTutorialSteps'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      customTutorialTips: (json['customTutorialTips'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  final String name;
  int durationMinutes;
  String? customImageRelPath;
  String? customTutorialSummary;
  List<String> customTutorialSteps;
  List<String> customTutorialTips;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'durationMinutes': durationMinutes,
      'customImageRelPath': customImageRelPath,
      'customTutorialSummary': customTutorialSummary,
      'customTutorialSteps': customTutorialSteps,
      'customTutorialTips': customTutorialTips,
    };
  }
}

class _WorkoutTutorial {
  const _WorkoutTutorial({
    required this.title,
    required this.summary,
    required this.steps,
    required this.tips,
  });

  final String title;
  final String summary;
  final List<String> steps;
  final List<String> tips;
}
