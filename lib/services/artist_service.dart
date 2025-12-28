import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/artist_song.dart';

class ArtistService {
  // 📌 Lấy thông tin nghệ sĩ
  Future<Map<String, dynamic>> getArtist(int artistId) async {
    final url = ApiConfig.artistDetail(artistId);
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) throw Exception("Artist not found");
    return jsonDecode(res.body);
  }

  // 📌 Lấy bài hát của nghệ sĩ
  Future<List<ArtistSong>> getSongs(int artistId) async {
    final url = ApiConfig.songsByArtist(artistId);
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) throw Exception("Không tìm thấy bài hát");
    final data = jsonDecode(res.body) as List;
    return data.map((x) => ArtistSong.fromJson(x)).toList();
  }

  // 📌 Kiểm tra đã follow chưa
  Future<bool> checkFollow(int artistId, int userId) async {
    final url = Uri.parse(ApiConfig.isArtistFollowed(artistId, userId));
    print("➡️ CHECK FOLLOW: $url");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print("📥 CHECK RESULT: $data");
      return data["isFollowed"] == true;
    }
    return false;
  }


// 📌 Follow (POST)
  Future<bool> follow(int artistId, int userId) async {
    final url = Uri.parse("${ApiConfig.followArtist}?artistId=$artistId&userId=$userId");
    print("➡️ CALL FOLLOW: $url");
    final res = await http.post(url);

    print("📩 RESPONSE: ${res.statusCode} | ${res.body}");
    return res.statusCode == 200;
  }

// 📌 Unfollow (DELETE)
  Future<bool> unfollow(int artistId, int userId) async {
    final url = Uri.parse("${ApiConfig.unfollowArtist}?artistId=$artistId&userId=$userId");
    print("➡️ CALL UNFOLLOW: $url");
    final res = await http.delete(url);

    print("📩 RESPONSE: ${res.statusCode} | ${res.body}");
    return res.statusCode == 200;
  }

  Future<List<dynamic>> getFollowedArtists(int userId) async {
    final url = Uri.parse("${ApiConfig.serverUrl}/api/artists/followed?userId=$userId");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Lỗi lấy danh sách nghệ sĩ đã follow");
    }
  }


}
