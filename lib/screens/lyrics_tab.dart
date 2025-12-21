import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../services/lyrics_service.dart';

class LyricsTab extends StatefulWidget {
  final int songId;
  final PlayerService playerService;

  const LyricsTab({
    super.key,
    required this.songId,
    required this.playerService,
  });

  @override
  State<LyricsTab> createState() => _LyricsTabState();
}

class _LyricsTabState extends State<LyricsTab> {
  final lyricsService = LyricsService();
  final ScrollController _scrollController =
  ScrollController();

  List<Map<String, dynamic>> lyrics = [];
  int _currentIndex = -1;
  static const double lineHeight = 44;

  @override
  void initState() {
    super.initState();
    loadLyrics();
  }

  Future<void> loadLyrics() async {
    lyrics = await lyricsService
        .getLyricsBySong(widget.songId);
    setState(() {});
  }

  void _scrollTo(int index) {
    _scrollController.animateTo(
      index * lineHeight,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF1E1E2C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: StreamBuilder<Duration>(
        stream: widget.playerService.player.positionStream,
        builder: (_, snapshot) {
          final sec = snapshot.data?.inSeconds ?? 0;

          for (int i = 0; i < lyrics.length; i++) {
            final start = lyrics[i]['time'];
            final end = i + 1 < lyrics.length
                ? lyrics[i + 1]['time']
                : 99999;

            if (sec >= start &&
                sec < end &&
                _currentIndex != i) {
              _currentIndex = i;
              WidgetsBinding.instance
                  .addPostFrameCallback(
                      (_) => _scrollTo(i));
              break;
            }
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            itemCount: lyrics.length,
            itemBuilder: (_, i) {
              final active = i == _currentIndex;

              return SizedBox(
                height: lineHeight,
                child: Center(
                  child: Text(
                    lyrics[i]['text'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: active
                          ? Colors.yellowAccent
                          : Colors.white54,
                      fontSize: active ? 22 : 16,
                      fontWeight: active
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
