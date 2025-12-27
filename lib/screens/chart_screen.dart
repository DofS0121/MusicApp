import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chart_provider.dart';
import '../providers/player_provider.dart';
import '../providers/favorite_provider.dart';
import '../models/chart_song.dart';
import '../models/song.dart';
import '../screens/song_detail_screen.dart';
import '../widgets/mini_player.dart';
import '../config/api_config.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late PageController _pageController;
  int startIndex = 300; // ⭐ tăng để loop tự nhiên
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() => context.read<ChartProvider>().loadChart('realtime'));

    _pageController = PageController(
      viewportFraction: 0.64, // ⭐ vừa cho chiều ngang
      initialPage: startIndex,
    );

    // ⭐ Auto slide
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String fullUrl(String path) =>
      path.startsWith("http") ? path : "${ApiConfig.serverUrl}$path";

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("#Songchart",
            style: TextStyle(
                color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 10), // ⭐ thêm khoảng cách
          _buildTabs(provider),
          const SizedBox(height: 10),
          _buildTop3(provider.songs),
          const SizedBox(height: 14),
          Expanded(child: _buildList(provider.songs)),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  // ==================== TABS ====================
  Widget _buildTabs(ChartProvider provider) {
    Widget tab(String label, String type) {
      final active = provider.type == type;
      return GestureDetector(
        onTap: () => provider.loadChart(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        tab("Realtime", "realtime"),
        const SizedBox(width: 10),
        tab("Daily", "daily"),
        const SizedBox(width: 10),
        tab("Weekly", "weekly"),
      ],
    );
  }

  // ==================== SLIDER TOP 3 ====================
  Widget _buildTop3(List<ChartSong> charts) {
    if (charts.length < 3) return const SizedBox();
    final top3 = charts.take(3).toList();
    final fav = context.read<FavoriteProvider>();
    final player = context.read<PlayerProvider>();

    const double height = 135;
    final double width = MediaQuery.of(context).size.width * 0.90;

    Color rankColor(int r) {
      switch (r) {
        case 1:
          return Colors.yellow.shade600;
        case 2:
          return Colors.grey.shade300;
        case 3:
          return Colors.brown.shade300;
        default:
          return Colors.white24;
      }
    }

    return SizedBox(
      height: height + 150,
      child: PageView.builder(
        controller: _pageController,
        padEnds: true,
        onPageChanged: (page) => setState(() => _currentPage = page % top3.length),
        itemBuilder: (_, index) {
          final i = index % 3;
          final c = top3[i];
          final isActive = (_currentPage == i);

          final fav = context.read<FavoriteProvider>();
          final song = Song(
            id: c.songId,
            title: c.title,
            artist: c.artist,
            coverUrl: c.coverUrl,
            audioUrl: c.audioUrl ?? "",
            duration: c.duration,
            views: c.viewCount,
            artistId: c.artistId,
            isFavorite: fav.isFavorite(c.songId),
          );

          return AnimatedScale(
            scale: isActive ? 1.03 : 0.92,
            duration: const Duration(milliseconds: 240),
            child: GestureDetector(
                onTap: () {
                  // playlist gốc từ charts (top 1 → hết danh sách)
                  final provider = context.read<ChartProvider>();
                  final fullPlaylist = provider.songs.map((c) => Song(
                    id: c.songId,
                    title: c.title,
                    artist: c.artist,
                    coverUrl: c.coverUrl,
                    audioUrl: c.audioUrl ?? "",
                    duration: c.duration,
                    views: c.viewCount,
                    artistId: c.artistId,
                    isFavorite: fav.isFavorite(c.songId),
                  )).toList();

                  // Lấy index thực của bài trong playlist
                  final realIndex = fullPlaylist.indexWhere((s) => s.id == song.id);

                  player.playSong(song: song, playlist: fullPlaylist, index: realIndex);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SongDetailScreen(
                        song: song,
                        playlist: fullPlaylist,
                        index: realIndex,
                      ),
                    ),
                  );
                },
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      width: isActive ? 4 : 2,
                      color: rankColor(c.rank),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(fullUrl(c.coverUrl)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (c.rank == 1)
                              const Icon(Icons.emoji_events,
                                  color: Colors.yellow, size: 18),
                            Text(" #${c.rank}",
                                style: TextStyle(
                                  color: rankColor(c.rank),
                                  fontWeight: FontWeight.bold,
                                  fontSize: isActive ? 20 : 17,
                                )),
                          ],
                        ),
                        Text(c.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        Text(c.artist,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== LIST RANKING (NEW UI STYLE) ====================
  Widget _buildList(List<ChartSong> charts) {
    final player = context.read<PlayerProvider>();
    final fav = context.watch<FavoriteProvider>();

    // Chuẩn hóa playlist từ charts
    final playlist = charts.map((c) => Song(
      id: c.songId,
      title: c.title,
      artist: c.artist,
      coverUrl: c.coverUrl,
      audioUrl: c.audioUrl ?? "",
      duration: c.duration,
      views: c.viewCount,
      artistId: c.artistId,
      isFavorite: fav.isFavorite(c.songId),
    )).toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
      itemCount: playlist.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = playlist[i];
        final c = charts[i];

        // Xử lý icon lên / xuống / giữ nguyên
        int? diff = (c.prevRank != null) ? c.prevRank! - c.rank : null;

        Icon arrow = const Icon(Icons.remove, color: Colors.white24, size: 16);
        if (diff != null && diff > 0) {
          arrow = const Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 16);
        } else if (diff != null && diff < 0) {
          arrow = const Icon(Icons.arrow_downward, color: Colors.redAccent, size: 16);
        }

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            player.playSong(song: s, playlist: playlist, index: i);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SongDetailScreen(song: s, playlist: playlist, index: i),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.06),
            ),
            child: Row(
              children: [
                // 🎖 Rank Number
                Text(
                  "${c.rank}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 14),

                // 🎵 Cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    fullUrl(s.coverUrl),
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),

                // 📌 Info
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
                        style: const TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // 📈 Rank Movement
                Row(
                  children: [
                    arrow,
                    if (diff != null && diff != 0)
                      Text(
                        diff.abs().toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: diff > 0 ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
