import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/playlist_service.dart';
import '../../models/playlist.dart';
import 'playlist_detail_screen.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  List<Playlist> playlists = [];
  bool loading = true;

  Future<void> loadData() async {
    final auth = context.read<AuthProvider>();
    playlists = await PlaylistService.getPlaylists(auth.userId!);
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // 📌 CREATE
  void _createPlaylist() {
    final auth = context.read<AuthProvider>();
    final c = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🎶 Playlist mới",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: c,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Tên playlist...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () async {
                if (c.text.trim().isEmpty) return;
                await PlaylistService.createPlaylist(auth.userId!, c.text.trim());
                Navigator.pop(context);
                loadData();
              },
              child: const Text("Tạo playlist"),
            )
          ],
        ),
      ),
    );
  }

  // ✏ RENAME
  void _renamePlaylist(Playlist playlist) {
    final c = TextEditingController(text: playlist.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text("✏️ Đổi tên Playlist", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: c,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
              hintText: "Tên mới", hintStyle: TextStyle(color: Colors.white54)),
        ),
        actions: [
          TextButton(
            child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: () async {
              final newName = c.text.trim();
              if (newName.isEmpty) return;
              final ok = await PlaylistService.renamePlaylist(playlist.id, newName);
              if (ok) {
                Navigator.pop(context);
                loadData();
              }
            },
            child: const Text("Lưu", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // ❌ DELETE
  Future<void> _deletePlaylist(int id, String name) async {
    await PlaylistService.deletePlaylist(id);
    loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🗑️ Đã xóa \"$name\"")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),

      // 🌿 AppBar xanh lá
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Thư viện",
            style: TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
            onPressed: _createPlaylist,
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : playlists.isEmpty
          ? const Center(
        child: Text(
          "📁 Chưa có playlist nào",
          style: TextStyle(color: Colors.white54, fontSize: 18),
        ),
      )

      // 📀 GRID spotify nhưng tone màu app bạn
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: playlists.length,
        itemBuilder: (_, i) {
          final p = playlists[i];

          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PlaylistDetailScreen(playlistId: p.id)),
              );
              loadData();
            },
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1E1E2C),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                builder: (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.white),
                      title: const Text("Đổi tên", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        _renamePlaylist(p);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline, color: Colors.red),
                      title: const Text("Xóa Playlist",
                          style: TextStyle(color: Colors.redAccent)),
                      onTap: () {
                        Navigator.pop(context);
                        _deletePlaylist(p.id, p.name);
                      },
                    ),
                  ],
                ),
              );
            },

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼 COVER
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: p.coverUrl == null
                      ? Container(
                    height: 130,
                    width: double.infinity,
                    color: Colors.white10,
                    child: const Icon(Icons.music_note,
                        color: Colors.white60, size: 40),
                  )
                      : Image.network(
                    "${ApiConfig.serverUrl}${p.coverUrl}",
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),

                // 🎵 NAME
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),

                Text("${p.totalSongs} bài hát",
                    style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          );
        },
      ),
    );
  }
}
