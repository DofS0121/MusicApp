import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../models/artist_song.dart';
import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/player_seek_bar.dart';
import '../config/api_config.dart';
import 'song_info_tab.dart';
import 'lyrics_tab.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  final List<Song> playlist;
  final int index;

  const SongDetailScreen({
    super.key,
    required this.song,
    required this.playlist,
    required this.index,
  });

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().playSong(
        song: widget.song,
        playlist: widget.playlist,
        index: widget.index,
      );
    });
  }

  String get _title {
    switch (_currentPage) {
      case 0:
        return "INFORMATION";
      case 2:
        return "LYRICS";
      default:
        return "NOW PLAYING";
    }
  }

  String fullUrl(String path) => "${ApiConfig.serverUrl}$path";

  void _playFromArtist(ArtistSong s) {
    final provider = context.read<PlayerProvider>();
    final idx = provider.playlist.indexWhere((e) => e.id == s.id);

    if (idx != -1) {
      provider.playSong(
        song: provider.playlist[idx],
        playlist: provider.playlist,
        index: idx,
      );
    }

    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// ❤️ ADD FAVORITE – QUA FAVORITE PROVIDER
  Future<void> _addFavorite(int songId) async {
    final auth = context.read<AuthProvider>();
    final fav = context.read<FavoriteProvider>();

    if (!auth.isAuthenticated ||
        auth.userId == null ||
        auth.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng đăng nhập")),
      );
      return;
    }

    if (fav.isFavorite(songId)) return;

    try {
      await fav.addFavorite(
        userId: auth.userId!,
        songId: songId,
        token: auth.token!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❤️ Đã thêm vào yêu thích")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Lỗi khi thêm yêu thích")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong ?? widget.song;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,

      // ================= APP BAR =================
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.55),
        elevation: 0,
        title: Text(
          _title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.3,
          ),
        ),
      ),

      // ================= BODY =================
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: [
          SongInfoTab(
            songId: song.id,
            artistId: song.artistId,
            currentSongId: song.id,
            onPlaySong: _playFromArtist,
          ),

          _buildPlayer(context, song),

          LyricsTab(
            songId: song.id,
            coverUrl: song.coverUrl,
            playerService: player.playerService,
          ),
        ],
      ),
    );
  }

  // ================= PLAYER TAB =================
  Widget _buildPlayer(BuildContext context, Song song) {
    final fav = context.watch<FavoriteProvider>();
    final isFav = fav.isFavorite(song.id);
    final player = context.watch<PlayerProvider>();

    return Stack(
      children: [
        Image.network(
          fullUrl(song.coverUrl),
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xAA000000), Color(0x33000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        Column(
          children: [
            const SizedBox(height: kToolbarHeight + 40),

            ClipOval(
              child: Image.network(
                fullUrl(song.coverUrl),
                width: 260,
                height: 260,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              song.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              song.artist,
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 10),

            /// ❤️ FAVORITE BUTTON
            Consumer<FavoriteProvider>(
              builder: (_, fav, __) {
                final isFav = fav.isFavorite(song.id);

                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: isFav ? Colors.redAccent : Colors.white70,
                  iconSize: 30,
                  onPressed: () async {
                    final auth = context.read<AuthProvider>();
                    if (!auth.isAuthenticated) return;

                    if (isFav) {
                      await fav.removeFavorite(
                        userId: auth.userId!,
                        songId: song.id,
                        token: auth.token!,
                      );
                    } else {
                      await fav.addFavorite(
                        userId: auth.userId!,
                        songId: song.id,
                        token: auth.token!,
                      );
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            StreamBuilder<Duration>(
              stream: player.playerService.player.positionStream,
              builder: (_, snap) => PlayerSeekBar(
                position: snap.data ?? Duration.zero,
                duration:
                player.playerService.duration ?? Duration.zero,
                onSeek: player.playerService.seek,
              ),
            ),

            const SizedBox(height: 26),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 38),
                  color: Colors.white,
                  onPressed: player.prev,
                ),
                IconButton(
                  icon: Icon(
                    player.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 72,
                  ),
                  color: Colors.deepPurpleAccent,
                  onPressed: player.togglePlay,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 38),
                  color: Colors.white,
                  onPressed: player.next,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
