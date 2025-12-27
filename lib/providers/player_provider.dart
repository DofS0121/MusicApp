import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/player_service.dart';
import '../config/api_config.dart';

class PlayerProvider extends ChangeNotifier {
  final PlayerService _playerService = PlayerService();

  Song? _currentSong;
  List<Song> _playlist = [];
  int _currentIndex = 0;

  Song? get currentSong => _currentSong;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _playerService.isPlaying;
  PlayerService get playerService => _playerService;

  // ====================== LOOP & SHUFFLE ======================
  bool _shuffle = false;
  int _loopMode = 1; // 0: off, 1: all, 2: one

  bool get isShuffle => _shuffle;
  int get loopMode => _loopMode;

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void toggleLoopMode() {
    _loopMode = (_loopMode + 1) % 3;
    notifyListeners();
  }

  // ====================== UTIL ======================
  String _fullUrl(String path) {
    return path.startsWith("http") ? path : "${ApiConfig.serverUrl}$path";
  }

  // ====================== MAIN CONTROLS ======================
  void playSong({required Song song, required List<Song> playlist, required int index}) {
    _playlist = playlist;
    _currentSong = song;
    _currentIndex = index;

    _playerService.play(_fullUrl(song.audioUrl));
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

  // ====================== NEXT ======================
  void next() {
    if (_playlist.isEmpty) return;

    if (_loopMode == 2) {
      _playerService.play(_fullUrl(_currentSong!.audioUrl));
    } else if (_shuffle) {
      _currentIndex = _pickRandomIndex();
      _currentSong = _playlist[_currentIndex];
      _playerService.play(_fullUrl(_currentSong!.audioUrl));
    } else {
      if (_currentIndex < _playlist.length - 1) {
        _currentIndex++;
      } else if (_loopMode == 1) {
        _currentIndex = 0;
      } else {
        stop();
        return;
      }
      _currentSong = _playlist[_currentIndex];
      _playerService.play(_fullUrl(_currentSong!.audioUrl));
    }
    notifyListeners();
  }

  int _pickRandomIndex() {
    final available = List<int>.generate(_playlist.length, (i) => i)
      ..remove(_currentIndex);
    available.shuffle();
    return available.first;
  }

  // ====================== PREV ======================
  void prev() {
    if (_playlist.isEmpty) return;

    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_loopMode == 1) {
      _currentIndex = _playlist.length - 1;
    }

    _currentSong = _playlist[_currentIndex];
    _playerService.play(_fullUrl(_currentSong!.audioUrl));
    notifyListeners();
  }

  // ====================== STOP ======================
  void stop() {
    _playerService.stop();
    _currentSong = null;
    _playlist = [];
    _currentIndex = 0;
    notifyListeners();
  }
  void stopAndReset() {
    _playerService.stop();
    _playlist = [];
    _currentIndex = 0;
    _currentSong = null;
    notifyListeners();
  }

  void updateSongView(int songId, int views) {
    final idx = playlist.indexWhere((s) => s.id == songId);
    if (idx != -1) {
      playlist[idx].views = views;
      notifyListeners();
    }
  }
}
