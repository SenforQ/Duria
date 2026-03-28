import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class WorkoutMusicService extends ChangeNotifier {
  WorkoutMusicService._() {
    _player.playerStateStream.listen((_) {
      notifyListeners();
    });
  }

  static final WorkoutMusicService instance = WorkoutMusicService._();

  static const String presetAssetPath = 'assets/DuriaTimeMusic.mp3';

  final AudioPlayer _player = AudioPlayer();
  bool _sessionConfigured = false;
  bool _presetSourceLoaded = false;

  bool get isPlaying => _player.playing;

  Future<void> configureAudioSession() async {
    if (_sessionConfigured) {
      return;
    }
    final AudioSession session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ),
    );
    _sessionConfigured = true;
  }

  Future<void> playPreset() async {
    await configureAudioSession();
    final AudioSession session = await AudioSession.instance;
    await session.setActive(true);
    if (!_presetSourceLoaded) {
      await _player.setAsset(presetAssetPath);
      await _player.setLoopMode(LoopMode.one);
      _presetSourceLoaded = true;
    }
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await playPreset();
    }
  }
}
