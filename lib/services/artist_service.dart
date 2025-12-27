import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ArtistService {
  Future<Map<String, dynamic>> getArtist(int artistId) async {
    final url = ApiConfig.artistDetail(artistId);

    print("🎤 [ARTIST API] GET = $url");

    final res = await http.get(Uri.parse(url));

    print("🎤 [ARTIST API] Status = ${res.statusCode}");
    print("🎤 [ARTIST API] Body = ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Artist not found");
    }

    return jsonDecode(res.body);
  }
}