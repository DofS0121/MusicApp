import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/artist_song.dart';
import '../services/song_service.dart';
import '../services/artist_service.dart';
import '../services/player_service.dart';
import '../config/api_config.dart';

class ArtistTab extends StatefulWidget {
  final Song song;
  final int currentSongId;
  final void Function(ArtistSong song)? onPlaySong;

  const ArtistTab({
    super.key,
    required this.song,
    required this.currentSongId,
    this.onPlaySong,
  });

  @override
  State<ArtistTab> createState() => _ArtistTabState();
}

class _ArtistTabState extends State<ArtistTab> {
  late Future<List<dynamic>> _future;

  final artistService = ArtistService();
  final songService = SongService();
  final playerService = PlayerService();

  @override
  void initState() {
    super.initState();
    _future = Future.wait([
      artistService.getArtist(widget.song.artistId),
      songService.getSongsByArtist(widget.song.artistId),
    ]);
  }

  String fullUrl(String path) =>
      "${ApiConfig.serverUrl}$path";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }

        final artist =
        snapshot.data![0] as Map<String, dynamic>;
        final songs =
        snapshot.data![1] as List<ArtistSong>;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🎤 Artist card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      fullUrl(artist['avatar']),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    artist['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artist['bio'] ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ...songs.map((s) {
              final isPlaying =
                  s.id == widget.currentSongId;

              return ListTile(
                tileColor: isPlaying
                    ? Colors.white.withOpacity(0.15)
                    : Colors.transparent,
                leading: Icon(
                  isPlaying
                      ? Icons.graphic_eq
                      : Icons.music_note,
                  color: isPlaying
                      ? Colors.greenAccent
                      : Colors.white70,
                ),
                title: Text(
                  s.title,
                  style: TextStyle(
                    color: isPlaying
                        ? Colors.greenAccent
                        : Colors.white,
                    fontWeight: isPlaying
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: const Icon(Icons.more_vert,
                    color: Colors.white54),
                onTap: () {
                  playerService
                      .play(fullUrl(s.audioUrl));
                  widget.onPlaySong?.call(s);
                },
              );
            }),
          ],
        );
      },
    );
  }
}
