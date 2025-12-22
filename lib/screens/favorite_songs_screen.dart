import 'dart:ui';
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
    _ensureFavoritesLoaded();
  }

  Future<void> _ensureFavoritesLoaded() async {
    final auth = context.read<AuthProvider>();
    final favoriteProvider = context.read<FavoriteProvider>();

    if (!auth.isAuthenticated) {
      setState(() => _loading = false);
      return;
    }

    /// 🔥 QUAN TRỌNG: nếu ids đang rỗng → load lại
    if (favoriteProvider.ids.isEmpty) {
      await favoriteProvider.loadFavorites(
        userId: auth.userId!,
        token: auth.token!,
      );
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  String fullUrl(String path) {
    if (path.startsWith('http')) return path;
    return "${ApiConfig.serverUrl}$path";
  }

  void _onPlaySong({
    required BuildContext context,
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
    final favoriteProvider = context.watch<FavoriteProvider>();
    final playerProvider = context.read<PlayerProvider>();

    /// ❌ CHƯA LOGIN
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

    /// ⏳ ĐANG LOAD FAVORITES
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E2C),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final favoriteIds = favoriteProvider.ids;

    /// ❗️KHÔNG CÓ FAVORITE
    if (favoriteIds.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E2C),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "❤️ Bài hát yêu thích",
            style: TextStyle(color: Colors.green),
          ),
        ),
        body: const Center(
          child: Text(
            "Chưa có bài hát yêu thích",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    /// 🔥 LẤY BÀI HÁT YÊU THÍCH TỪ PLAYLIST
    final favoriteSongs = playerProvider.playlist
        .where((s) => favoriteIds.contains(s.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        title: const Text(
          "❤️ Bài hát yêu thích",
          style: TextStyle(color: Colors.greenAccent),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: favoriteSongs.length,
            itemBuilder: (context, index) {
              final song = favoriteSongs[index];

              return Dismissible(
                key: ValueKey(song.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white, size: 28),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF2A2A3D),
                      title: const Text(
                        "Xóa yêu thích",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        "Bạn muốn xóa \"${song.title}\" khỏi danh sách yêu thích?",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            "Hủy",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Xóa"),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  await favoriteProvider.removeFavorite(
                    userId: auth.userId!,
                    songId: song.id,
                    token: auth.token!,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("💔 Đã xóa ${song.title} khỏi yêu thích"),
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () => _onPlaySong(
                    context: context,
                    song: song,
                    playlist: favoriteSongs,
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
      ),
    );
  }
}
