import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'favorite_provider.dart';
import 'player_provider.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  String? _token;
  Map<String, dynamic>? _user;

  // ================= GETTER =================
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  int? get userId => _user?["id"];
  Map<String, dynamic>? get user => _user; // 🔥 BẮT BUỘC

  // ================= SAVE LOGIN =================
  Future<void> saveLoginData(
      String token,
      Map<String, dynamic> user,
      FavoriteProvider favoriteProvider,
      ) async {
    _token = token;
    _user = user;

    await _storage.write(key: "token", value: token);
    await _storage.write(key: "user", value: jsonEncode(user));

    await favoriteProvider.loadFavorites(
      userId: user["id"],
      token: token,
    );

    notifyListeners();
  }

  // ================= AUTO LOGIN =================
  Future<bool> tryAutoLogin(FavoriteProvider favoriteProvider) async {
    final t = await _storage.read(key: "token");
    final u = await _storage.read(key: "user");

    if (t == null || u == null) return false;

    _token = t;
    _user = jsonDecode(u);

    await favoriteProvider.loadFavorites(
      userId: _user!["id"],
      token: _token!,
    );

    notifyListeners();
    return true;
  }

  // ================= LOGOUT =================
  Future<void> logout(
      FavoriteProvider favoriteProvider,
      PlayerProvider playerProvider,
      ) async {
    _token = null;
    _user = null;

    favoriteProvider.clear();
    playerProvider.stopAndReset(); // 🔥 STOP NHẠC

    await _storage.deleteAll();
    notifyListeners();
  }
}
