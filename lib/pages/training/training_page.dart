import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../athletes/coach_media_widgets.dart';
import '../home/recommended_courses_page.dart';
import '../../data/library_training_plan.dart';
import '../../data/training_category_plans.dart';
import '../../services/training_activity_stats.dart';
import '../../services/wallet_service.dart';
import '../../services/workout_music_service.dart';
import '../../wallet_insufficient_helper.dart';
import '../../widgets/workout_music_consent_dialog.dart';

Future<void> openMyPlanWorkoutWithMusicConsent(
  BuildContext context,
  MyPlanWorkoutPage page,
) async {
  final bool useMusic = await showWorkoutMusicConsentDialog(context);
  if (!context.mounted) {
    return;
  }
  if (useMusic) {
    await WorkoutMusicService.instance.playPreset();
  }
  if (!context.mounted) {
    return;
  }
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => page),
  );
}

class _TrainingCategoryData {
  const _TrainingCategoryData({
    required this.title,
    required this.subtitle,
    required this.assetPath,
  });

  final String title;
  final String subtitle;
  final String assetPath;
}

class _MyPlanData {
  const _MyPlanData({
    required this.name,
    required this.progress,
    required this.progressLabel,
    required this.assetPath,
    required this.categoryTitle,
    required this.libraryPlanName,
    this.coverRelPath,
  });

  final String name;
  final double progress;
  final String progressLabel;
  final String assetPath;
  final String categoryTitle;
  final String libraryPlanName;
  final String? coverRelPath;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'progress': progress,
      'progressLabel': progressLabel,
      'assetPath': assetPath,
      'categoryTitle': categoryTitle,
      'libraryPlanName': libraryPlanName,
      if (coverRelPath != null && coverRelPath!.isNotEmpty)
        'coverRelPath': coverRelPath,
    };
  }

  static _MyPlanData fromJson(Map<String, dynamic> m) {
    return _MyPlanData(
      name: m['name'] as String? ?? '',
      progress: (m['progress'] as num?)?.toDouble() ?? 0,
      progressLabel:
          m['progressLabel'] as String? ?? 'Day 0 / 20',
      assetPath:
          m['assetPath'] as String? ?? 'assets/home_fitness_hero_bg.png',
      categoryTitle: m['categoryTitle'] as String? ?? 'Full-body fitness',
      libraryPlanName:
          m['libraryPlanName'] as String? ?? 'Full-body circuit · Starter',
      coverRelPath: m['coverRelPath'] as String?,
    );
  }
}

const List<String> _createPlanPresetCoverAssets = <String>[
  'assets/home_fitness_hero_bg.png',
  'assets/stat_today_sport.png',
  'assets/daily_plan_run_bg.png',
  'assets/daily_plan_jumping_bg.png',
  'assets/daily_plan_stretch_bg.png',
  'assets/today_task_warmup_bg.png',
  'assets/today_task_core_bg.png',
  'assets/today_task_upper_bg.png',
  'assets/today_task_stretch_bg.png',
];

Future<File?> _trainingPlanCoverFile(String relPath) async {
  final root = await getApplicationDocumentsDirectory();
  final f = File(p.join(root.path, relPath));
  if (await f.exists()) {
    return f;
  }
  return null;
}

class _PlanCoverFitImage extends StatelessWidget {
  const _PlanCoverFitImage({
    required this.assetPath,
    this.relPath,
  });

  final String assetPath;
  final String? relPath;

  @override
  Widget build(BuildContext context) {
    if (relPath != null && relPath!.isNotEmpty) {
      return FutureBuilder<File?>(
        future: _trainingPlanCoverFile(relPath!),
        builder: (context, snapshot) {
          final file = snapshot.data;
          if (file != null) {
            return Image.file(
              file,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            );
          }
          return Image.asset(
            assetPath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          );
        },
      );
    }
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
  }
}

const List<_TrainingCategoryData> _trainingLibraryCategories =
    <_TrainingCategoryData>[
  _TrainingCategoryData(
    title: 'Full-body fitness',
    subtitle: 'Full-body basics',
    assetPath: 'assets/stat_today_sport.png',
  ),
  _TrainingCategoryData(
    title: 'Running & cardio',
    subtitle: 'Endurance & heart health',
    assetPath: 'assets/daily_plan_run_bg.png',
  ),
  _TrainingCategoryData(
    title: 'Fat-burn jumps',
    subtitle: 'Explosive conditioning',
    assetPath: 'assets/daily_plan_jumping_bg.png',
  ),
  _TrainingCategoryData(
    title: 'Stretch & recovery',
    subtitle: 'Flexibility & recovery',
    assetPath: 'assets/daily_plan_stretch_bg.png',
  ),
  _TrainingCategoryData(
    title: 'Warm-up & activation',
    subtitle: 'Prep for training',
    assetPath: 'assets/today_task_warmup_bg.png',
  ),
  _TrainingCategoryData(
    title: 'Core training',
    subtitle: 'Trunk stability',
    assetPath: 'assets/today_task_core_bg.png',
  ),
  _TrainingCategoryData(
    title: 'Upper-body strength',
    subtitle: 'Push & pull balance',
    assetPath: 'assets/today_task_upper_bg.png',
  ),
  _TrainingCategoryData(
    title: 'Full-body stretch',
    subtitle: 'Post-session cool-down',
    assetPath: 'assets/today_task_stretch_bg.png',
  ),
];

String _canonicalCategoryTitle(String stored) {
  const Map<String, String> legacy = <String, String>{
    '综合健身': 'Full-body fitness',
    '跑步有氧': 'Running & cardio',
    '燃脂跳跃': 'Fat-burn jumps',
    '拉伸放松': 'Stretch & recovery',
    '热身激活': 'Warm-up & activation',
    '核心训练': 'Core training',
    '上肢力量': 'Upper-body strength',
    '全身拉伸': 'Full-body stretch',
  };
  return legacy[stored] ?? stored;
}

String _canonicalLibraryPlanName(String stored) {
  const Map<String, String> legacy = <String, String>{
    '全身循环 · 入门': 'Full-body circuit · Starter',
    '全身塑形 · 进阶': 'Full-body sculpt · Progress',
    '轻松跑 · 心肺基础': 'Easy run · Cardio base',
    '间歇跑 · 提升配速': 'Intervals · Build pace',
    'Tabata 跳跃燃脂': 'Tabata jump burn',
    '低冲击有氧': 'Low-impact cardio',
    '全身柔韧 · 睡前版': 'Full-body flexibility · Bedtime',
    '练后恢复拉伸': 'Post-workout stretch',
    '力量课前热身': 'Pre-strength warm-up',
    '跑步前激活': 'Pre-run activation',
    '核心稳定基础': 'Core stability base',
    '核心耐力进阶': 'Core endurance plus',
    '推日 · 胸肩三头': 'Push day · Chest, shoulders, triceps',
    '拉日 · 背与二头': 'Pull day · Back & biceps',
    '久坐族肩颈腰背': 'Desk neck & back relief',
    '下肢链拉伸': 'Lower-body chain stretch',
  };
  return legacy[stored] ?? stored;
}

_TrainingCategoryData _trainingCategoryForTitle(String title) {
  final String t = _canonicalCategoryTitle(title);
  for (final _TrainingCategoryData c in _trainingLibraryCategories) {
    if (c.title == t) {
      return c;
    }
  }
  throw StateError('Unknown training category: $title');
}

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage>
    with SingleTickerProviderStateMixin {
  static const Color _brand = Color(0xFF8BC34A);
  static const Color _brandDark = Color(0xFF558B2F);
  static const Color _brandDeep = Color(0xFF33691E);

  late TabController _tabController;
  String _libraryQuery = '';
  List<_MyPlanData> _userPlans = <_MyPlanData>[];

  static const String _kUserPlansPrefs = 'training_user_plans_v1';

  static const List<_MyPlanData> _samplePlans = <_MyPlanData>[
    _MyPlanData(
      name: 'Full-body strength · 4-week progress',
      progress: 0,
      progressLabel: 'Day 0 / 20',
      assetPath: 'assets/home_fitness_hero_bg.png',
      categoryTitle: 'Full-body fitness',
      libraryPlanName: 'Full-body sculpt · Progress',
    ),
    _MyPlanData(
      name: 'Morning cardio check-in',
      progress: 0,
      progressLabel: 'Day 0 / 25',
      assetPath: 'assets/daily_plan_run_bg.png',
      categoryTitle: 'Running & cardio',
      libraryPlanName: 'Easy run · Cardio base',
    ),
    _MyPlanData(
      name: 'Core stability boost',
      progress: 0,
      progressLabel: 'Day 0 / 15',
      assetPath: 'assets/today_task_core_bg.png',
      categoryTitle: 'Core training',
      libraryPlanName: 'Core stability base',
    ),
  ];

  static const List<String> _popularTitlesEn = <String>[
    'Full-body starter plan',
    'Cardio fat-burn training',
    'Core strength plan',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index == 2) {
        TrainingActivityStatsController.instance.notifyStatsChanged();
      }
    });
    unawaited(_loadUserPlans());
  }

  Future<void> _loadUserPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_kUserPlansPrefs);
    if (raw == null || raw.isEmpty) {
      if (mounted) {
        setState(() => _userPlans = <_MyPlanData>[]);
      }
      return;
    }
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      final List<_MyPlanData> loaded = list
          .map(
            (dynamic e) => _MyPlanData.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ),
          )
          .toList();
      if (mounted) {
        setState(() => _userPlans = loaded);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _userPlans = <_MyPlanData>[]);
      }
    }
  }

  Future<void> _saveUserPlans() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kUserPlansPrefs,
      jsonEncode(_userPlans.map((e) => e.toJson()).toList()),
    );
  }

  List<_MyPlanData> get _plansForMyPlanTab =>
      <_MyPlanData>[..._userPlans, ..._samplePlans];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Training',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _brandDeep,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _brand,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Library'),
            Tab(text: 'My plans'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TrainingLibraryTab(
            brand: _brand,
            brandDark: _brandDark,
            brandDeep: _brandDeep,
            categories: _trainingLibraryCategories,
            libraryQuery: _libraryQuery,
            onQueryChanged: (v) => setState(() => _libraryQuery = v),
            popularPlanTitles: _popularTitlesEn,
          ),
          _MyPlansTab(
            brand: _brand,
            brandDark: _brandDark,
            brandDeep: _brandDeep,
            plans: _plansForMyPlanTab,
          ),
          _DataAnalysisTab(
            brand: _brand,
            brandDark: _brandDark,
            brandDeep: _brandDeep,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_training_create_plan',
        onPressed: () => _showCreatePlanSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Create plan'),
        backgroundColor: _brand,
        foregroundColor: _brandDeep,
      ),
    );
  }

  void _showCreatePlanSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CreatePlanBottomSheet(
        brand: _brand,
        brandDeep: _brandDeep,
        scaffoldContext: context,
        currentUserPlanCount: _userPlans.length,
        onCreated: (plan) {
          setState(() {
            _userPlans.insert(0, plan);
          });
          unawaited(_saveUserPlans());
        },
      ),
    );
  }
}

class _CreatePlanBottomSheet extends StatefulWidget {
  const _CreatePlanBottomSheet({
    required this.brand,
    required this.brandDeep,
    required this.scaffoldContext,
    required this.currentUserPlanCount,
    required this.onCreated,
  });

  final Color brand;
  final Color brandDeep;
  final BuildContext scaffoldContext;
  final int currentUserPlanCount;
  final void Function(_MyPlanData plan) onCreated;

  @override
  State<_CreatePlanBottomSheet> createState() => _CreatePlanBottomSheetState();
}

class _CreatePlanBottomSheetState extends State<_CreatePlanBottomSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _goalCtrl;
  late final TextEditingController _daysCtrl;
  late final TextEditingController _minutesCtrl;
  String _presetCoverAsset = _createPlanPresetCoverAssets.first;
  String? _galleryCoverRelPath;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _goalCtrl = TextEditingController();
    _daysCtrl = TextEditingController(text: '20');
    _minutesCtrl = TextEditingController(text: '30');
  }

  Future<void> _pickCoverFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) {
      return;
    }
    final Directory root = await getApplicationDocumentsDirectory();
    final String rel =
        'training_plan_covers/plan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File dest = File(p.join(root.path, rel));
    await dest.parent.create(recursive: true);
    await File(x.path).copy(dest.path);
    if (!mounted) {
      return;
    }
    setState(() => _galleryCoverRelPath = rel);
  }

  void _selectPresetCover(String asset) {
    setState(() {
      _presetCoverAsset = asset;
      _galleryCoverRelPath = null;
    });
  }

  Future<void> _submitCreate() async {
    final String name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
        const SnackBar(content: Text('Please enter a plan name')),
      );
      return;
    }
    if (widget.currentUserPlanCount >= WalletService.freeUserTrainingPlanCount) {
      final bool ok = await WalletService.instance.trySpendCoins(
        WalletService.trainingPlanOverQuotaCost,
      );
      if (!ok) {
        if (mounted) {
          showInsufficientCoinsSnackBar(widget.scaffoldContext);
        }
        return;
      }
    }
    final int days = int.tryParse(_daysCtrl.text.trim()) ?? 20;
    final int safeDays = days.clamp(1, 999);
    final _MyPlanData plan = _MyPlanData(
      name: name,
      progress: 0,
      progressLabel: 'Day 0 / $safeDays',
      assetPath: _presetCoverAsset,
      categoryTitle: 'Full-body fitness',
      libraryPlanName: 'Full-body circuit · Starter',
      coverRelPath: _galleryCoverRelPath,
    );
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
    widget.onCreated(plan);
    ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
      SnackBar(content: Text('Plan created: $name')),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _goalCtrl.dispose();
    _daysCtrl.dispose();
    _minutesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create training plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Plan name',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Summer shred challenge',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Cover image',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a preset or upload from your gallery',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _createPlanPresetCoverAssets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final String asset = _createPlanPresetCoverAssets[index];
                  final bool selected = _galleryCoverRelPath == null &&
                      _presetCoverAsset == asset;
                  return GestureDetector(
                    onTap: () => _selectPresetCover(asset),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? widget.brand
                              : Colors.grey.shade300,
                          width: selected ? 3 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        asset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickCoverFromGallery,
                    icon: const Icon(Icons.photo_library_outlined, size: 20),
                    label: const Text('Choose from gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.brandDeep,
                    ),
                  ),
                ),
                if (_galleryCoverRelPath != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Remove custom cover',
                    onPressed: () =>
                        setState(() => _galleryCoverRelPath = null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ],
            ),
            if (_galleryCoverRelPath != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: FutureBuilder<File?>(
                    future: _trainingPlanCoverFile(_galleryCoverRelPath!),
                    builder: (context, snap) {
                      final f = snap.data;
                      if (f != null) {
                        return Image.file(f, fit: BoxFit.cover);
                      }
                      return const ColoredBox(
                        color: Color(0xFFE0E0E0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Training goal',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _goalCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe what you want to achieve',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Plan length (days)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _daysCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '20',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Daily duration (min)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _minutesCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '30',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                unawaited(_submitCreate());
              },
              style: FilledButton.styleFrom(
                backgroundColor: widget.brand,
                foregroundColor: widget.brandDeep,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Create plan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingLibraryTab extends StatelessWidget {
  const _TrainingLibraryTab({
    required this.brand,
    required this.brandDark,
    required this.brandDeep,
    required this.categories,
    required this.libraryQuery,
    required this.onQueryChanged,
    required this.popularPlanTitles,
  });

  final Color brand;
  final Color brandDark;
  final Color brandDeep;
  final List<_TrainingCategoryData> categories;
  final String libraryQuery;
  final ValueChanged<String> onQueryChanged;
  final List<String> popularPlanTitles;

  @override
  Widget build(BuildContext context) {
    final q = libraryQuery.trim().toLowerCase();
    final filtered = q.isEmpty
        ? categories
        : categories
            .where(
              (c) =>
                  c.title.toLowerCase().contains(q) ||
                  c.subtitle.toLowerCase().contains(q),
            )
            .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 140,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/home_fitness_hero_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Duria training library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start moving every day',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Search categories…',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RecommendedCoursesPage(
                    appBarTitle: 'Featured training',
                    circleBackButton: true,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.playlist_add_check_rounded, size: 20),
            label: const Text('Featured training'),
            style: TextButton.styleFrom(foregroundColor: brandDark),
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final c = filtered[index];
            return _CategoryImageCard(
              data: c,
              brand: brand,
              brandDeep: brandDeep,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TrainingCategoryPlansPage(
                      category: c,
                      brand: brand,
                      brandDark: brandDark,
                      brandDeep: brandDeep,
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular picks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            Text(
              'Synced with recommended courses',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List<Widget>.generate(
          recommendedCourses.length.clamp(0, popularPlanTitles.length),
          (i) {
            final course = recommendedCourses[i];
            final String titleEn = popularPlanTitles[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PopularCourseTile(
                displayTitle: titleEn,
                course: course,
                brand: brand,
                brandDeep: brandDeep,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CourseDetailPage(
                        course: course,
                        circleBackButton: true,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryImageCard extends StatelessWidget {
  const _CategoryImageCard({
    required this.data,
    required this.brand,
    required this.brandDeep,
    required this.onTap,
  });

  final _TrainingCategoryData data;
  final Color brand;
  final Color brandDeep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: brand.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  data.assetPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PopularCourseTile extends StatelessWidget {
  const _PopularCourseTile({
    required this.displayTitle,
    required this.course,
    required this.brand,
    required this.brandDeep,
    required this.onTap,
  });

  final String displayTitle;
  final CourseItem course;
  final Color brand;
  final Color brandDeep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sub = '${_displayCourseLevel(course.level)} · ${course.duration}';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: brand.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  course.cover,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill, color: brand, size: 40),
            ],
          ),
        ),
      ),
    );
  }
}

String _displayCourseLevel(String level) {
  switch (level.toLowerCase()) {
    case 'beginner':
      return 'Beginner';
    case 'intermediate':
      return 'Intermediate';
    case 'advanced':
      return 'Advanced';
    default:
      return level;
  }
}

class _MyPlansTab extends StatelessWidget {
  const _MyPlansTab({
    required this.brand,
    required this.brandDark,
    required this.brandDeep,
    required this.plans,
  });

  final Color brand;
  final Color brandDark;
  final Color brandDeep;
  final List<_MyPlanData> plans;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: plans.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          );
        }
        final plan = plans[index - 1];
        return _MyPlanCard(
          plan: plan,
          brand: brand,
          brandDark: brandDark,
          brandDeep: brandDeep,
        );
      },
    );
  }
}

class _MyPlanCard extends StatelessWidget {
  const _MyPlanCard({
    required this.plan,
    required this.brand,
    required this.brandDark,
    required this.brandDeep,
  });

  final _MyPlanData plan;
  final Color brand;
  final Color brandDark;
  final Color brandDeep;

  void _openDetail(BuildContext context) {
    final lib = _libraryPlanForMyPlanData(plan);
    final cat = _trainingCategoryForTitle(plan.categoryTitle);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrainingPlanDetailPage(
          categoryTitle: cat.title,
          headerAssetPath: plan.assetPath,
          headerCoverRelPath: plan.coverRelPath,
          plan: lib,
          brand: brand,
          brandDark: brandDark,
          brandDeep: brandDeep,
          appBarTitle: plan.name,
          progressSummary: plan.progressLabel,
        ),
      ),
    );
  }

  Future<void> _openWorkout(BuildContext context) async {
    final LibraryTrainingPlan lib = _libraryPlanForMyPlanData(plan);
    await openMyPlanWorkoutWithMusicConsent(
      context,
      MyPlanWorkoutPage(
        myPlanTitle: plan.name,
        coverAssetPath: plan.assetPath,
        coverRelPath: plan.coverRelPath,
        plan: lib,
        brand: brand,
        brandDark: brandDark,
        brandDeep: brandDeep,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: brand.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _PlanCoverFitImage(
                  assetPath: plan.assetPath,
                  relPath: plan.coverRelPath,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Text(
                    plan.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: plan.progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          color: brand,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(plan.progress * 100).round()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: brandDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.progressLabel,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _openDetail(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: brandDark,
                          side: BorderSide(color: brand.withValues(alpha: 0.8)),
                        ),
                        child: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _openWorkout(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: brand,
                          foregroundColor: brandDark,
                        ),
                        child: const Text('Start workout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataAnalysisTab extends StatefulWidget {
  const _DataAnalysisTab({
    required this.brand,
    required this.brandDark,
    required this.brandDeep,
  });

  final Color brand;
  final Color brandDark;
  final Color brandDeep;

  @override
  State<_DataAnalysisTab> createState() => _DataAnalysisTabState();
}

class _DataAnalysisTabState extends State<_DataAnalysisTab> {
  late final VoidCallback _statsListener;
  TrainingWeekAggregate _aggregate = TrainingWeekAggregate.empty;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _statsListener = _reloadFromNotify;
    TrainingActivityStatsController.instance.addListener(_statsListener);
    _reload();
  }

  @override
  void dispose() {
    TrainingActivityStatsController.instance.removeListener(_statsListener);
    super.dispose();
  }

  void _reloadFromNotify() {
    _reload();
  }

  Future<void> _reload() async {
    final TrainingWeekAggregate next =
        await TrainingActivityStatsService.loadWeekAggregate(DateTime.now());
    if (!mounted) {
      return;
    }
    setState(() {
      _aggregate = next;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final agg = _aggregate;
    final maxDayMinutes = agg.minutesByDayIndex.fold<int>(
      0,
      (a, b) => a > b ? a : b,
    );
    final denom = maxDayMinutes > 0 ? maxDayMinutes : 1;

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/today_sport_progress_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'This week at a glance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Weekly stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Linked to My plans, Today sport, Daily check-in, and recommended courses',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Sessions',
                  value: '${agg.sessionCount}',
                  unit: '',
                  color: widget.brand,
                  textColor: widget.brandDeep,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  label: 'Total time',
                  value: '${agg.totalMinutes}',
                  unit: 'min',
                  color: const Color(0xFF43A047),
                  textColor: const Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  label: 'Burn',
                  value: '${agg.totalKcal}',
                  unit: 'kcal',
                  color: const Color(0xFFFFA726),
                  textColor: const Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Check-ins this week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          _WeekCalendarStrip(
            weekStart: weekStart,
            trainedWeekdays: agg.daysWithActivityWeekday,
            brand: widget.brand,
          ),
          const SizedBox(height: 24),
          Text(
            'Training volume',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.brand.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List<Widget>.generate(7, (i) {
                      final minutes = agg.minutesByDayIndex[i];
                      final barH = maxDayMinutes > 0
                          ? (120 * (minutes / denom)).clamp(4.0, 120.0)
                          : 0.0;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: barH,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      widget.brand.withValues(alpha: 0.5),
                                      widget.brand,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List<Widget>.generate(7, (i) {
                    final d = weekStart.add(Duration(days: i));
                    return SizedBox(
                      width: 36,
                      child: Text(
                        '${d.month}/${d.day}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AchievementCard(
                  icon: Icons.emoji_events_outlined,
                  label: 'Check-in streak',
                  value: '${agg.checkInStreakDays} d',
                  brand: widget.brand,
                  brandDark: widget.brandDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AchievementCard(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Weekly burn',
                  value: '${agg.totalKcal} kcal',
                  brand: widget.brand,
                  brandDark: widget.brandDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AchievementCard(
                  icon: Icons.trending_up,
                  label: 'Time vs last week',
                  value: agg.weekOverWeekLabel,
                  brand: widget.brand,
                  brandDark: widget.brandDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.textColor,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class _WeekCalendarStrip extends StatelessWidget {
  const _WeekCalendarStrip({
    required this.weekStart,
    required this.trainedWeekdays,
    required this.brand,
  });

  final DateTime weekStart;
  final Set<int> trainedWeekdays;
  final Color brand;

  static const List<String> _wd = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brand.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _wd
                .map(
                  (d) => Text(
                    d,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(7, (i) {
              final day = weekStart.add(Duration(days: i));
              final isToday = _isSameDate(day, DateTime.now());
              final done = trainedWeekdays.contains(day.weekday);
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? brand : Colors.grey[200],
                      border:
                          isToday ? Border.all(color: brand, width: 2) : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: done ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.brand,
    required this.brandDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color brand;
  final Color brandDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brand.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: brandDark, size: 26),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey[800]),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: brandDark,
            ),
          ),
        ],
      ),
    );
  }
}

List<LibraryTrainingPlan> libraryTrainingPlansForCategory(
    _TrainingCategoryData c) {
  return plansForTrainingCategoryTitle(c.title);
}

LibraryTrainingPlan _libraryPlanForMyPlanData(_MyPlanData data) {
  final _TrainingCategoryData cat =
      _trainingCategoryForTitle(data.categoryTitle);
  final List<LibraryTrainingPlan> list = libraryTrainingPlansForCategory(cat);
  final String want = _canonicalLibraryPlanName(data.libraryPlanName);
  for (final LibraryTrainingPlan p in list) {
    if (p.name == want) {
      return p;
    }
  }
  for (final LibraryTrainingPlan p in list) {
    if (p.name == data.libraryPlanName) {
      return p;
    }
  }
  throw StateError('Unknown library plan: ${data.libraryPlanName}');
}

enum _MyPlanWorkoutStepStatus { todo, current, done }

class MyPlanWorkoutPage extends StatefulWidget {
  const MyPlanWorkoutPage({
    super.key,
    required this.myPlanTitle,
    required this.coverAssetPath,
    this.coverRelPath,
    required this.plan,
    required this.brand,
    required this.brandDark,
    required this.brandDeep,
  });

  final String myPlanTitle;
  final String coverAssetPath;
  final String? coverRelPath;
  final LibraryTrainingPlan plan;
  final Color brand;
  final Color brandDark;
  final Color brandDeep;

  @override
  State<MyPlanWorkoutPage> createState() => _MyPlanWorkoutPageState();
}

class _MyPlanWorkoutPageState extends State<MyPlanWorkoutPage> {
  Timer? _timer;
  bool _running = false;
  int _elapsedSeconds = 0;

  List<LibraryTrainingStep> get _steps => widget.plan.steps;

  int get _totalSeconds =>
      _steps.fold<int>(0, (sum, step) => sum + step.minutes * 60);

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
          const SnackBar(content: Text('Workout complete')),
        );
        unawaited(
          TrainingActivityStatsService.recordSession(
            minutes: widget.plan.totalMinutes,
            source: TrainingActivitySource.myPlan,
          ),
        );
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

  _MyPlanWorkoutStepStatus _statusOfStep(int index) {
    var cursor = 0;
    for (var i = 0; i < _steps.length; i++) {
      final end = cursor + _steps[i].minutes * 60;
      if (i == index) {
        if (_elapsedSeconds >= end) return _MyPlanWorkoutStepStatus.done;
        if (_elapsedSeconds >= cursor && _elapsedSeconds < end) {
          return _MyPlanWorkoutStepStatus.current;
        }
        return _MyPlanWorkoutStepStatus.todo;
      }
      cursor = end;
    }
    return _MyPlanWorkoutStepStatus.todo;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.plan;
    final double progress = _totalSeconds == 0
        ? 0.0
        : (_elapsedSeconds / _totalSeconds).clamp(0.0, 1.0);
    final totalMin = p.totalMinutes;
    return Scaffold(
      appBar: AppBar(
        leading: const CoachCircleBackButton(),
        automaticallyImplyLeading: false,
        title: Text(
          widget.myPlanTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _PlanCoverFitImage(
                    assetPath: widget.coverAssetPath,
                    relPath: widget.coverRelPath,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.40),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${p.level} · ~$totalMin min · ${p.steps.length} blocks',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
                  Text(
                    'Timer: ${_format(_elapsedSeconds)} / ${_format(_totalSeconds)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(999),
                    color: widget.brand,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _toggleTimer,
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.brand,
                          foregroundColor: widget.brandDeep,
                        ),
                        child: Text(_running ? 'Pause' : 'Start'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.brandDark,
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Blocks & time',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          ...List<Widget>.generate(p.steps.length, (index) {
            final step = p.steps[index];
            final status = _statusOfStep(index);
            final statusText = switch (status) {
              _MyPlanWorkoutStepStatus.current => 'Current',
              _MyPlanWorkoutStepStatus.done => 'Done',
              _MyPlanWorkoutStepStatus.todo => 'Upcoming',
            };
            final Color statusColor = switch (status) {
              _MyPlanWorkoutStepStatus.current => widget.brandDark,
              _MyPlanWorkoutStepStatus.done => Colors.green,
              _MyPlanWorkoutStepStatus.todo => Colors.grey,
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
                        Chip(
                          label: Text(statusText),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Duration: ${step.minutes} min'),
                    const SizedBox(height: 4),
                    Text(
                      step.detail,
                      style: TextStyle(color: Colors.grey[700], height: 1.35),
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

class TrainingCategoryPlansPage extends StatelessWidget {
  const TrainingCategoryPlansPage({
    super.key,
    required this.category,
    required this.brand,
    required this.brandDark,
    required this.brandDeep,
  });

  final _TrainingCategoryData category;
  final Color brand;
  final Color brandDark;
  final Color brandDeep;

  @override
  Widget build(BuildContext context) {
    final plans = libraryTrainingPlansForCategory(category);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: const CoachCircleBackButton(),
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    category.assetPath,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 52,
                    child: Text(
                      category.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList.separated(
              itemCount: plans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: brand.withValues(alpha: 0.35)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TrainingPlanDetailPage(
                            categoryTitle: category.title,
                            headerAssetPath: category.assetPath,
                            plan: plan,
                            brand: brand,
                            brandDark: brandDark,
                            brandDeep: brandDeep,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  plan.name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: brand.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  plan.level,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: brandDeep,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '~ ${plan.totalMinutes} min · ${plan.steps.length} blocks',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'View full workout',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: brandDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TrainingPlanDetailPage extends StatelessWidget {
  const TrainingPlanDetailPage({
    super.key,
    required this.categoryTitle,
    required this.headerAssetPath,
    this.headerCoverRelPath,
    required this.plan,
    required this.brand,
    required this.brandDark,
    required this.brandDeep,
    this.appBarTitle,
    this.progressSummary,
  });

  final String categoryTitle;
  final String headerAssetPath;
  final String? headerCoverRelPath;
  final LibraryTrainingPlan plan;
  final Color brand;
  final Color brandDark;
  final Color brandDeep;
  final String? appBarTitle;
  final String? progressSummary;

  Future<void> _openWorkout(BuildContext context) async {
    final String workoutTitle = appBarTitle ?? plan.name;
    await openMyPlanWorkoutWithMusicConsent(
      context,
      MyPlanWorkoutPage(
        myPlanTitle: workoutTitle,
        coverAssetPath: headerAssetPath,
        coverRelPath: headerCoverRelPath,
        plan: plan,
        brand: brand,
        brandDark: brandDark,
        brandDeep: brandDeep,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String titleInBar = appBarTitle ?? plan.name;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  leading: const CoachCircleBackButton(),
                  expandedHeight: 140,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      titleInBar,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        _PlanCoverFitImage(
                          assetPath: headerAssetPath,
                          relPath: headerCoverRelPath,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(
                              label: Text(categoryTitle),
                              backgroundColor: brand.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: brandDeep,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(plan.level),
                              backgroundColor: Colors.grey[200],
                              visualDensity: VisualDensity.compact,
                            ),
                            const Spacer(),
                            Text(
                              '~ ${plan.totalMinutes} min total',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: brandDark,
                              ),
                            ),
                          ],
                        ),
                        if (progressSummary != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            progressSummary!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: brandDark,
                            ),
                          ),
                        ],
                        if (appBarTitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Today’s plan: ${plan.name}',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList.separated(
                    itemCount: plan.steps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final step = plan.steps[i];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: brand.withValues(alpha: 0.25),
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: brandDeep,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            step.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${step.minutes} min',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (step.detail.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        step.detail,
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Material(
            elevation: 8,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _openWorkout(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: brand,
                      foregroundColor: brandDeep,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Start workout'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
