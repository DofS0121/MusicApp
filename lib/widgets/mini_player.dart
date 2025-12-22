import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../config/api_config.dart';
import '../screens/song_detail_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  String fullUrl(String path) => "${ApiConfig.serverUrl}$path";

  /// ❤️ ADD FAVORITE – QUA FAVORITE PROVIDER
  Future<void> _toggleFavorite(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final fav = context.read<FavoriteProvider>();
    final player = context.read<PlayerProvider>();
    final song = player.currentSong;

    if (song == null) return;

    if (!auth.isAuthenticated ||
        auth.userId == null ||
        auth.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng đăng nhập")),
      );
      return;
    }

    // ⛔ đã yêu thích thì không add lại (chưa làm remove)
    if (fav.isFavorite(song.id)) return;

    try {
      await fav.addFavorite(
        userId: auth.userId!,
        songId: song.id,
        token: auth.token!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❤️ Đã thêm vào yêu thích")),
      );
    } catch (e) {
      debugPrint("❌ ADD FAVORITE ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Lỗi khi lưu yêu thích")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PlayerProvider, FavoriteProvider, AuthProvider>(
      builder: (_, player, fav, auth, __) {
        final song = player.currentSong;

        if (song == null) return const SizedBox();

        final isFavorite = fav.isFavorite(song.id);

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

                    /// ❤️ FAVORITE (ĐỒNG BỘ)
                    Consumer<FavoriteProvider>(
                      builder: (_, fav, __) {
                        final isFav = fav.isFavorite(song.id);

                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                          ),
                          color: isFav ? Colors.red : Colors.white70,
                          iconSize: 22,
                          onPressed: () async {
                            final auth = context.read<AuthProvider>();
                            if (!auth.isAuthenticated) return;

                            if (isFav) {
                              await fav.removeFavorite(
                                userId: auth.userId!,
                                songId: song.id,
                                token: auth.token!,
                              );
                            } else {
                              await fav.addFavorite(
                                userId: auth.userId!,
                                songId: song.id,
                                token: auth.token!,
                              );
                            }
                          },
                        );
                      },
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
