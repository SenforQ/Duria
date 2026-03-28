import 'package:flutter/material.dart';

import '../services/workout_music_service.dart';

class WorkoutMusicFab extends StatefulWidget {
  const WorkoutMusicFab({super.key});

  @override
  State<WorkoutMusicFab> createState() => _WorkoutMusicFabState();
}

class _WorkoutMusicFabState extends State<WorkoutMusicFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    WorkoutMusicService.instance.addListener(_onMusicStateChanged);
    _onMusicStateChanged();
  }

  void _onMusicStateChanged() {
    if (!mounted) {
      return;
    }
    final bool playing = WorkoutMusicService.instance.isPlaying;
    if (playing) {
      if (!_spinController.isAnimating) {
        _spinController.repeat();
      }
    } else {
      _spinController.stop();
    }
  }

  @override
  void dispose() {
    WorkoutMusicService.instance.removeListener(_onMusicStateChanged);
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black45,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          WorkoutMusicService.instance.togglePlayPause();
        },
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: RotationTransition(
              turns: _spinController,
              child: const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
