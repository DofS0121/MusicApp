import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../services/playlist_service.dart';
import '../models/playlist.dart';
import '../widgets/player_seek_bar.dart';
import '../config/api_config.dart';
import '../screens/song_info_tab.dart';
import '../screens/lyrics_tab.dart';

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



class _SongDetailScreenState extends State<SongDetailScreen>
    with SingleTickerProviderStateMixin {
  final PageController _page = PageController(initialPage: 1);
  int _tab = 1;

  String get _title {
    switch (_tab) {
      case 0:
        return "INFORMATION";
      case 2:
        return "LYRICS";
      default:
        return "NOW PLAYING";
    }
  }

  // 📀 Animation xoay đĩa
  late AnimationController _diskCtrl;

  @override
  void initState() {
    super.initState();

    final player = context.read<PlayerProvider>();
    player.playSong(
      song: widget.song,
      playlist: widget.playlist,
      index: widget.index,
    );

    _diskCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(); // quay chậm

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!player.isPlaying) _diskCtrl.stop();
    });
  }

  @override
  void dispose() {
    _diskCtrl.dispose();
    super.dispose();
  }

  String fullUrl(String path) =>
      path.startsWith("http") ? path : "${ApiConfig.serverUrl}$path";

  // ======================= ADD TO PLAYLIST =======================
  Future<void> _addToPlaylistDialog(Song song) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng đăng nhập")),
      );
      return;
    }

    final playlists = await PlaylistService.getPlaylists(auth.userId!);
    TextEditingController newName = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141422),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => StatefulBuilder(builder: (context, setSheet) {
        return SizedBox(
          height: 450,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                  width: 40, height: 4, decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 14),

              const Text("Thêm vào playlist",
                  style: TextStyle(color: Colors.white, fontSize: 18)),

              const Divider(color: Colors.white10),

              Expanded(
                child: ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (_, i) {
                    final p = playlists[i];
                    return ListTile(
                      title: Text(p.name, style: const TextStyle(color: Colors.white)),
                      leading: p.coverUrl == null
                          ? const Icon(Icons.playlist_play, color: Colors.white70)
                          : CircleAvatar(
                          backgroundImage: NetworkImage(fullUrl(p.coverUrl!))),
                      onTap: () async {
                        final inside = await PlaylistService.getPlaylistDetail(p.id);
                        final ids = (inside?["songs"] as List)
                            .map((e) => (e is Song ? e.id : e["id"] as int))
                            .toList();

                        if (ids.contains(song.id)) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("⚠️ \"${song.title}\" đã có trong playlist")),
                          );
                          return;
                        }

                        await PlaylistService.addSong(p.id, song.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("🎉 Đã thêm vào ${p.name}")));
                      },
                    );
                  },
                ),
              ),

              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.greenAccent),
                title: const Text("Tạo playlist mới",
                    style: TextStyle(color: Colors.greenAccent)),
                onTap: () async {
                  Navigator.pop(context);
                  _createPlaylistAndAdd(song);
                },
              )
            ],
          ),
        );
      }),
    );
  }

  // ➕ tạo mới & thêm bài
  Future<void> _createPlaylistAndAdd(Song song) async {
    final auth = context.read<AuthProvider>();
    final c = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text("🎶 Playlist mới", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: c,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Tên playlist"),
        ),
        actions: [
          TextButton(child: const Text("Hủy"), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (c.text.trim().isEmpty) return;
              await PlaylistService.createPlaylist(auth.userId!, c.text);
              final list = await PlaylistService.getPlaylists(auth.userId!);
              final created = list.last;
              await PlaylistService.addSong(created.id, song.id);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("🎉 Đã tạo & thêm vào ${created.name}!")));
            },
            child: const Text("Tạo & Thêm"),
          )
        ],
      ),
    );
  }

  // ======================= BUILD UI =======================
  // ======================= BUILD UI =======================
  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final fav = context.watch<FavoriteProvider>();
    final song = player.currentSong ?? widget.song;
    final isFav = fav.isFavorite(song.id);



    // 📀 Dừng/quay theo trạng thái phát
    player.isPlaying ? _diskCtrl.repeat() : _diskCtrl.stop();


    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,

      // ======================= APP BAR =======================
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        centerTitle: true,
        title: Text(
          _title, // 👉 dùng getter bạn gửi
          style: const TextStyle(
            color: Colors.greenAccent,
            letterSpacing: 1.3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Stack(
        children: [
          // 🌫️ Background mờ + cover
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Image.network(
                fullUrl(song.coverUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.55)),

          // ======================= PAGE VIEW =======================
          PageView(
            controller: _page,
            onPageChanged: (i) {
              setState(() => _tab = i);
            },
            children: [
              // 👉 TAB 0: SONG INFO
              SongInfoTab(
                songId: song.id,
                artistId: song.artistId,
                currentSongId: song.id,
                onPlaySong: (_) {},
              ),

              // 🎵 TAB 1: PLAYER CHÍNH
              _playerBody(song, player, fav, isFav),

              // 👉 TAB 2: LYRICS
              LyricsTab(
                songId: song.id,
                coverUrl: song.coverUrl,
                playerService: player.playerService,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======================= MAIN PLAYER BODY =======================
  Widget _playerBody(Song song, PlayerProvider player,
      FavoriteProvider fav, bool isFav) {
    return Column(
      children: [
        const SizedBox(height: 120),

        // 🎵 Cover xoay
        RotationTransition(
          turns: _diskCtrl,
          child: ClipOval(
            child: Image.network(
              fullUrl(song.coverUrl),
              width: 260,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 28),

        Text(song.title,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(song.artist, style: const TextStyle(color: Colors.white70)),

        const SizedBox(height: 14),

        // ❤️ + ➕ playlist
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
              iconSize: 28,
              color: isFav ? Colors.redAccent : Colors.white70,
              onPressed: () {
                final auth = context.read<AuthProvider>();

                if (!auth.isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠️ Vui lòng đăng nhập")),
                  );
                  return;
                }

                fav.toggleFavorite(
                  userId: auth.userId!,
                  song: song,
                  token: auth.token!,
                );
              },
            ),
            const SizedBox(width: 14),
            IconButton(
              icon: const Icon(Icons.playlist_add),
              color: Colors.greenAccent,
              iconSize: 28,
              onPressed: () => _addToPlaylistDialog(song),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 🎚 Thanh seek
        StreamBuilder<Duration>(
          stream: player.playerService.player.positionStream,
          builder: (_, snap) => PlayerSeekBar(
            position: snap.data ?? Duration.zero,
            duration: player.playerService.duration ?? Duration.zero,
            onSeek: player.playerService.seek,
          ),
        ),

        const SizedBox(height: 8),

        // 🔀 🔁 SHUFFLE / PREV / PLAY / NEXT / LOOP
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shuffle,
                  color: player.isShuffle ? Colors.greenAccent : Colors.white54),
              onPressed: player.toggleShuffle,
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              iconSize: 38,
              color: Colors.white,
              onPressed: player.prev,
            ),
            IconButton(
              icon: Icon(
                player.isPlaying ? Icons.pause_circle : Icons.play_circle_fill,
                size: 74,
                color: Colors.greenAccent,
              ),
              onPressed: player.togglePlay,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              iconSize: 38,
              color: Colors.white,
              onPressed: player.next,
            ),
            IconButton(
              icon: Icon(
                player.loopMode == 2
                    ? Icons.repeat_one
                    : Icons.repeat,
                color: player.loopMode > 0 ? Colors.greenAccent : Colors.white54,
              ),
              onPressed: player.toggleLoopMode,
            ),
          ],
        )
      ],
    );
  }
}
