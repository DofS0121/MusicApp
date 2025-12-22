import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/favorite_service.dart';

class FavoriteButton extends StatelessWidget {
  final int songId;

  const FavoriteButton({
    super.key,
    required this.songId,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.favorite_border,
        color: Colors.redAccent,
      ),
      onPressed: () async {
        print("❤️ CLICK FAVORITE – songId=$songId");

        final auth = context.read<AuthProvider>();

        print("👤 isAuthenticated = ${auth.isAuthenticated}");
        print("👤 userId = ${auth.userId}");
        print("🔐 token = ${auth.token != null ? auth.token!.substring(0, 15) : "NULL"}");

        if (!auth.isAuthenticated ||
            auth.userId == null ||
            auth.token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng đăng nhập")),
          );
          return;
        }

        try {
          await FavoriteService.addFavorite(
            userId: auth.userId!,
            songId: songId,
            token: auth.token!,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❤️ Đã thêm vào yêu thích")),
          );
        } catch (e) {
          print("❌ ADD FAVORITE ERROR: $e");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Lỗi khi thêm yêu thích")),
          );
        }
      },
    );
  }
}
