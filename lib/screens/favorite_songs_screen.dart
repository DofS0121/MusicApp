import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../providers/favorite_provider.dart';
import '../screens/song_detail_screen.dart';
import '../widgets/mini_player.dart';
import '../config/api_config.dart';

class FavoriteSongsScreen extends StatefulWidget {
  const FavoriteSongsScreen({super.key});

  @override
  State<FavoriteSongsScreen> createState() => _FavoriteSongsScreenState();
}

class _FavoriteSongsScreenState extends State<FavoriteSongsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final auth = context.read<AuthProvider>();
    final fav = context.read<FavoriteProvider>();

    if (!auth.isAuthenticated) {
      setState(() => _loading = false);
      return;
    }

    await fav.loadFavorites(
      userId: auth.userId!,
      token: auth.token!,
    );

    if (mounted) setState(() => _loading = false);
  }

  String fullUrl(String path) =>
      path.startsWith('http') ? path : "${ApiConfig.serverUrl}$path";

  void _playSong({
    required Song song,
    required List<Song> playlist,
    required int index,
  }) {
    final player = context.read<PlayerProvider>();
    player.playSong(song: song, playlist: playlist, index: index);

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
    final fav = context.watch<FavoriteProvider>();
    final songs = fav.songs;

    // 🚫 Chưa đăng nhập
    if (!auth.isAuthenticated) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E2C),
        body: Center(
          child: Text("Vui lòng đăng nhập", style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    // 🔄 Loading
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E2C),
        body: Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    // ❌ Không có bài hát
    if (songs.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E2C),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("❤️ Bài hát yêu thích",
              style: TextStyle(color: Colors.greenAccent)),
        ),
        body: const Center(
          child: Text("Chưa có bài hát yêu thích",
              style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "❤️ Bài hát yêu thích",
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 90),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final s = songs[index];

          return GestureDetector(
            onTap: () => _playSong(
              song: s,
              playlist: songs,
              index: index,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white.withOpacity(0.06),
              ),
              child: Row(
                children: [
                  // 🎵 Cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      fullUrl(s.coverUrl),
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // 📌 Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          s.artist,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ❤️ Remove
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    onPressed: () async {
                      await fav.removeFavorite(
                        userId: auth.userId!,
                        songId: s.id,
                        token: auth.token!,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("💔 Đã bỏ yêu thích \"${s.title}\"")),
                      );
                    },
                  ),

                  // ▶️ Play
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill,
                        color: Colors.greenAccent, size: 36),
                    onPressed: () => _playSong(
                      song: s,
                      playlist: songs,
                      index: index,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
