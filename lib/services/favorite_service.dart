import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/add_favorite_dto.dart';
import '../models/song.dart';

class FavoriteService {
  /// ❤️ ADD FAVORITE
  static Future<void> addFavorite({
    required int userId,
    required int songId,
    required String token,
  }) async {
    final dto = AddFavoriteDto(
      userId: userId,
      songId: songId,
    );

    final response = await http.post(
      Uri.parse(ApiConfig.addFavorite),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Add favorite failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// ❌ REMOVE FAVORITE
  static Future<void> removeFavorite({
    required int userId,
    required int songId,
    required String token,
  }) async {
    final dto = AddFavoriteDto(
      userId: userId,
      songId: songId,
    );

    final response = await http.delete(
      Uri.parse(ApiConfig.removeFavorite),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Remove favorite failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// 📄 GET FAVORITES
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
