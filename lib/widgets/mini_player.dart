import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';
import '../services/favorite_service.dart';
import '../models/user_favorite.dart';
import '../config/api_config.dart';
import '../screens/song_detail_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  String fullUrl(String path) => "${ApiConfig.serverUrl}$path";

  /// ❤️ ADD FAVORITE (CHUNG LOGIC)
  Future<void> _addFavorite(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final player = context.read<PlayerProvider>();
    final song = player.currentSong;

    if (song == null) return;

    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng đăng nhập")),
      );
      return;
    }

    // ⛔ tránh trùng yêu thích
    if (song.isFavorite) return;

    try {
      await FavoriteService.addFavorite(
        UserFavorite(
          userId: auth.userId!,
          songId: song.id,
        ),
        auth.token!,
      );

      // ✅ cập nhật trạng thái dùng chung
      song.isFavorite = true;
      player.notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❤️ Đã thêm vào yêu thích")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Lỗi khi lưu yêu thích")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (_, player, __) {
        final song = player.currentSong;

        // ❌ Không có bài → ẩn MiniPlayer
        if (song == null) return const SizedBox();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SongDetailScreen(
                  song: song,
                  playlist: player.playlist,
                  index: player.currentIndex,
                ),
              ),
            );
          },
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  border: const Border(
                    top: BorderSide(color: Colors.white12),
                  ),
                ),
                child: Row(
                  children: [
                    // 🎧 COVER
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        fullUrl(song.coverUrl),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 🎵 INFO
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// ❤️ FAVORITE (TRƯỚC PLAY)
                    IconButton(
                      icon: Icon(
                        song.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      color: song.isFavorite
                          ? Colors.red
                          : Colors.white70,
                      iconSize: 22,
                      onPressed: () => _addFavorite(context),
                    ),

                    // ▶️ PLAY / PAUSE
                    IconButton(
                      icon: Icon(
                        player.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: player.togglePlay,
                    ),

                    // ❌ CLOSE
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 24,
                      ),
                      onPressed: player.stop,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
