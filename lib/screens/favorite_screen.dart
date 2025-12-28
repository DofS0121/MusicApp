import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/mini_player.dart';
import '../config/api_config.dart';
import '../services/artist_service.dart';
import '../services/song_service.dart';
import 'song/song_detail_screen.dart';
import 'artist_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool loadingFollowed = true;
  List<dynamic> followedArtists = [];
  bool _isLoadingSongs = false;

  final SongService _songService = SongService();
  final ArtistService _artistService = ArtistService();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);

    // 🚀 Khi đổi tab → nếu tab CA SĨ → tự refresh danh sách follow
    _tab.addListener(() {
      if (_tab.index == 1) {
        _loadFollowedArtists();
      }
      setState(() {});
    });

    _loadFollowedArtists();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadFollowedArtists() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;

    setState(() => loadingFollowed = true);

    try {
      final data = await _artistService.getFollowedArtists(auth.userId!);
      setState(() {
        followedArtists = data;
        loadingFollowed = false;
      });
    } catch (e) {
      setState(() => loadingFollowed = false);
    }
  }

  String full(String p) => p.startsWith("http") ? p : "${ApiConfig.serverUrl}$p";

  // 🎧 PLAY SONG + tăng view
  Future<void> playSong(Song s, List<Song> list, int i) async {
    final player = context.read<PlayerProvider>();
    if (player.currentSong?.id != s.id) {
      try {
        s.views = await _songService.increaseView(s.id);
        setState(() {});
      } catch (_) {}
    }

    player.playSong(song: s, playlist: list, index: i);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(song: s, playlist: list, index: i),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final active = _tab.index == index;
    return GestureDetector(
      onTap: () => setState(() => _tab.index = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.greenAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fav = context.watch<FavoriteProvider>();
    final songs = fav.songs;

    if (!auth.isAuthenticated) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E2C),
        body: Center(
          child: Text("Vui lòng đăng nhập",
              style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "❤️ Yêu thích",
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton("Bài hát", 0),
              const SizedBox(width: 10),
              _buildTabButton("Ca sĩ", 1),
            ],
          ),
        ),
      ),

      body: TabBarView(
        controller: _tab,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // 🎵 TAB BÀI HÁT
          songs.isEmpty
              ? const Center(
              child: Text("Chưa có bài hát", style: TextStyle(color: Colors.white60)))
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 90),
            itemCount: songs.length,
            itemBuilder: (_, i) {
              final s = songs[i];
              final player = context.watch<PlayerProvider>();
              final fav = context.watch<FavoriteProvider>();
              final isPlaying = player.currentSong?.id == s.id;

              return InkWell(
                onTap: () => playSong(s, songs, i),
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
                      // 🎵 Cover
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          full(s.coverUrl),
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.music_note, size: 50, color: Colors.white54),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // 📌 Thông tin bài hát
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              s.artist,
                              style: const TextStyle(color: Colors.white60, fontSize: 14),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.headphones, size: 16, color: Colors.white60),
                                const SizedBox(width: 6),
                                Text(
                                  "${s.views} lượt nghe",
                                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ❤️ Favorite toggle
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.redAccent),
                        onPressed: () async {
                          // 👉 Xoá khỏi danh sách yêu thích
                          await fav.removeFavorite(
                            userId: auth.userId!,
                            songId: s.id,
                            token: auth.token!,
                          );

                          // 👉 Cập nhật giao diện sau khi xoá
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("💔 Đã bỏ yêu thích \"${s.title}\"")),
                          );
                        },
                      ),

                      // ▶️ Play
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill,
                            color: Colors.greenAccent, size: 36),
                        onPressed: () => playSong(s, songs, i),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),


          // ⭐ TAB CA SĨ FOLLOW
          loadingFollowed
              ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent))
              : followedArtists.isEmpty
              ? const Center(
              child: Text("Chưa theo dõi nghệ sĩ",
                  style: TextStyle(color: Colors.white60)))
              : ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: followedArtists.length,
            itemBuilder: (_, i) {
              final a = followedArtists[i];
              return InkWell(
                onTap: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArtistDetailScreen(artistId: a["id"]),
                    ),
                  );

                  // 🟢 Nếu có thay đổi follow → load lại danh sách
                  if (changed == true) {
                    await _loadFollowedArtists();
                  }
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          full(a["avatar"] ?? ""),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(a["name"],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600)),
                            Text("${a["totalSongs"]} bài hát",
                                style: const TextStyle(
                                    color: Colors.white60)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Colors.white54),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),

      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
