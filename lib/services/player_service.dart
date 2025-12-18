import 'package:just_audio/just_audio.dart';

class PlayerService {
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;
  PlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  String? _currentUrl;

  AudioPlayer get player => _player;
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  Future<void> play(String url) async {
    if (_currentUrl != url) {
      await _player.setUrl(url);
      _currentUrl = url;
    }
    await _player.play();
  }

  Future<void> pause() => _player.pause();
  Future<void> seek(Duration d) => _player.seek(d);
}
