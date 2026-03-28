import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/training_activity_stats.dart';

class TodaySportPage extends StatefulWidget {
  const TodaySportPage({super.key});

  @override
  State<TodaySportPage> createState() => _TodaySportPageState();
}

class _TodaySportPageState extends State<TodaySportPage> {
  static const String _kState = 'today_sport_state_v2';

  static const String _progressBgAsset = 'assets/today_sport_progress_bg.png';

  static const List<String> _defaultCellAssets = <String>[
    'assets/today_task_warmup_bg.png',
    'assets/today_task_core_bg.png',
    'assets/today_task_upper_bg.png',
    'assets/today_task_stretch_bg.png',
  ];

  final List<_TaskItem> _tasks = <_TaskItem>[];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  List<_TaskItem> _defaultTasks() {
    return <_TaskItem>[
      _TaskItem(
        title: 'Warm-up Walking',
        target: '15 min',
        assetDefault: _defaultCellAssets[0],
      ),
      _TaskItem(
        title: 'Core Training',
        target: '20 min',
        assetDefault: _defaultCellAssets[1],
      ),
      _TaskItem(
        title: 'Upper Body',
        target: '25 min',
        assetDefault: _defaultCellAssets[2],
      ),
      _TaskItem(
        title: 'Stretching',
        target: '10 min',
        assetDefault: _defaultCellAssets[3],
      ),
    ];
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_kState);
    if (raw == null || raw.isEmpty) {
      _tasks
        ..clear()
        ..addAll(_defaultTasks());
    } else {
      try {
        final Map<String, dynamic> data =
            jsonDecode(raw) as Map<String, dynamic>;
        final String savedDate = data['date']?.toString() ?? '';
        final List<dynamic> list = data['tasks'] as List<dynamic>? ?? [];
        final List<_TaskItem> loaded = <_TaskItem>[];
        for (final dynamic it in list) {
          final Map<String, dynamic> m = it as Map<String, dynamic>;
          final String title = m['title']?.toString() ?? 'New Task';
          final String target = m['target']?.toString() ?? '10 min';
          final String asset = m['assetDefault']?.toString().isNotEmpty == true
              ? m['assetDefault'].toString()
              : _defaultCellAssets.first;
          final String? rel = m['relPath']?.toString();
          final bool done = m['done'] == true;
          loaded.add(
            _TaskItem(
              title: title,
              target: target,
              assetDefault: asset,
              relPath: (rel != null && rel.isEmpty) ? null : rel,
              done: done,
            ),
          );
        }
        _tasks
          ..clear()
          ..addAll(loaded);
        if (savedDate != _todayKey()) {
          for (final t in _tasks) {
            t.done = false;
          }
        }
      } catch (_) {
        _tasks
          ..clear()
          ..addAll(_defaultTasks());
      }
    }
    if (!mounted) return;
    setState(() => _loading = false);
    await _saveState();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'date': _todayKey(),
      'tasks': _tasks.map((e) => e.toJson()).toList(),
    };
    await prefs.setString(_kState, jsonEncode(payload));
  }

  int _minutesFromTarget(String target) {
    final m = RegExp(r'(\d+)').firstMatch(target);
    if (m == null) {
      return 0;
    }
    return int.tryParse(m.group(1)!) ?? 0;
  }

  Future<void> _toggle(int index, bool value) async {
    setState(() => _tasks[index].done = value);
    await _saveState();
    if (_tasks.isNotEmpty && _tasks.every((t) => t.done)) {
      final int mins = _tasks.fold<int>(
        0,
        (s, t) => s + _minutesFromTarget(t.target),
      );
      await TrainingActivityStatsService.recordTodaySportDayIfNeeded(
        minutes: mins,
      );
    }
  }

  Future<File?> _fileForRelativePath(String? rel) async {
    if (rel == null || rel.isEmpty) return null;
    final root = await getApplicationDocumentsDirectory();
    final file = File(p.join(root.path, rel));
    if (await file.exists()) return file;
    return null;
  }

  Future<void> _pickImageForTask(int index) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final root = await getApplicationDocumentsDirectory();
    final rel = 'today_sport/task_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final dest = File(p.join(root.path, rel));
    await dest.parent.create(recursive: true);
    await File(x.path).copy(dest.path);
    if (!mounted) return;
    setState(() => _tasks[index].relPath = rel);
    await _saveState();
  }

  void _resetTaskImage(int index) {
    setState(() => _tasks[index].relPath = null);
    _saveState();
  }

  Future<void> _addTaskSheet() async {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    String selectedAsset = _defaultCellAssets.first;
    String? selectedRelPath;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add sport task',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Title',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Leg Day',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Time',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: timeCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 30 min',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (selectedRelPath == null)
                            Image.asset(selectedAsset, fit: BoxFit.cover)
                          else
                            FutureBuilder<File?>(
                              future: _fileForRelativePath(selectedRelPath),
                              builder: (context, snapshot) {
                                final file = snapshot.data;
                                if (file != null) {
                                  return Image.file(file, fit: BoxFit.cover);
                                }
                                return Image.asset(
                                  selectedAsset,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.28),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Background Preview',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Default Background',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) {
                        final asset = _defaultCellAssets[i];
                        final selected = selectedAsset == asset;
                        return GestureDetector(
                          onTap: () => sheetSetState(() => selectedAsset = asset),
                          child: Container(
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: AssetImage(asset),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: _defaultCellAssets.length,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final x = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (x == null) return;
                      final root = await getApplicationDocumentsDirectory();
                      final rel =
                          'today_sport/task_${DateTime.now().millisecondsSinceEpoch}.jpg';
                      final dest = File(p.join(root.path, rel));
                      await dest.parent.create(recursive: true);
                      await File(x.path).copy(dest.path);
                      sheetSetState(() => selectedRelPath = rel);
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload custom background'),
                  ),
                  if (selectedRelPath != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => sheetSetState(() => selectedRelPath = null),
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Use default background'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      final target = timeCtrl.text.trim();
                      if (title.isEmpty || target.isEmpty) return;
                      setState(() {
                        _tasks.add(
                          _TaskItem(
                            title: title,
                            target: target,
                            assetDefault: selectedAsset,
                            relPath: selectedRelPath,
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                      _saveState();
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      titleCtrl.dispose();
      timeCtrl.dispose();
    });
  }

  Future<void> _deleteTask(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete task'),
          content: const Text('Are you sure you want to delete this sport task?'),
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
    if (confirmed != true) return;
    setState(() {
      _tasks.removeAt(index);
    });
    await _saveState();
  }

  Future<void> _openEditSheet(int index) async {
    final item = _tasks[index];
    final titleCtrl = TextEditingController(text: item.title);
    final timeCtrl = TextEditingController(text: item.target);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FutureBuilder<File?>(
                        future: _fileForRelativePath(item.relPath),
                        builder: (context, snapshot) {
                          final file = snapshot.data;
                          if (file != null) {
                            return Image.file(file, fit: BoxFit.cover);
                          }
                          return Image.asset(
                            item.assetDefault,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Current Background',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Title',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter time',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _pickImageForTask(index);
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Change image'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  _resetTaskImage(index);
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.restore),
                label: const Text('Reset to default image'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    item.title = titleCtrl.text.trim().isEmpty
                        ? item.title
                        : titleCtrl.text.trim();
                    item.target = timeCtrl.text.trim().isEmpty
                        ? item.target
                        : timeCtrl.text.trim();
                  });
                  Navigator.pop(ctx);
                  _saveState();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      titleCtrl.dispose();
      timeCtrl.dispose();
    });
  }

  Widget _taskBackground(int index) {
    final item = _tasks[index];
    return FutureBuilder<File?>(
      future: _fileForRelativePath(item.relPath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file != null) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        }
        return Image.asset(
          item.assetDefault,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }

  int get _completed => _tasks.where((e) => e.done).length;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final double progress =
        _tasks.isEmpty ? 0 : _completed / _tasks.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today sport',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _addTaskSheet,
            icon: const Icon(Icons.add),
            tooltip: 'Add Task',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _progressBgAsset,
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
                          'Progress: $_completed/${_tasks.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.white24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_tasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.grey.withValues(alpha: 0.08),
              ),
              child: const Text(
                'No sport task yet. Tap + to add one.',
                textAlign: TextAlign.center,
              ),
            ),
          ...List<Widget>.generate(_tasks.length, (index) {
            final item = _tasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _taskBackground(index),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: item.done,
                                  onChanged: (v) =>
                                      _toggle(index, v ?? false),
                                  checkColor: Colors.black87,
                                  fillColor: WidgetStateProperty.all(
                                    Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => _openEditSheet(index),
                                  icon: const Icon(Icons.edit_outlined),
                                  color: Colors.white,
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  onPressed: () => _deleteTask(index),
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.white,
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.target,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          FilledButton(
            onPressed: _completed == _tasks.length
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Great! You completed all tasks today.',
                        ),
                      ),
                    );
                  }
                : null,
            child: const Text('Finish Today Plan'),
          ),
        ],
      ),
    );
  }
}

class _TaskItem {
  _TaskItem({
    required this.title,
    required this.target,
    required this.assetDefault,
    this.relPath,
    this.done = false,
  });

  String title;
  String target;
  String assetDefault;
  String? relPath;
  bool done;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'target': target,
        'assetDefault': assetDefault,
        'relPath': relPath,
        'done': done,
      };
}
