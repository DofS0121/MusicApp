import 'package:flutter/material.dart';
import '../services/song_service.dart';
import '../services/playlist_service.dart';
import '../models/song.dart';
import '../config/api_config.dart';

class PlaylistAddSongScreen extends StatefulWidget {
  final int playlistId;
  const PlaylistAddSongScreen({super.key, required this.playlistId});

  @override
  State<PlaylistAddSongScreen> createState() => _PlaylistAddSongScreenState();
}

class _PlaylistAddSongScreenState extends State<PlaylistAddSongScreen> {
  final SongService _songService = SongService();
  List<Song> songs = [];
  List<int> inPlaylist = [];
  bool loading = true;

  Future<void> loadData() async {
    try {
      final all = await _songService.getSongs();
      final detail = await PlaylistService.getPlaylistDetail(widget.playlistId);

      if (detail != null) {
        final list = detail["songs"] as List<dynamic>;
        inPlaylist = list.map<int>((item) => item.id).toList();
      }

      songs = all;
    } catch (e) {
      debugPrint("❌ loadData error: $e");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> add(int id, String title) async {
    await PlaylistService.addSong(widget.playlistId, id);
    inPlaylist.add(id);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("➕ Đã thêm \"$title\" vào playlist")),
    );
  }

  String full(String p) => "${ApiConfig.serverUrl}$p";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Thêm bài hát",
          style: TextStyle(color: Colors.greenAccent, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.greenAccent),
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
        itemCount: songs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),

        itemBuilder: (_, i) {
          final s = songs[i];
          if (inPlaylist.contains(s.id)) return const SizedBox();

          return Dismissible(
            key: ValueKey(s.id),
            direction: DismissDirection.startToEnd,
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              color: Colors.greenAccent.withOpacity(0.12),
              child: const Icon(Icons.add_circle, color: Colors.greenAccent, size: 32),
            ),
            onDismissed: (_) => add(s.id, s.title),

            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => add(s.id, s.title),

              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        full(s.coverUrl),
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.music_note, color: Colors.white54, size: 40),
                      ),
                    ),
                    const SizedBox(width: 14),

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
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            s.artist,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
                      onPressed: () => add(s.id, s.title),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
