import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chart_song.dart';

class ChartService {
  static Future<List<ChartSong>> getChart(String type) async {
    final url = "${ApiConfig.baseUrl}/charts/$type";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw Exception("Load chart failed");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => ChartSong.fromJson(e)).toList();
  }
}
