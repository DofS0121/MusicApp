import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../config/api_config.dart';
import '../screens/song_detail_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  String fullUrl(String path) => "${ApiConfig.serverUrl}$path";

  @override
  Widget build(BuildContext context) {
    return Consumer3<PlayerProvider, FavoriteProvider, AuthProvider>(
      builder: (_, player, fav, auth, __) {
        final Song? song = player.currentSong;

        if (song == null) return const SizedBox.shrink();

        final bool isFavorite = fav.isFavorite(song.id);

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
                    /// 🎧 COVER
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        fullUrl(song.coverUrl),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.music_note, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// 🎵 INFO
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

                    /// ❤️ FAVORITE (FIX ĐÚNG LOGIC)
                    IconButton(
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      color: isFavorite ? Colors.red : Colors.white70,
                      iconSize: 22,
                      onPressed: () async {
                        if (!auth.isAuthenticated ||
                            auth.userId == null ||
                            auth.token == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("⚠️ Vui lòng đăng nhập"),
                            ),
                          );
                          return;
                        }

                        if (isFavorite) {
                          await fav.removeFavorite(
                            userId: auth.userId!,
                            songId: song.id,
                            token: auth.token!,
                          );
                        } else {
                          await fav.addFavorite(
                            userId: auth.userId!,
                            song: song, // 🔥 TRUYỀN SONG ĐẦY ĐỦ
                            token: auth.token!,
                          );
                        }
                      },
                    ),

                    /// ▶️ PLAY / PAUSE
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

                    /// ❌ CLOSE
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
