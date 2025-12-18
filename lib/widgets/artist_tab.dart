import 'package:flutter/material.dart';
import '../models/song.dart';
import '../config/api_config.dart';

class ArtistTab extends StatelessWidget {
  final Song song;
  final List<Song> artistSongs;
  final void Function(int index) onSongTap;

  const ArtistTab({
    super.key,
    required this.song,
    required this.artistSongs,
    required this.onSongTap,
  });

  String fullUrl(String path) =>
      "http://${ApiConfig.host}:${ApiConfig.port}$path";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF4A148C),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // 👤 Artist avatar
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(fullUrl(song.coverUrl)),
          ),

          const SizedBox(height: 12),

          Text(
            song.artist,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Bài hát của ca sĩ",
              style: TextStyle(color: Colors.white70),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: artistSongs.length,
              itemBuilder: (context, index) {
                final s = artistSongs[index];
                return ListTile(
                  title: Text(s.title,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    s.artist,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  onTap: () => onSongTap(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
