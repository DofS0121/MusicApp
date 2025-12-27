import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  final Dio _dio = Dio();

  // ================= LOGIN =================
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.login),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({"Email": email, "Password": password}),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      print("🔴 [LOGIN ERROR] $e");
      return null;
    }
  }

  // ================= REGISTER =================
  Future<Map<String, dynamic>?> register(
      String email, String password, String fullName) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.register),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "Email": email,
          "Password": password,
          "FullName": fullName,
        }),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }

      return null;
    } catch (e) {
      print("🔴 [REGISTER ERROR] $e");
      return null;
    }
  }

  // ================= UPLOAD AVATAR =================
  Future<String?> uploadAvatar(int userId, String token, File file) async {
    try {
      final url = "${ApiConfig.uploadAvatar}/$userId";

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path),
      });

      final res = await _dio.post(
        url,
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      return res.data["avatar"]?.toString();
    } catch (e) {
      print("🔴 [UPLOAD AVATAR ERROR] $e");
      return null;
    }
  }

  // =====================================================
  // ✏️ UPDATE THÔNG TIN USER (FullName / Email)
  // =====================================================
  Future<Map<String, dynamic>?> updateProfile({
    required int userId,
    required String token,
    required String fullName,
    required String email,
  }) async {
    try {
      final res = await _dio.put(
        "${ApiConfig.updateUser}/$userId",
        data: {
          "FullName": fullName,
          "Email": email,
        },
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      return res.data;
    } catch (e) {
      print("🔴 [UPDATE PROFILE ERROR] $e");
      return null;
    }
  }

  // =====================================================
  // 🖼 UPDATE AVATAR + THÔNG TIN CÙNG LÚC (OPTIONAL)
  // =====================================================
  Future<Map<String, dynamic>?> updateProfileWithAvatar({
    required int userId,
    required String token,
    required String fullName,
    required String email,
    File? avatarFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        "FullName": fullName,
        "Email": email,
        if (avatarFile != null)
          "Avatar": await MultipartFile.fromFile(avatarFile.path),
      });

      final res = await _dio.put(
        "${ApiConfig.updateUser}/$userId",
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      return res.data;
    } catch (e) {
      print("🔴 [UPDATE PROFILE + AVATAR ERROR] $e");
      return null;
    }
  }
}
