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
      print("🟡 [LOGIN] Email = $email");
      print("🟡 [LOGIN] Password = $password");

      final url = ApiConfig.login;
      print("🟡 [LOGIN] URL = $url");

      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Email": email,
          "Password": password,
        }),
      );

      print("🟡 [LOGIN] StatusCode = ${res.statusCode}");
      print("🟡 [LOGIN] ResponseBody = ${res.body}");

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
    final res = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Email": email,
        "Password": password,
        "FullName": fullName,
      }),
    );

    return res.statusCode == 200 ? jsonDecode(res.body) : null;
  }

  // ================= UPLOAD AVATAR =================
  Future<String?> uploadAvatar(int userId, File file) async {
    final url = "${ApiConfig.uploadAvatar}/$userId";

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path),
    });

    final res = await _dio.post(
      url,
      data: formData,
      options: Options(contentType: "multipart/form-data"),
    );

    return res.data["avatar"];
  }
}
