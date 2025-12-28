import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/favorite_provider.dart';
import '../services/song_service.dart';
import '../models/song.dart';
import '../config/api_config.dart';
import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';
import 'song/song_detail_screen.dart';
import '../widgets/mini_player.dart';
import 'artist_detail_screen.dart';

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
  List<dynamic> _artistsResult = [];

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

  // 📌 LOAD tất cả bài hát
  Future<void> _loadSongs() async {
    try {
      final songs = await _songService.getSongs();
      if (!mounted) return;

      setState(() {
        _allSongs = songs;
        _displaySongs = songs;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String fullUrl(String p) => "${ApiConfig.serverUrl}$p";

  // 🔍 TÌM KIẾM (nghệ sĩ + bài hát)
  Future<void> _onSearch(String keyword) async {
    final text = keyword.trim().toLowerCase();
    if (text.isEmpty) {
      setState(() {
        _artistsResult = [];
        _displaySongs = List.from(_allSongs);
      });
      return;
    }

    // 1️⃣ Gọi API tìm nghệ sĩ theo keyword
    final artistRes = await http.get(Uri.parse(ApiConfig.searchArtists(text)));
    List artists = artistRes.statusCode == 200 ? jsonDecode(artistRes.body) : [];

    // 2️⃣ Lọc bài hát theo keyword
    final filteredSongs = _allSongs.where((s) =>
    s.title.toLowerCase().contains(text) ||
        s.artist.toLowerCase().contains(text)
    ).toList();

    // 3️⃣ Nếu tìm thấy bài hát nhưng nghệ sĩ chưa có trong artists => thêm vào danh sách
    for (var song in filteredSongs) {
      final exists = artists.any((a) => a["id"] == song.artistId);
      if (!exists) {
        artists.add({
          "id": song.artistId,
          "name": song.artist,
          "avatar": song.coverUrl, // hoặc để null nếu không có avatar riêng
          "totalSongs": _allSongs.where((x) => x.artistId == song.artistId).length,
        });
      }
    }

    setState(() {
      _artistsResult = artists;
      _displaySongs = filteredSongs;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _artistsResult = [];
      _displaySongs = List.from(_allSongs);
    });
  }

  // ▶️ PLAY SONG
  Future<void> _onPlaySong(Song song, int index) async {
    final player = context.read<PlayerProvider>();

    if (player.currentSong?.id != song.id) {
      try {
        song.views = await _songService.increaseView(song.id);
        setState(() {});
      } catch (_) {}
    }

    player.playSong(song: song, playlist: _allSongs, index: index);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(song: song, playlist: _allSongs, index: index),
      ),
    );
  }

  // 🚀 ĐI ĐẾN ARTIST DETAIL
  void _goToArtist(int artistId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArtistDetailScreen(artistId: artistId),
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
              onPressed: () => auth.logout(fav, context.read<PlayerProvider>()),
            ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : Column(
        children: [
          // 🔍 SEARCH FIELD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Tìm bài hát hoặc ca sĩ...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
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

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
              children: [
                // ⭐ ƯU TIÊN HIỂN THỊ NGHỆ SĨ TRƯỚC
                if (_artistsResult.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text("👤 Nghệ sĩ",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                  ..._artistsResult.map((a) {
                    final avatar = a["avatar"]; // đảm bảo lấy đúng trường

                    return ListTile(
                      onTap: () => _goToArtist(a["id"]),
                      leading: ClipOval(
                        child: Image.network(
                          avatar == null
                              ? "https://via.placeholder.com/80"
                              : (avatar.toString().startsWith("http")
                              ? avatar
                              : "${ApiConfig.serverUrl}$avatar"),
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, color: Colors.white38),
                        ),
                      ),
                      title: Text(a["name"], style: const TextStyle(color: Colors.white)),
                      subtitle: Text("${a["totalSongs"]} bài hát",
                          style: const TextStyle(color: Colors.white54)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                    );
                  }).toList(),
                  const Divider(color: Colors.white12, height: 26),
                ],

                // 🎵 BÀI HÁT KẾT QUẢ
                if (_displaySongs.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text("🎵 Bài hát",
                        style: TextStyle(color: Colors.white70)),
                  ),

                ..._displaySongs.map((song) {
                  final isPlaying = player.currentSong?.id == song.id;

                  return InkWell(
                    onTap: () => _onPlaySong(song, _allSongs.indexOf(song)),
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              fullUrl(song.coverUrl),
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.music_note, size: 50, color: Colors.white54),
                            ),
                          ),
                          const SizedBox(width: 14),
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
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.headphones,         // 🎧 icon
                                      size: 16,
                                      color: Colors.white60,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${song.views} lượt nghe",
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
                          const Icon(Icons.play_circle_fill,
                              color: Colors.greenAccent, size: 36),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
