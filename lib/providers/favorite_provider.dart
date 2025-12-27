import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<int> _favoriteSongIds = {};
  final List<Song> _favoriteSongs = [];

  // ===== GETTERS =====
  Set<int> get ids => _favoriteSongIds;
  List<Song> get songs => List.unmodifiable(_favoriteSongs);

  bool isFavorite(int songId) => _favoriteSongIds.contains(songId);

  int get favoritesCount => _favoriteSongIds.length;


  // ===== LOAD FAVORITES =====
  Future<void> loadFavorites({
    required int userId,
    required String token,
  }) async {
    final songs =
    await FavoriteService.getFavoritesByUser(userId, token);

    _favoriteSongIds
      ..clear()
      ..addAll(songs.map((e) => e.id));

    _favoriteSongs
      ..clear()
      ..addAll(songs);

    notifyListeners();
  }

  // ===== ADD FAVORITE =====
  Future<void> addFavorite({
    required int userId,
    required Song song,
    required String token,
  }) async {
    await FavoriteService.addFavorite(
      userId: userId,
      songId: song.id,
      token: token,
    );

    if (!_favoriteSongIds.contains(song.id)) {
      _favoriteSongIds.add(song.id);
      _favoriteSongs.add(song);
      notifyListeners();
    }
  }

  // ===== REMOVE FAVORITE =====
  Future<void> removeFavorite({
    required int userId,
    required int songId,
    required String token,
  }) async {
    await FavoriteService.removeFavorite(
      userId: userId,
      songId: songId,
      token: token,
    );

    _favoriteSongIds.remove(songId);
    _favoriteSongs.removeWhere((s) => s.id == songId);

    notifyListeners();
  }

  // ===== CLEAR (logout) =====
  void clear() {
    _favoriteSongIds.clear();
    _favoriteSongs.clear();
    notifyListeners();
  }

  Future<void> toggleFavorite({
    required int userId,
    required Song song,
    required String token,
  }) async {
    if (isFavorite(song.id)) {
      await removeFavorite(userId: userId, songId: song.id, token: token);
    } else {
      await addFavorite(userId: userId, song: song, token: token);
    }
  }
}
