import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class LyricsService {
  Future<List<Map<String, dynamic>>> getLyricsBySong(int songId) async {
    final res = await http.get(
      Uri.parse(ApiConfig.lyricsBySong(songId)),
    );

    if (res.statusCode != 200) {
      throw Exception("Lyrics not found");
    }

    return List<Map<String, dynamic>>.from(
      jsonDecode(res.body),
    );
  }
}
