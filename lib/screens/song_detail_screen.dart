import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../models/artist_song.dart';
import '../providers/player_provider.dart';
import '../widgets/player_seek_bar.dart';
import '../config/api_config.dart';
import 'artist_tab.dart';
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
  final PageController _pageController =
  PageController(initialPage: 1);

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

  String fullUrl(String path) =>
      "${ApiConfig.serverUrl}$path";

  void _playFromArtist(ArtistSong s) {
    final provider = context.read<PlayerProvider>();
    final idx =
    provider.playlist.indexWhere((e) => e.id == s.id);

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final song = provider.currentSong ?? widget.song;

    return Scaffold(
      extendBodyBehindAppBar: true, // 🔥 QUAN TRỌNG
      backgroundColor: Colors.black,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white, // chữ + icon trắng
        centerTitle: true,
        title: const Text(
          "Now Playing",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.55),
                Colors.black.withOpacity(0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),

      // ================= BODY =================
      body: PageView(
        controller: _pageController,
        children: [
          ArtistTab(
            song: song,
            currentSongId: song.id,
            onPlaySong: _playFromArtist,
          ),

          _buildPlayer(provider, song),

          LyricsTab(
            songId: song.id,
            playerService: provider.playerService,
          ),
        ],
      ),
    );
  }

  // ================= PLAYER TAB =================
  Widget _buildPlayer(PlayerProvider provider, Song song) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          fullUrl(song.coverUrl),
          fit: BoxFit.cover,
        ),

        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            color: Colors.black.withOpacity(0.45),
          ),
        ),

        Column(
          children: [
            const SizedBox(height: kToolbarHeight + 24),

            ClipOval(
              child: Image.network(
                fullUrl(song.coverUrl),
                width: 260,
                height: 260,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

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

            const SizedBox(height: 20),

            StreamBuilder<Duration>(
              stream:
              provider.playerService.player.positionStream,
              builder: (_, snapshot) {
                return PlayerSeekBar(
                  position: snapshot.data ?? Duration.zero,
                  duration:
                  provider.playerService.duration ??
                      Duration.zero,
                  onSeek: provider.playerService.seek,
                );
              },
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon:
                  const Icon(Icons.skip_previous, size: 40),
                  color: Colors.white,
                  onPressed: provider.prev,
                ),
                IconButton(
                  icon: Icon(
                    provider.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 70,
                  ),
                  color: Colors.white,
                  onPressed: provider.togglePlay,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40),
                  color: Colors.white,
                  onPressed: provider.next,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
