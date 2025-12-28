import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/api_config.dart';
import '../../services/player_service.dart';
import '../../services/lyrics_service.dart';

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
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    lyrics = await lyricsService.getLyricsBySong(widget.songId);
    setState(() {});
  }

  String fullUrl(String p) => "${ApiConfig.serverUrl}$p";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          fullUrl(widget.coverUrl),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            color: Colors.black.withOpacity(.3),
          ),
        ),

        StreamBuilder<Duration>(
          stream: widget.playerService.player.positionStream,
          builder: (_, snap) {
            final sec = snap.data?.inSeconds ?? 0;
            for (int i = 0; i < lyrics.length; i++) {
              if (sec >= lyrics[i]['time']) currentIndex = i;
            }

            /// Auto scroll to current
            if (controller.hasClients && currentIndex > 0) {
              controller.animateTo(
                (currentIndex * 60).toDouble(),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
              );
            }

            return ListView.builder(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(24, 140, 24, 100),
              itemCount: lyrics.length,
              itemBuilder: (_, i) {
                final active = i == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    lyrics[i]['text'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: active ? 22 : 16,
                      height: 1.4,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      color: active ? Colors.yellowAccent : Colors.white54,
                      shadows: active
                          ? [Shadow(color: Colors.yellowAccent, blurRadius: 20)]
                          : null,
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
