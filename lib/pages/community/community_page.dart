import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/coach_moderation_service.dart';
import '../athletes/athletes_page.dart';
import '../athletes/coach_media_widgets.dart';
import '../athletes/report_page.dart';

class _CoachManifestEntry {
  const _CoachManifestEntry({
    required this.id,
    required this.nickname,
    required this.tagline,
    required this.skills,
    required this.avatar,
    required this.gallery,
    required this.video,
  });

  final String id;
  final String nickname;
  final String tagline;
  final List<String> skills;
  final String avatar;
  final List<String> gallery;
  final String video;

  factory _CoachManifestEntry.fromJson(Map<String, dynamic> m) {
    final List<dynamic> sk = m['skills'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> gal = m['gallery'] as List<dynamic>? ?? <dynamic>[];
    return _CoachManifestEntry(
      id: m['id'] as String? ?? '',
      nickname: m['nickname'] as String? ?? '',
      tagline: m['tagline'] as String? ?? '',
      skills: sk.map((e) => e.toString()).toList(),
      avatar: m['avatar'] as String? ?? '',
      gallery: gal.map((e) => e.toString()).toList(),
      video: m['video'] as String? ?? '',
    );
  }
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<_CoachManifestEntry> _coaches = <_CoachManifestEntry>[];
  bool _loading = true;
  String? _error;

  void _onModerationChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    CoachModerationService.instance.addListener(_onModerationChanged);
    _loadManifest();
  }

  @override
  void dispose() {
    CoachModerationService.instance.removeListener(_onModerationChanged);
    super.dispose();
  }

  List<_CoachManifestEntry> _visibleCoaches() {
    final CoachModerationService mod = CoachModerationService.instance;
    return _coaches.where((c) => !mod.isHidden(c.id)).toList();
  }

  /// Only the first coach in [coaches_manifest.json] order may show video.
  /// If that coach is blocked/muted/hidden, no other post takes over the video slot.
  String? get _manifestFirstCoachId =>
      _coaches.isEmpty ? null : _coaches.first.id;

  Future<void> _loadManifest() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await CoachModerationService.instance.load();
      final String raw = await rootBundle.loadString(
        'assets/Duria_Resource/coaches_manifest.json',
      );
      final Map<String, dynamic> root =
          jsonDecode(raw) as Map<String, dynamic>;
      final List<dynamic> arr = root['coaches'] as List<dynamic>? ?? [];
      final List<_CoachManifestEntry> list = arr
          .map(
            (dynamic e) => _CoachManifestEntry.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ),
          )
          .toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _coaches = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _showCoachModerationActionSheet(
    BuildContext parentContext,
    _CoachManifestEntry coach,
  ) {
    showCupertinoModalPopup<void>(
      context: parentContext,
      builder: (BuildContext sheetContext) {
        return CupertinoActionSheet(
          title: const Text('Post actions'),
          message: Text(
            coach.nickname,
            style: const TextStyle(fontSize: 15),
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.of(parentContext).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => CoachReportPage(
                      coachId: coach.id,
                      coachNickname: coach.nickname,
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
                await CoachModerationService.instance.blacklistCoach(coach.id);
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('Blocked ${coach.nickname}')),
                  );
                }
              },
              child: const Text('Block'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.pop(sheetContext);
                await CoachModerationService.instance.blockCoach(coach.id);
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('Muted ${coach.nickname}')),
                  );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[500]),
              const SizedBox(height: 12),
              Text(
                'Failed to load',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadManifest,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_coaches.isEmpty) {
      return Center(
        child: Text('No posts yet', style: TextStyle(color: Colors.grey[600])),
      );
    }

    final List<_CoachManifestEntry> visible = _visibleCoaches();
    final String? videoSlotCoachId = _manifestFirstCoachId;
    if (visible.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.visibility_off_outlined, size: 56, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Nothing to show',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Some content may be blocked or muted',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadManifest,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (BuildContext context, int index) {
          final _CoachManifestEntry c = visible[index];
          final bool showVideo = videoSlotCoachId != null &&
              c.id == videoSlotCoachId &&
              c.video.isNotEmpty;
          return _CoachFeedCard(
            coach: c,
            showVideo: showVideo,
            onModerationTap: () =>
                _showCoachModerationActionSheet(context, c),
          );
        },
      ),
    );
  }
}

class _CoachFeedCard extends StatelessWidget {
  const _CoachFeedCard({
    required this.coach,
    required this.showVideo,
    required this.onModerationTap,
  });

  final _CoachManifestEntry coach;
  final bool showVideo;
  final VoidCallback onModerationTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    openBundledCoachDetailFromManifestId(
                      context,
                      coachId: coach.id,
                    );
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: coach.avatar.isNotEmpty
                        ? AssetImage(coach.avatar)
                        : null,
                    child: coach.avatar.isEmpty
                        ? Text(
                            coach.nickname.isNotEmpty
                                ? coach.nickname.substring(0, 1)
                                : '?',
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coach.nickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coach.tagline,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                CoachCircleReportButton(onPressed: onModerationTap),
              ],
            ),
            if (coach.skills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: coach.skills
                    .map(
                      (s) => Chip(
                        label: Text(
                          s,
                          style: const TextStyle(fontSize: 12),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 14),
            if (showVideo && coach.video.isNotEmpty)
              CoachVideoPosterTile(
                futureThumb: CoachVideoThumbCache.assetFirstFrame(coach.video),
                height: 220,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          CoachAssetVideoPlayPage(assetPath: coach.video),
                    ),
                  );
                },
              )
            else if (!showVideo && coach.gallery.isNotEmpty)
              _CoachGalleryCarousel(images: coach.gallery)
            else
              SizedBox(
                height: 160,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.hide_image_outlined, size: 40),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoachGalleryCarousel extends StatefulWidget {
  const _CoachGalleryCarousel({required this.images});

  final List<String> images;

  @override
  State<_CoachGalleryCarousel> createState() => _CoachGalleryCarouselState();
}

class _CoachGalleryCarouselState extends State<_CoachGalleryCarousel> {
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imgs = widget.images;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int i) => setState(() => _pageIndex = i),
              itemCount: imgs.length,
              itemBuilder: (BuildContext context, int i) {
                return Image.asset(
                  imgs[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(imgs.length, (int i) {
            final bool active = i == _pageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: active
                    ? const Color(0xFF6366F1)
                    : Colors.grey[300],
              ),
            );
          }),
        ),
      ],
    );
  }
}
