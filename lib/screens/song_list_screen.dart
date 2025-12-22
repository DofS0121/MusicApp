import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';

import '../services/song_service.dart';
import '../models/song.dart';
import '../config/api_config.dart';
import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';
import 'song_detail_screen.dart';
import '../widgets/mini_player.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final SongService _songService = SongService();
  late Future<List<Song>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = _songService.getSongs();
  }

  String fullUrl(String path) {
    return "${ApiConfig.serverUrl}$path";
  }

  /// ▶️ PLAY SONG
  Future<void> _onPlaySong({
    required BuildContext context,
    required Song song,
    required List<Song> playlist,
    required int index,
  }) async {
    final player = context.read<PlayerProvider>();

    if (player.currentSong?.id != song.id) {
      try {
        final newViews = await _songService.increaseView(song.id);
        setState(() => song.views = newViews);
      } catch (_) {}
    }

    player.playSong(
      song: song,
      playlist: playlist,
      index: index,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(
          song: song,
          playlist: playlist,
          index: index,
        ),
      ),
    );
  }

  /// 🚪 LOGOUT
  void _logout() {
    context.read<AuthProvider>()
        .logout(context.read<FavoriteProvider>(), context.read<PlayerProvider>());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("🎵 Songs", style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (auth.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: FutureBuilder<List<Song>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
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
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];

                  return GestureDetector(
                    onTap: () => _onPlaySong(
                      context: context,
                      song: song,
                      playlist: songs,
                      index: index,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          /// 🎧 COVER
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              fullUrl(song.coverUrl),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.music_note),
                            ),
                          ),
                          const SizedBox(width: 12),

                          /// 🎼 INFO
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
                                Text(
                                  song.artist,
                                  style: const TextStyle(color: Colors.white60),
                                ),
                                Text(
                                  "${song.views} lượt nghe",
                                  style:
                                  const TextStyle(color: Colors.white38),
                                ),
                              ],
                            ),
                          ),

                          /// ▶️ PLAY ICON
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

              /// 🔥 MINI PLAYER
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
