import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/ai_coaches_data.dart';
import '../../data/duria_coaches_data.dart';
import '../../services/coach_moderation_service.dart';
import '../../services/custom_coach_storage.dart';
import '../../services/wallet_service.dart';
import '../../wallet_insufficient_helper.dart';
import '../ai/ai_chat_page.dart';
import 'coach_media_widgets.dart';
import 'coach_role_chat_page.dart';
import 'report_page.dart';

class AthletesPage extends StatefulWidget {
  const AthletesPage({super.key});

  @override
  State<AthletesPage> createState() => _AthletesPageState();
}

class _AthletesPageState extends State<AthletesPage> {
  CoachFilterKind _filter = CoachFilterKind.all;
  String _searchQuery = '';
  List<CustomCoachRecord> _customCoaches = <CustomCoachRecord>[];
  List<BundledCoachProfile> _bundledCoaches = <BundledCoachProfile>[];
  bool _bundledLoading = true;
  String? _bundledLoadError;
  final CustomCoachStorage _customStorage = CustomCoachStorage.instance;
  Directory? _documentsDirectory;

  static const List<CoachFilterKind> _filters = <CoachFilterKind>[
    CoachFilterKind.all,
    CoachFilterKind.realPerson,
    CoachFilterKind.ai,
    CoachFilterKind.custom,
  ];

  void _onModerationListChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    CoachModerationService.instance.addListener(_onModerationListChanged);
    CoachModerationService.instance.load().then((_) {
      if (mounted) setState(() {});
    });
    _reloadCustom();
    getApplicationDocumentsDirectory().then((d) {
      if (mounted) setState(() => _documentsDirectory = d);
    });
    _loadBundled();
  }

  @override
  void dispose() {
    CoachModerationService.instance.removeListener(_onModerationListChanged);
    super.dispose();
  }

  Future<void> _loadBundled() async {
    setState(() {
      _bundledLoading = true;
      _bundledLoadError = null;
    });
    try {
      final list = await DuriaCoachesManifest.loadBundledCoaches();
      if (!mounted) return;
      setState(() {
        _bundledCoaches = list;
        _bundledLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bundledCoaches = <BundledCoachProfile>[];
        _bundledLoading = false;
        _bundledLoadError = e.toString();
      });
    }
  }

  Future<void> _reloadCustom() async {
    final list = await _customStorage.loadAll();
    if (!mounted) return;
    setState(() => _customCoaches = list);
  }

  List<_CoachListEntry> _buildEntries() {
    final mod = CoachModerationService.instance;
    final bundled = _bundledCoaches
        .where((e) => !mod.isHidden(e.id))
        .map((e) => _CoachListEntry.bundled(e))
        .toList();
    final custom = _customCoaches
        .where((e) => !mod.isHidden(e.id))
        .map((e) => _CoachListEntry.custom(e))
        .toList();
    final aiList = aiCoachItems
        .where((e) => !mod.isHidden(e.id))
        .map((e) => _CoachListEntry.ai(e))
        .toList();
    return <_CoachListEntry>[...bundled, ...custom, ...aiList];
  }

  List<_CoachListEntry> _filteredEntries() {
    var list = _buildEntries();
    if (_filter != CoachFilterKind.all) {
      list = list.where((e) => e.filterKind == _filter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.trim();
      list = list.where((e) {
        if (e.nickname.contains(q) || e.tagline.contains(q)) return true;
        if (e.skills.any((s) => s.contains(q))) return true;
        final ai = e.ai;
        if (ai != null && ai.presetQuestions.any((p) => p.contains(q))) {
          return true;
        }
        return false;
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries();
    final Widget mainBody;
    if (_bundledLoading) {
      mainBody = const Center(child: CircularProgressIndicator());
    } else if (_bundledLoadError != null) {
      mainBody = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Failed to load coaches:\n$_bundledLoadError',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadBundled,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else {
      mainBody = Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search name, bio, or skills…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final f = _filters[index];
                final selected = f == _filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: FilterChip(
                    label: Text(f.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: const Color(0xFF8BC34A).withValues(alpha: 0.35),
                    checkmarkColor: const Color(0xFF33691E),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _filter == CoachFilterKind.custom
                              ? 'No custom coaches yet. Tap + to add one.'
                              : 'No coaches yet',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      return _CoachCard(
                        entry: entries[index],
                        documentsDirectory: _documentsDirectory,
                        onListModerated: () => setState(() {}),
                        onTap: () async {
                          final listEntry = entries[index];
                          final ai = listEntry.ai;
                          if (ai != null) {
                            await Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => AiChatPage(
                                  coachName: ai.nickname,
                                  coachAvatarUrl: ai.avatarUrl,
                                  presetQuestions: ai.presetQuestions,
                                ),
                              ),
                            );
                            return;
                          }
                          final doc = _documentsDirectory ??
                              await getApplicationDocumentsDirectory();
                          if (!context.mounted) return;
                          final shouldRefresh = await Navigator.of(context).push<bool>(
                            MaterialPageRoute<bool>(
                              builder: (_) => CoachDetailPage(
                                entry: listEntry,
                                documentsDirectory: doc,
                              ),
                            ),
                          );
                          if (!context.mounted) return;
                          if (shouldRefresh == true) {
                            await CoachModerationService.instance.load();
                            if (!context.mounted) return;
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Removed from coach list'),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Coaches',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_athletes_add_custom_coach',
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
              child: _AddCustomCoachSheet(
                onSaved: () {
                  Navigator.pop(ctx);
                  _reloadCustom();
                  setState(() => _filter = CoachFilterKind.custom);
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: mainBody,
    );
  }
}

class _CoachListEntry {
  _CoachListEntry._({
    required this.isBundled,
    required this.id,
    required this.filterKind,
    required this.nickname,
    required this.tagline,
    required this.skills,
    this.bundled,
    this.custom,
    this.ai,
  });

  factory _CoachListEntry.bundled(BundledCoachProfile p) {
    return _CoachListEntry._(
      isBundled: true,
      id: p.id,
      filterKind: p.category,
      nickname: p.nickname,
      tagline: p.tagline,
      skills: p.skills,
      bundled: p,
    );
  }

  factory _CoachListEntry.custom(CustomCoachRecord r) {
    return _CoachListEntry._(
      isBundled: false,
      id: r.id,
      filterKind: CoachFilterKind.custom,
      nickname: r.nickname,
      tagline: r.tagline,
      skills: r.skills,
      custom: r,
    );
  }

  factory _CoachListEntry.ai(AiCoachItem item) {
    return _CoachListEntry._(
      isBundled: false,
      id: item.id,
      filterKind: CoachFilterKind.ai,
      nickname: item.nickname,
      tagline: item.specialty,
      skills: <String>[item.specialty],
      ai: item,
    );
  }

  final bool isBundled;
  final String id;
  final CoachFilterKind filterKind;
  final String nickname;
  final String tagline;
  final List<String> skills;
  final BundledCoachProfile? bundled;
  final CustomCoachRecord? custom;
  final AiCoachItem? ai;

  String categoryLabel() {
    switch (filterKind) {
      case CoachFilterKind.all:
        return '';
      case CoachFilterKind.realPerson:
        return 'Real coaches';
      case CoachFilterKind.ai:
        return 'AI coaches';
      case CoachFilterKind.custom:
        return 'Custom';
    }
  }
}

void _showCoachModerationActionSheet(
  BuildContext context,
  _CoachListEntry entry, {
  VoidCallback? afterBlacklistOrBlock,
}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetContext) {
      return CupertinoActionSheet(
        title: Text(entry.nickname),
        message: const Text('Choose an action'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => CoachReportPage(
                    coachId: entry.id,
                    coachNickname: entry.nickname,
                  ),
                ),
              );
            },
            child: const Text('Report'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(sheetContext);
              await CoachModerationService.instance.blacklistCoach(entry.id);
              if (context.mounted) {
                afterBlacklistOrBlock?.call();
              }
            },
            child: const Text('Block'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(sheetContext);
              await CoachModerationService.instance.blockCoach(entry.id);
              if (context.mounted) {
                afterBlacklistOrBlock?.call();
              }
            },
            child: const Text('Mute'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancel'),
        ),
      );
    },
  );
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.entry,
    required this.documentsDirectory,
    required this.onTap,
    this.onListModerated,
  });

  final _CoachListEntry entry;
  final Directory? documentsDirectory;
  final VoidCallback onTap;
  final VoidCallback? onListModerated;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFF8BC34A).withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipOval(
                child: () {
                  final ai = entry.ai;
                  if (ai != null) {
                    return Image.network(
                      ai.avatarUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          width: 72,
                          height: 72,
                          child: Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  if (entry.isBundled) {
                    return Image.asset(
                      entry.bundled!.avatarAsset,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(),
                    );
                  }
                  final doc = documentsDirectory;
                  if (doc == null) {
                    return _avatarFallback();
                  }
                  final f = entry.custom!.resolveAvatar(doc);
                  if (!f.existsSync()) return _avatarFallback();
                  return Image.file(
                    f,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarFallback(),
                  );
                }(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.nickname,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            _showCoachModerationActionSheet(
                              context,
                              entry,
                              afterBlacklistOrBlock: onListModerated,
                            );
                          },
                          icon: Icon(
                            Icons.warning_amber_rounded,
                            size: 22,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8BC34A).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            entry.categoryLabel(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF33691E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: entry.skills.take(4).map((s) {
                        return Chip(
                          label: Text(s, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      width: 72,
      height: 72,
      color: const Color(0xFF8BC34A).withValues(alpha: 0.2),
      child: const Icon(Icons.person, size: 40, color: Color(0xFF558B2F)),
    );
  }
}

class CoachDetailPage extends StatelessWidget {
  const CoachDetailPage({
    super.key,
    required this.entry,
    required this.documentsDirectory,
  });

  final _CoachListEntry entry;
  final Directory documentsDirectory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: const CoachCircleBackButton(),
            actions: [
              CoachCircleMessageButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => CoachRoleChatPage(
                        coachId: entry.id,
                        coachName: entry.nickname,
                        avatarAsset:
                            entry.isBundled ? entry.bundled!.avatarAsset : null,
                        avatarFile: entry.isBundled
                            ? null
                            : entry.custom!.resolveAvatar(documentsDirectory),
                      ),
                    ),
                  );
                },
              ),
              CoachCircleReportButton(
                onPressed: () => _showCoachActions(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: null,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (entry.isBundled)
                    Image.asset(
                      entry.bundled!.galleryAssets.isNotEmpty
                          ? entry.bundled!.galleryAssets.first
                          : entry.bundled!.avatarAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Image.asset(entry.bundled!.avatarAsset, fit: BoxFit.cover),
                    )
                  else
                    _CustomHeaderImage(
                      record: entry.custom!,
                      documentsDirectory: documentsDirectory,
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 20,
                    child: Row(
                      children: [
                        ClipOval(
                          child: entry.isBundled
                              ? Image.asset(
                                  entry.bundled!.avatarAsset,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  entry.custom!.resolveAvatar(documentsDirectory),
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 72,
                                    height: 72,
                                    color: Colors.white24,
                                    child: const Icon(Icons.person, color: Colors.white),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                entry.categoryLabel(),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.tagline,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.nickname,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!entry.isBundled) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Bio',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.tagline.trim().isEmpty ? '—' : entry.tagline,
                      style: TextStyle(fontSize: 15, height: 1.45, color: Colors.grey[800]),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Skills',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.skills
                        .map(
                          (s) => Chip(
                            label: Text(s),
                            backgroundColor: const Color(0xFF8BC34A).withValues(alpha: 0.2),
                          ),
                        )
                        .toList(),
                  ),
                  if (entry.isBundled) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Gallery',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _GalleryBundled(paths: entry.bundled!.galleryAssets),
                    const SizedBox(height: 24),
                    const Text(
                      'Coaching video',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    CoachVideoPosterTile(
                      futureThumb: CoachVideoThumbCache.assetFirstFrame(
                        entry.bundled!.videoAsset,
                      ),
                      onTap: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => CoachAssetVideoPlayPage(
                              assetPath: entry.bundled!.videoAsset,
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    if (entry.custom!.resolveGallery(documentsDirectory).any((f) => f.existsSync())) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Gallery',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _GalleryCustom(
                        files: entry.custom!.resolveGallery(documentsDirectory),
                      ),
                    ],
                    if (entry.custom!.videoRelativePath != null &&
                        entry.custom!.resolveVideo(documentsDirectory)?.existsSync() == true) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Coaching video',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      CoachVideoPosterTile(
                        futureThumb: CoachVideoThumbCache.fileFirstFrame(
                          entry.custom!.resolveVideo(documentsDirectory)!.path,
                        ),
                        onTap: () {
                          final vf = entry.custom!.resolveVideo(documentsDirectory)!;
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => CoachFileVideoPlayPage(file: vf),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCoachActions(BuildContext context) {
    _showCoachModerationActionSheet(
      context,
      entry,
      afterBlacklistOrBlock: () {
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      },
    );
  }
}

class _CustomHeaderImage extends StatelessWidget {
  const _CustomHeaderImage({
    required this.record,
    required this.documentsDirectory,
  });

  final CustomCoachRecord record;
  final Directory documentsDirectory;

  @override
  Widget build(BuildContext context) {
    final g = record.resolveGallery(documentsDirectory);
    if (g.isNotEmpty && g.first.existsSync()) {
      return Image.file(g.first, fit: BoxFit.cover);
    }
    final a = record.resolveAvatar(documentsDirectory);
    if (a.existsSync()) {
      return Image.file(a, fit: BoxFit.cover);
    }
    return Container(
      color: const Color(0xFF8BC34A),
      child: const Center(child: Icon(Icons.fitness_center, size: 80, color: Colors.white)),
    );
  }
}

class _GalleryBundled extends StatelessWidget {
  const _GalleryBundled({required this.paths});

  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: paths.length,
      itemBuilder: (context, i) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.black12,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => CoachGalleryFullScreenPage.assets(
                      assetPaths: paths,
                      initialIndex: i,
                    ),
                  ),
                );
              },
              child: Image.asset(
                paths[i],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GalleryCustom extends StatelessWidget {
  const _GalleryCustom({required this.files});

  final List<File> files;

  @override
  Widget build(BuildContext context) {
    final exist = files.where((f) => f.existsSync()).toList();
    if (exist.isEmpty) {
      return Text('No gallery images yet', style: TextStyle(color: Colors.grey[600]));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: exist.length,
      itemBuilder: (context, i) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.black12,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => CoachGalleryFullScreenPage.files(
                      files: exist,
                      initialIndex: i,
                    ),
                  ),
                );
              },
              child: Image.file(
                exist[i],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddCustomCoachSheet extends StatefulWidget {
  const _AddCustomCoachSheet({required this.onSaved});

  final VoidCallback onSaved;

  @override
  State<_AddCustomCoachSheet> createState() => _AddCustomCoachSheetState();
}

class _AddCustomCoachSheetState extends State<_AddCustomCoachSheet> {
  final TextEditingController _nickname = TextEditingController();
  final TextEditingController _tagline = TextEditingController();
  final TextEditingController _skills = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _avatarPath;
  bool _saving = false;

  @override
  void dispose() {
    _nickname.dispose();
    _tagline.dispose();
    _skills.dispose();
    super.dispose();
  }

  String _ext(File f) {
    final e = p.extension(f.path).toLowerCase();
    return e.isEmpty ? '.jpg' : e;
  }

  Future<void> _save() async {
    if (_nickname.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a nickname')),
      );
      return;
    }
    if (_avatarPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose an avatar')),
      );
      return;
    }
    if (_tagline.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a bio')),
      );
      return;
    }
    final skillList = _skills.text
        .split(RegExp(r'[,，、\s]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (skillList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one skill')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final CustomCoachStorage storage = CustomCoachStorage.instance;
      final List<CustomCoachRecord> existing = await storage.loadAll();
      if (existing.length >= WalletService.freeCustomCoachCount) {
        final bool ok = await WalletService.instance.trySpendCoins(
          WalletService.customCoachOverQuotaCost,
        );
        if (!ok) {
          if (mounted) {
            showInsufficientCoinsSnackBar(context);
          }
          return;
        }
      }
      final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      final avatarRel = await storage.copyIntoMediaDir(
        File(_avatarPath!),
        '${id}_avatar${_ext(File(_avatarPath!))}',
      );
      final record = CustomCoachRecord(
        id: id,
        nickname: _nickname.text.trim(),
        tagline: _tagline.text.trim(),
        skills: skillList,
        avatarRelativePath: avatarRel,
        galleryRelativePaths: const <String>[],
        videoRelativePath: null,
      );
      await storage.add(record);
      if (mounted) widget.onSaved();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add custom coach',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Nickname',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nickname,
              decoration: const InputDecoration(
                hintText: 'Display name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bio',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagline,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Style, experience, or focus areas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Skills',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _skills,
              decoration: const InputDecoration(
                hintText: 'e.g. strength, running, yoga (comma-separated)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Avatar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _saving
                  ? null
                  : () async {
                      final x = await _picker.pickImage(source: ImageSource.gallery);
                      if (x != null) setState(() => _avatarPath = x.path);
                    },
              icon: const Icon(Icons.face),
              label: Text(_avatarPath == null ? 'Pick avatar' : 'Change avatar'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openBundledCoachDetailFromManifestId(
  BuildContext context, {
  required String coachId,
}) async {
  final List<BundledCoachProfile> list =
      await DuriaCoachesManifest.loadBundledCoaches();
  BundledCoachProfile? profile;
  for (final BundledCoachProfile e in list) {
    if (e.id == coachId) {
      profile = e;
      break;
    }
  }
  if (!context.mounted) {
    return;
  }
  if (profile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile unavailable')),
    );
    return;
  }
  final BundledCoachProfile resolved = profile;
  final Directory doc = await getApplicationDocumentsDirectory();
  if (!context.mounted) {
    return;
  }
  await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => CoachDetailPage(
        entry: _CoachListEntry.bundled(resolved),
        documentsDirectory: doc,
      ),
    ),
  );
}
