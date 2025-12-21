import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/song.dart';
import '../models/user_favorite.dart';

class FavoriteService {
  /// ❤️ Thêm bài hát vào yêu thích
  static Future<void> addFavorite(
      UserFavorite favorite,
      String token,
      ) async {
    final response = await http.post(
      Uri.parse(ApiConfig.addFavorite),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(favorite.toJson()),
    );


    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception(
        'Add favorite failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// 📄 Lấy danh sách bài hát yêu thích
  static Future<List<Song>> getFavoritesByUser(
      int userId,
      String token,
      ) async {
    final response = await http.get(
      Uri.parse(ApiConfig.getFavoritesByUser(userId)),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception(
        'Load favorites failed: ${response.statusCode}',
      );
    }
  }
}
