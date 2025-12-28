import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/playlist_service.dart';
import '../../services/song_service.dart';
import '../../models/song.dart';
import '../../models/playlist.dart';
import '../../config/api_config.dart';
import '../../providers/player_provider.dart';
import '../../providers/auth_provider.dart';
import '../song/song_detail_screen.dart';
import 'playlist_add_song_screen.dart';
import '../../widgets/mini_player.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final int playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  Playlist? playlist;
  List<Song> songs = [];
  final SongService _songService = SongService();

  Future<void> loadData() async {
    final data = await PlaylistService.getPlaylistDetail(widget.playlistId);
    if (data == null || !mounted) return;
    setState(() {
      playlist = data["playlist"];
      songs = data["songs"];
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> playSong(int index) async {
    final player = context.read<PlayerProvider>();
    final song = songs[index];

    try {
      song.views = await _songService.increaseView(song.id);
    } catch (_) {}

    player.playSong(song: song, playlist: songs, index: index);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(song: song, playlist: songs, index: index),
      ),
    );
  }

  void playShuffled() {
    final player = context.read<PlayerProvider>();
    final shuffleList = List<Song>.from(songs)..shuffle();
    final first = shuffleList.first;

    player.playSong(song: first, playlist: shuffleList, index: 0);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(song: first, playlist: shuffleList, index: 0),
      ),
    );
  }

  Future<void> removeSong(int id, String title) async {
    await PlaylistService.removeSong(widget.playlistId, id);
    loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🗑️ Đã xóa \"$title\" khỏi playlist")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final player = context.watch<PlayerProvider>();

    if (playlist == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E2C),
        body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
      );
    }

    final isEmpty = songs.isEmpty;
    final name = playlist!.name;
    final createdBy = user?["fullName"] ?? "User";

    // 👉 Tính tổng thời gian playlist
    int totalSec = songs.fold(0, (sum, s) => sum + s.duration);
    int hours = totalSec ~/ 3600;
    int minutes = (totalSec % 3600) ~/ 60;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Colors.greenAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          /// 🟣 COVER
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(14),
                image: playlist!.coverUrl != null
                    ? DecorationImage(
                  image: NetworkImage("${ApiConfig.serverUrl}${playlist!.coverUrl}"),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: playlist!.coverUrl == null
                  ? const Icon(Icons.music_note, size: 90, color: Colors.white30)
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          Text(name,
              style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
          Text("Tạo bởi $createdBy",
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 4),

          Text(
            "${songs.length} bài • ${hours > 0 ? "$hours giờ " : ""}$minutes phút",
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),

          const SizedBox(height: 18),

          /// 🎛️ BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isEmpty)
                ElevatedButton.icon(
                  onPressed: playShuffled,
                  icon: const Icon(Icons.shuffle),
                  label: const Text("Phát ngẫu nhiên"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.withOpacity(0.15),
                    foregroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              const SizedBox(width: 10),

              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistAddSongScreen(playlistId: playlist!.id),
                    ),
                  );
                  loadData();
                },
                icon: const Icon(Icons.add_circle),
                label: Text(isEmpty ? "Thêm bài vào playlist" : "Thêm bài"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(color: Colors.white10),

          /// 🎵 SONG LIST
          /// 🎵 SONG LIST (UI GIỐNG SONG_LIST_SCREEN)
          if (!isEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 140),
                itemCount: songs.length,
                itemBuilder: (_, i) {
                  final s = songs[i];
                  final isPlaying = player.currentSong?.id == s.id;

                  return Dismissible(
                    key: ValueKey(s.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 30),
                    ),
                    onDismissed: (_) => removeSong(s.id, s.title),

                    child: InkWell(
                      onTap: () => playSong(i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: isPlaying
                              ? Colors.greenAccent.withOpacity(0.12)
                              : Colors.white.withOpacity(0.05),
                        ),
                        child: Row(
                          children: [
                            // 📌 COVER
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                "${ApiConfig.serverUrl}${s.coverUrl}",
                                width: 65,
                                height: 65,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.music_note, size: 50, color: Colors.white54),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // 📌 INFO
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

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.headphones,
                                        size: 16,
                                        color: Colors.white60,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${s.views} lượt nghe",
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.play_circle_fill,
                              color: Colors.greenAccent,
                              size: 36,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),

      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
