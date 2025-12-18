import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/data_utils.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  String? _token;
  Map<String, dynamic>? _user;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  bool get isAuthenticated => _token != null;

  Future<void> saveLoginData(String token, Map<String, dynamic> user) async {
    print("🟢 [AuthProvider] Save token = $token");
    print("🟢 [AuthProvider] Save user = $user");

    _token = token;

    _user = {
      "UserID": user["id"],
      "Email": user["email"],
      "FullName": user["fullName"],
      "Avatar": user["avatar"] ?? "default.png",
      "Role": user["role"],
    };

    await _storage.write(key: "token", value: token);
    await _storage.write(key: "user", value: jsonEncode(_user));

    print("🟢 [AuthProvider] Stored user = $_user");

    notifyListeners();
  }


  Future<bool> tryAutoLogin() async {
    final t = await _storage.read(key: "token");
    final u = await _storage.read(key: "user");

    if (t == null || u == null) return false;

    _token = t;
    _user = jsonDecode(u);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}
