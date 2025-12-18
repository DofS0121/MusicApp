import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/song_service.dart';
import '../models/song.dart';
import '../config/api_config.dart';
import '../providers/player_provider.dart';
import 'song_detail_screen.dart';
import '../widgets/mini_player.dart';

class SongListScreen extends StatelessWidget {
  const SongListScreen({super.key});

  String fullUrl(String path) =>
      "${ApiConfig.serverUrl}$path";

  @override
  Widget build(BuildContext context) {
    final songService = SongService();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("🎵 Songs"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Song>>(
        future: songService.getSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "❌ ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final songs = snapshot.data ?? [];
          if (songs.isEmpty) {
            return const Center(
              child: Text(
                "No songs found",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return Stack(
            children: [
              // 🎵 LIST
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                itemCount: songs.length,
                itemBuilder: (_, index) {
                  final song = songs[index];

                  return GestureDetector(
                    onTap: () {
                      // 🔥 PLAY QUA PROVIDER
                      context.read<PlayerProvider>().playSong(
                        song: song,
                        playlist: songs,
                        index: index,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SongDetailScreen(
                            song: song,
                            playlist: songs,
                            index: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              fullUrl(song.coverUrl),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  song.artist,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white70,
                            size: 36,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 🔥 MINI PLAYER (GLOBAL)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MiniPlayer(),
              ),
            ],
          );
        },
      ),
    );
  }
}
