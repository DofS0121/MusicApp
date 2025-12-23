import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<int> _favoriteSongIds = {};

  bool isFavorite(int songId) => _favoriteSongIds.contains(songId);

  Set<int> get ids => _favoriteSongIds;

  /// 🔄 Load favorites
  Future<void> loadFavorites({
    required int userId,
    required String token,
  }) async {
    final songs =
    await FavoriteService.getFavoritesByUser(userId, token);

    _favoriteSongIds
      ..clear()
      ..addAll(songs.map((e) => e.id));

    notifyListeners();
  }

  /// ❤️ ADD
  Future<void> addFavorite({
    required int userId,
    required int songId,
    required String token,
  }) async {
    await FavoriteService.addFavorite(
      userId: userId,
      songId: songId,
      token: token,
    );

    _favoriteSongIds.add(songId);
    notifyListeners();
  }

  /// ❌ REMOVE
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
    notifyListeners();
  }

  void clear() {
    _favoriteSongIds.clear();
    notifyListeners();
  }
}
