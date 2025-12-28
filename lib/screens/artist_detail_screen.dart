import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../providers/favorite_provider.dart';
import '../services/artist_service.dart';
import '../services/song_service.dart';
import '../models/song.dart';
import '../models/artist_song.dart';
import 'song/song_detail_screen.dart';
import '../widgets/mini_player.dart';

class ArtistDetailScreen extends StatefulWidget {
  final int artistId;
  const ArtistDetailScreen({super.key, required this.artistId});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  Map<String, dynamic>? artist;
  List<Song> songs = [];
  bool isFollowing = false;
  bool loading = true;
  bool showFullBio = false;
  final SongService _songService = SongService();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final auth = context.read<AuthProvider>();
    final fav = context.read<FavoriteProvider>();
    final service = ArtistService();


    final data = await service.getArtist(widget.artistId);
    final artistSongs = await service.getSongs(widget.artistId);

    songs = artistSongs.map((e) {
      final s = e.toSong();
      s.isFavorite = fav.isFavorite(s.id);
      return s;
    }).toList();

    bool followed = auth.isAuthenticated
        ? await service.checkFollow(widget.artistId, auth.userId!)
        : false;

    setState(() {
      artist = data;
      isFollowing = followed;
      loading = false;
    });
  }

  void playRandom() async {
    if (songs.isEmpty) return;
    songs.shuffle();

    final s = songs.first;
    final player = context.read<PlayerProvider>();

    // 🟢 Tăng view nếu chưa phải bài đang phát
    if (player.currentSong?.id != s.id) {
      try {
        s.views = await _songService.increaseView(s.id);
        setState(() {});
      } catch (_) {}
    }

    player.playSong(song: s, playlist: songs, index: 0);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(song: s, playlist: songs, index: 0),
      ),
    );
  }


  void toggleFollow() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;

    final service = ArtistService();
    bool success = false;

    if (isFollowing) {
      success = await service.unfollow(widget.artistId, auth.userId!);
    } else {
      success = await service.follow(widget.artistId, auth.userId!);
    }

    if (success) {
      setState(() => isFollowing = !isFollowing);
      Navigator.pop(context, true); // 🔥 gửi kết quả về FavoriteScreen
    }
  }


  void playSong(int index) async {
    final player = context.read<PlayerProvider>();
    final s = songs[index];

    // 🟢 Nếu là bài mới thì tăng view
    if (player.currentSong?.id != s.id) {
      try {
        s.views = await _songService.increaseView(s.id);
        setState(() {}); // cập nhật UI
      } catch (_) {}
    }

    player.playSong(song: s, playlist: songs, index: index);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongDetailScreen(song: s, playlist: songs, index: index),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final fav = context.watch<FavoriteProvider>();
    const primary = Color(0xFF1E1E2C);

    if (loading) {
      return const Scaffold(
        backgroundColor: primary,
        body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
      );
    }

    return Scaffold(
      backgroundColor: primary,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 ẢNH TOP FULL + HEADER
          SizedBox(
          width: double.infinity,
          height: 380,
          child: Stack(
            children: [
              // Ảnh nền
              Positioned.fill(
                child: Image.network(
                  "${ApiConfig.serverUrl}${artist!["avatarUrl"]}",
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.45),
                  colorBlendMode: BlendMode.darken,
                ),
              ),

              // 🔙 Nút Back
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // ⭐ Tên nghệ sĩ — căn trái đáy ảnh
              Positioned(
                left: 20,
                bottom: 80, // đặt lên cao hơn để có chỗ cho nút
                child: Text(
                  artist!["name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 🎛️ Hàng nút — căn giữa nằm dưới tên
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ❤️ Nút Follow
                    ElevatedButton(
                      onPressed: toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.greenAccent,
                        side: const BorderSide(color: Colors.greenAccent),
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: Text(isFollowing ? "Đang quan tâm" : "Quan tâm", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold )),
                    ),
                    const SizedBox(width: 12),

                    // ▶️ Nút phát
                    ElevatedButton(
                      onPressed: playRandom,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("PHÁT", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

          const SizedBox(height: 25),

            // 📝 BIO — TÁCH RIÊNG
            if (artist!["bio"] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => setState(() => showFullBio = !showFullBio),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      artist!["bio"],
                      maxLines: showFullBio ? null : 4,
                      overflow: showFullBio ? TextOverflow.visible : TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 35),

            // 🎶 TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Bài hát nổi bật",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 10),

            // 🎵 DANH SÁCH BÀI HÁT
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: songs.length,
              itemBuilder: (_, i) {
                final s = songs[i];
                final isPlaying = player.currentSong?.id == s.id;

                return InkWell(
                  onTap: () => playSong(i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isPlaying
                          ? Colors.greenAccent.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "${ApiConfig.serverUrl}${s.coverUrl}",
                            width: 62,
                            height: 62,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                              Text(s.artist, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                              Row(
                                children: [
                                  const Icon(Icons.headphones, size: 16, color: Colors.white60),
                                  const SizedBox(width: 6),
                                  Text("${s.views} lượt nghe",
                                      style: const TextStyle(color: Colors.white60, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.play_circle_fill, color: Colors.greenAccent, size: 34),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
