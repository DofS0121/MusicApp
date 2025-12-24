import 'package:flutter/material.dart';
import '../models/chart_song.dart';
import '../services/chart_service.dart';

class ChartProvider extends ChangeNotifier {
  String _type = 'realtime';
  bool loading = false;
  List<ChartSong> songs = [];

  String get type => _type;

  Future<void> loadChart(String type) async {
    _type = type;
    loading = true;
    notifyListeners();

    try {
      songs = await ChartService.getChart(type);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
