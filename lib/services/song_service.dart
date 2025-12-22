import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../models/artist_song.dart';
import '../config/api_config.dart';

class SongService {
  Future<List<Song>> getSongs() async {
    final url = ApiConfig.songs;
    print("🎵 [GET SONGS] URL = $url");

    final res = await http.get(Uri.parse(url));

    print("🎵 [GET SONGS] Status = ${res.statusCode}");
    print("🎵 [GET SONGS] Body = ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to load songs");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Song.fromJson(e)).toList();
  }

  Future<List<ArtistSong>> getSongsByArtist(int artistId) async {
    final url = ApiConfig.songsByArtist(artistId);

    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw Exception("Failed to load artist songs");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => ArtistSong.fromJson(e)).toList();
  }



  Future<int> increaseView(int songId) async {
    final res = await http.post(
      Uri.parse(ApiConfig.increaseView(songId)),
    );

    if (res.statusCode != 200) {
      throw Exception("Increase view failed");
    }

    final data = jsonDecode(res.body);
    return data['views']; // 👈 view mới từ API
  }

  Future<List<Song>> searchSongs(String keyword) async {
    final url = ApiConfig.searchSongs(keyword);
    print("🔍 SEARCH = $url");

    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw Exception("Search failed");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Song.fromJson(e)).toList();
  }

}

