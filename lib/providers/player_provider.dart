import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/player_service.dart';
import '../config/api_config.dart';

class PlayerProvider extends ChangeNotifier {
  final PlayerService _playerService = PlayerService();

  Song? _currentSong;
  List<Song> _playlist = [];
  int _currentIndex = 0;

  // ================= GETTERS =================
  Song? get currentSong => _currentSong;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  PlayerService get playerService => _playerService;
  bool get isPlaying => _playerService.isPlaying;

  // ================= PRIVATE =================
  String _fullUrl(String path) {
    if (path.startsWith("http")) return path;
    return "${ApiConfig.serverUrl}$path";
  }

  // ================= ACTIONS =================
  void playSong({
    required Song song,
    required List<Song> playlist,
    required int index,
  }) {
    _currentSong = song;
    _playlist = playlist;
    _currentIndex = index;

    final url = _fullUrl(song.audioUrl);
    _playerService.play(url);

    notifyListeners();
  }

  void togglePlay() {
    if (_playerService.isPlaying) {
      _playerService.pause();
    } else if (_currentSong != null) {
      _playerService.play(_fullUrl(_currentSong!.audioUrl));
    }
    notifyListeners();
  }

  void next() {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      _currentSong = _playlist[_currentIndex];
      _playerService.play(_fullUrl(_currentSong!.audioUrl));
      notifyListeners();
    }
  }

  void prev() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _currentSong = _playlist[_currentIndex];
      _playerService.play(_fullUrl(_currentSong!.audioUrl));
      notifyListeners();
    }
  }

  // ================= ❌ STOP =================
  void stop() {
    _playerService.stop();     // dừng audio
    _currentSong = null;       // xoá bài hiện tại
    _playlist = [];
    _currentIndex = 0;

    notifyListeners();         // MiniPlayer tự ẩn
  }
}

