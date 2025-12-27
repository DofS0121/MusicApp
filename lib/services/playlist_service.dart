import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistService {
  static Future<List<Playlist>> getPlaylists(int userId) async {
    final res = await http.get(Uri.parse("${ApiConfig.playlistList}/$userId"));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)["playlists"] as List;
      return data.map((e) => Playlist.fromJson(e)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getPlaylistDetail(int playlistId) async {
    final res = await http.get(Uri.parse("${ApiConfig.playlistDetail}/$playlistId"));
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    return {
      "playlist": Playlist.fromJson(data["playlist"]),
      "songs": (data["songs"] as List).map((e) => Song.fromJson(e)).toList(),
    };
  }

  static Future<bool> createPlaylist(int userId, String name) async {
    final res = await http.post(
      Uri.parse(ApiConfig.playlistCreate + "?userId=$userId&name=$name"),
    );
    return res.statusCode == 200;
  }

  static Future<bool> addSong(int playlistId, int songId) async {
    final res = await http.post(
      Uri.parse(ApiConfig.playlistAddSong + "?playlistId=$playlistId&songId=$songId"),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deletePlaylist(int playlistId) async {
    final res = await http.delete(
      Uri.parse("${ApiConfig.playlistDelete}/$playlistId"),
    );
    return res.statusCode == 200;
  }

  static Future<bool> removeSong(int playlistId, int songId) async {
    final res = await http.delete(
      Uri.parse("${ApiConfig.playlistRemoveSong}?playlistId=$playlistId&songId=$songId"),
    );
    return res.statusCode == 200;
  }

  static Future<bool> renamePlaylist(int id, String newName) async {
    final url = "${ApiConfig.serverUrl}/api/playlist/rename?playlistId=$id&newName=$newName";
    final res = await http.put(Uri.parse(url));
    return res.statusCode == 200;
  }
}
