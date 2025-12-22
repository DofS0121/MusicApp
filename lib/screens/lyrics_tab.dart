import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../services/lyrics_service.dart';
import '../config/api_config.dart';

class LyricsTab extends StatefulWidget {
  final int songId;
  final String coverUrl;
  final PlayerService playerService;

  const LyricsTab({
    super.key,
    required this.songId,
    required this.coverUrl,
    required this.playerService,
  });

  @override
  State<LyricsTab> createState() => _LyricsTabState();
}

class _LyricsTabState extends State<LyricsTab> {
  final lyricsService = LyricsService();
  List<Map<String, dynamic>> lyrics = [];
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    loadLyrics();
  }

  Future<void> loadLyrics() async {
    lyrics = await lyricsService.getLyricsBySong(widget.songId);
    setState(() {});
  }

  String fullUrl(String p) => "${ApiConfig.serverUrl}$p";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(fullUrl(widget.coverUrl),
            fit: BoxFit.cover, width: double.infinity),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xAA000000), Color(0x33000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        StreamBuilder<Duration>(
          stream: widget.playerService.player.positionStream,
          builder: (_, snap) {
            final sec = snap.data?.inSeconds ?? 0;
            for (int i = 0; i < lyrics.length; i++) {
              if (sec >= lyrics[i]['time']) currentIndex = i;
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 120, 24, 32),
              itemCount: lyrics.length,
              itemBuilder: (_, i) {
                final active = i == currentIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    lyrics[i]['text'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: active
                          ? Colors.yellowAccent
                          : Colors.white54,
                      fontSize: active ? 22 : 16,
                      fontWeight:
                      active ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
