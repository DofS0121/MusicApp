import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/artist_song.dart';
import '../models/song_info.dart';
import '../services/song_service.dart';
import '../config/api_config.dart';

class SongInfoTab extends StatefulWidget {
  final int songId;
  final int artistId;
  final int currentSongId;
  final void Function(ArtistSong song)? onPlaySong;

  const SongInfoTab({
    super.key,
    required this.songId,
    required this.artistId,
    required this.currentSongId,
    this.onPlaySong,
  });

  @override
  State<SongInfoTab> createState() => _SongInfoTabState();
}

class _SongInfoTabState extends State<SongInfoTab> {
  final songService = SongService();
  late Future<SongInfo> _info;
  late Future<List<ArtistSong>> _songs;

  @override
  void initState() {
    super.initState();
    _info = songService.getSongInfo(widget.songId);
    _songs = songService.getSongsByArtist(widget.artistId);
  }

  String fullUrl(String p) => "${ApiConfig.serverUrl}$p";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SongInfo>(
      future: _info,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final song = snap.data!;

        return FutureBuilder<List<ArtistSong>>(
          future: _songs,
          builder: (_, listSnap) {
            if (!listSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                Image.network(fullUrl(song.coverUrl),
                    fit: BoxFit.cover, width: double.infinity),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
                  child: Container(
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),

                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 120, 16, 32),
                  children: [
                    // INFO CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  fullUrl(song.coverUrl),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      song.artist,
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 12),

                          if (song.releaseDate != null)
                            _infoRow(
                              "Phát hành",
                              "${song.releaseDate!.day.toString().padLeft(2, '0')}/"
                                  "${song.releaseDate!.month.toString().padLeft(2, '0')}/"
                                  "${song.releaseDate!.year}",
                            ),

                          if (song.categories.isNotEmpty)
                            _infoRow(
                              "Thể loại",
                              song.categories.join(", "),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Bài hát của ca sĩ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...listSnap.data!.map((s) {
                      final isPlaying = s.id == widget.currentSongId;
                      return ListTile(
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
                          ),
                        ),
                        trailing: const Icon(Icons.play_arrow,
                            color: Colors.white70),
                        onTap: () => widget.onPlaySong?.call(s),
                      );
                    }),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(color: Colors.white54),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
