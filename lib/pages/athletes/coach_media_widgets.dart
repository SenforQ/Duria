import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CoachVideoThumbCache {
  CoachVideoThumbCache._();
  static final Map<String, Future<Uint8List?>> _futures = <String, Future<Uint8List?>>{};

  static Future<Uint8List?> assetFirstFrame(String assetPath) {
    return _futures.putIfAbsent(
      'a:$assetPath',
      () => Future<Uint8List?>.value(null),
    );
  }

  static Future<Uint8List?> fileFirstFrame(String filePath) {
    return _futures.putIfAbsent(
      'f:$filePath',
      () => Future<Uint8List?>.value(null),
    );
  }
}

class CoachCircleBackButton extends StatelessWidget {
  const CoachCircleBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 8),
        child: Material(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black38,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed ?? () => Navigator.of(context).maybePop(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back, size: 22, color: Color(0xE6000000)),
            ),
          ),
        ),
      ),
    );
  }
}

class CoachCircleMessageButton extends StatelessWidget {
  const CoachCircleMessageButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 4),
        child: Material(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black38,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.chat_bubble_outline, size: 20, color: Color(0xE6000000)),
            ),
          ),
        ),
      ),
    );
  }
}

class CoachCircleReportButton extends StatelessWidget {
  const CoachCircleReportButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: Material(
          color: const Color(0xE6000000),
          elevation: 2,
          shadowColor: Colors.black38,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.warning_amber_rounded, size: 22, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class CoachVideoPosterTile extends StatelessWidget {
  const CoachVideoPosterTile({
    super.key,
    required this.futureThumb,
    required this.onTap,
    this.height = 200,
  });

  final Future<Uint8List?> futureThumb;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<Uint8List?>(
                future: futureThumb,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  }
                  return const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1C1E),
                    ),
                    child: SizedBox.expand(),
                  );
                },
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoachAssetVideoPlayPage extends StatefulWidget {
  const CoachAssetVideoPlayPage({super.key, required this.assetPath});

  final String assetPath;

  @override
  State<CoachAssetVideoPlayPage> createState() => _CoachAssetVideoPlayPageState();
}

class _CoachAssetVideoPlayPageState extends State<CoachAssetVideoPlayPage> {
  VideoPlayerController? _controller;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.asset(widget.assetPath);
      await c.initialize();
      if (!mounted) return;
      setState(() {
        _controller = c;
        _ready = true;
      });
      await c.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: const CoachCircleBackButton(),
        title: const Text('Coaching video'),
      ),
      body: Center(
        child: _error != null
            ? Text(_error!, style: const TextStyle(color: Colors.white70))
            : !_ready || _controller == null
                ? const CircularProgressIndicator(color: Colors.white)
                : AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
      ),
    );
  }
}

class CoachFileVideoPlayPage extends StatefulWidget {
  const CoachFileVideoPlayPage({super.key, required this.file});

  final File file;

  @override
  State<CoachFileVideoPlayPage> createState() => _CoachFileVideoPlayPageState();
}

class _CoachFileVideoPlayPageState extends State<CoachFileVideoPlayPage> {
  VideoPlayerController? _controller;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.file(widget.file);
      await c.initialize();
      if (!mounted) return;
      setState(() {
        _controller = c;
        _ready = true;
      });
      await c.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: const CoachCircleBackButton(),
        title: const Text('Coaching video'),
      ),
      body: Center(
        child: _error != null
            ? Text(_error!, style: const TextStyle(color: Colors.white70))
            : !_ready || _controller == null
                ? const CircularProgressIndicator(color: Colors.white)
                : AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
      ),
    );
  }
}

class CoachGalleryFullScreenPage extends StatefulWidget {
  CoachGalleryFullScreenPage.assets({
    super.key,
    required List<String> assetPaths,
    this.initialIndex = 0,
  })  : assetPaths = assetPaths,
        files = null,
        assert(assetPaths.isNotEmpty, 'assetPaths must not be empty');

  CoachGalleryFullScreenPage.files({
    super.key,
    required List<File> files,
    this.initialIndex = 0,
  })  : assetPaths = null,
        files = files,
        assert(files.isNotEmpty, 'files must not be empty');

  final List<String>? assetPaths;
  final List<File>? files;
  final int initialIndex;

  @override
  State<CoachGalleryFullScreenPage> createState() => _CoachGalleryFullScreenPageState();
}

class _CoachGalleryFullScreenPageState extends State<CoachGalleryFullScreenPage> {
  late final PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    final n = widget.assetPaths?.length ?? widget.files!.length;
    final maxIndex = n - 1;
    final safeInitial = widget.initialIndex.clamp(0, maxIndex);
    _current = safeInitial;
    _pageController = PageController(initialPage: safeInitial);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _count => widget.assetPaths?.length ?? widget.files!.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: const CoachCircleBackButton(),
        title: _count > 1
            ? Text('${_current + 1} / $_count')
            : const Text('Gallery'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _count,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (context, index) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final Widget imageChild = widget.assetPaths != null
                  ? Image.asset(
                      widget.assetPaths![index],
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    )
                  : Image.file(
                      widget.files![index],
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    );
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Center(child: imageChild),
              );
            },
          );
        },
      ),
    );
  }
}
