import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  final Dio _dio = Dio();

  // ================= LOGIN =================
  Future<Map<String, dynamic>?> login(
      String email,
      String password,
      ) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.login),
        headers: const {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Email": email,
          "Password": password,
        }),
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
      String email,
      String password,
      String fullName,
      ) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.register),
        headers: const {
          "Content-Type": "application/json",
        },
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
  Future<String?> uploadAvatar(
      int userId,
      String token,
      File file,
      ) async {
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
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return res.data["avatar"];
    } catch (e) {
      print("🔴 [UPLOAD AVATAR ERROR] $e");
      return null;
    }
  }
}
