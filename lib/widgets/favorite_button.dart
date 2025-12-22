import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/user_favorite.dart';
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
      icon: const Icon(Icons.favorite_border, color: Colors.redAccent),
      onPressed: () async {
        final auth = context.read<AuthProvider>();

        // ❌ Chưa đăng nhập
        if (!auth.isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng đăng nhập")),
          );
          return;
        }

        try {
          await FavoriteService.addFavorite(
            UserFavorite(
              userId: auth.userId!, // ✅ user thật
              songId: songId,
            ),
            auth.token!, // ✅ FIX TOKEN
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❤️ Đã thêm vào yêu thích")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Lỗi khi thêm yêu thích")),
          );
        }
      },
    );
  }
}
