import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../services/favorite_service.dart';
import '../screens/song_detail_screen.dart';
import '../widgets/mini_player.dart';
import '../config/api_config.dart';

class FavoriteSongsScreen extends StatefulWidget {
  const FavoriteSongsScreen({super.key});

  @override
  FavoriteSongsScreenState createState() => FavoriteSongsScreenState();
}

class FavoriteSongsScreenState extends State<FavoriteSongsScreen> {
  Future<List<Song>>? _favoritesFuture;

  /// 🔁 BẮT BUỘC – để MainScreen gọi reload
  void reload() {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;

    setState(() {
      _favoritesFuture = FavoriteService.getFavoritesByUser(
        auth.userId!,
        auth.token!,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    reload();
  }

  String fullUrl(String path) {
    if (path.startsWith('http')) return path;
    return "${ApiConfig.serverUrl}$path";
  }

  /// ▶️ PLAY SONG (ĐƠN GIẢN – CHẠY NGAY)
  void _onPlaySong({
    required Song song,
    required List<Song> playlist,
    required int index,
  }) {
    final player = context.read<PlayerProvider>();

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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E2C),
        body: Center(
          child: Text(
            "Vui lòng đăng nhập",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("❤️ Bài hát yêu thích"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Song>>(
        future: _favoritesFuture,
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
                "Chưa có bài hát yêu thích",
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
                                  style: const TextStyle(color: Colors.white38),
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
