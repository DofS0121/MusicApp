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

  String fullUrl(String path) => "${ApiConfig.serverUrl}$path";

  Future<void> _onPlaySong(BuildContext context, Song song, List<Song> playlist, int index) async {
    final player = context.read<PlayerProvider>();

    if (player.currentSong?.id != song.id) {
      try {
        final newViews = await _songService.increaseView(song.id);
        setState(() => song.views = newViews);
      } catch (_) {}
    }

    player.playSong(song: song, playlist: playlist, index: index);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(song: song, playlist: playlist, index: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fav = context.watch<FavoriteProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "🎧 Tất cả bài hát",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          if (auth.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: () => auth.logout(fav, context.read<PlayerProvider>()),
            ),
        ],
      ),

      body: FutureBuilder<List<Song>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          }

          final songs = snapshot.data!;
          final player = context.read<PlayerProvider>();

          if (songs.isEmpty) {
            return const Center(
              child: Text("Không có bài hát nào", style: TextStyle(color: Colors.white70)),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: songs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final song = songs[i];
                final isFav = fav.isFavorite(song.id);
                final isPlaying = player.currentSong?.id == song.id;

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _onPlaySong(context, song, songs, i),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: isPlaying
                          ? Colors.greenAccent.withOpacity(0.12)
                          : Colors.white.withOpacity(0.05),
                    ),
                    child: Row(
                      children: [
                        /// COVER
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            fullUrl(song.coverUrl),
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.music_note, size: 50, color: Colors.white54),
                          ),
                        ),

                        const SizedBox(width: 14),

                        /// INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  )),
                              Text(song.artist,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                  )),
                              Text(
                                "${song.views} lượt nghe",
                                style: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// PLAY
                        const Icon(Icons.play_circle_fill, color: Colors.greenAccent, size: 36),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
