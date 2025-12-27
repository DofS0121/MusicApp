import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorite_provider.dart';
import '../services/song_service.dart';
import '../models/song.dart';
import '../config/api_config.dart';
import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';
import 'song_detail_screen.dart';
import '../widgets/mini_player.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final SongService _songService = SongService();
  final TextEditingController _searchController = TextEditingController();

  List<Song> _allSongs = [];
  List<Song> _displaySongs = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================= LOAD SONGS =================
  Future<void> _loadSongs() async {
    setState(() => _loading = true);

    try {
      final songs = await _songService.getSongs();
      if (!mounted) return;

      setState(() {
        _allSongs = songs;
        _displaySongs = songs;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String fullUrl(String path) => "${ApiConfig.serverUrl}$path";

  // ================= SEARCH =================
  void _onSearch(String keyword) {
    final text = keyword.trim().toLowerCase();

    if (text.isEmpty) {
      setState(() => _displaySongs = List.from(_allSongs));
      return;
    }

    setState(() {
      _displaySongs = _allSongs.where((song) {
        return song.title.toLowerCase().contains(text) ||
            song.artist.toLowerCase().contains(text);
      }).toList();
    });
  }

  // ================= CLEAR SEARCH =================
  void _clearSearch() {
    _searchController.clear();
    setState(() => _displaySongs = List.from(_allSongs));
  }

  // ================= PLAY =================
  Future<void> _onPlaySong(
      BuildContext context, Song song, int index) async {
    final player = context.read<PlayerProvider>();

    if (player.currentSong?.id != song.id) {
      try {
        final newViews = await _songService.increaseView(song.id);
        song.views = newViews;
        setState(() {});
      } catch (_) {}
    }

    player.playSong(
      song: song,
      playlist: _allSongs,
      index: index,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(
          song: song,
          playlist: _allSongs,
          index: index,
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fav = context.watch<FavoriteProvider>();
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "🎧 Tất cả bài hát",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          if (auth.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: () =>
                  auth.logout(fav, context.read<PlayerProvider>()),
            ),
        ],
      ),

      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.greenAccent),
      )
          : Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Tìm theo tên bài hát hoặc ca sĩ...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon:
                const Icon(Icons.search, color: Colors.white54),

                // ❌ CLEAR BUTTON
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.white70),
                  onPressed: _clearSearch,
                )
                    : null,

                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🎵 LIST SONGS
          Expanded(
            child: _displaySongs.isEmpty
                ? const Center(
              child: Text(
                "Không tìm thấy bài hát",
                style: TextStyle(color: Colors.white70),
              ),
            )
                : ListView.separated(
              padding:
              const EdgeInsets.fromLTRB(14, 8, 14, 90),
              itemCount: _displaySongs.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final song = _displaySongs[i];
                final isPlaying =
                    player.currentSong?.id == song.id;

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _onPlaySong(
                    context,
                    song,
                    _allSongs.indexOf(song),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: isPlaying
                          ? Colors.greenAccent.withOpacity(0.12)
                          : Colors.white.withOpacity(0.05),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(12),
                          child: Image.network(
                            fullUrl(song.coverUrl),
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.music_note,
                                size: 50,
                                color: Colors.white54),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                song.artist,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "${song.views} lượt nghe",
                                style: const TextStyle(
                                  color: Colors.white24,
                                  fontSize: 12,
                                ),
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
