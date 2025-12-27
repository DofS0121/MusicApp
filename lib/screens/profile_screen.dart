import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../services/auth_service.dart';
import 'auth_gate.dart';
import '../providers/player_provider.dart';
import '../config/api_config.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/playlist_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  // 🔗 Ghép URL avatar nếu chỉ lưu fileName
  String _avatarUrl(dynamic avatar) {
    if (avatar == null) return "";
    if (avatar.toString().startsWith("http")) return avatar;
    return "${ApiConfig.serverUrl}/uploads/avatars/$avatar";
  }

  /// 📸 PICK & UPLOAD AVATAR
  Future<void> _changeAvatar() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _uploading = true);

    try {
      final avatarUrl = await _authService.uploadAvatar(
        auth.userId!,
        auth.token!,
        File(image.path),
      );

      if (avatarUrl != null) {
        final updatedUser = Map<String, dynamic>.from(auth.user!);
        updatedUser["avatar"] = avatarUrl;

        await auth.saveLoginData(
          auth.token!,
          updatedUser,
          context.read<FavoriteProvider>(),
        );
      }
    } catch (e) {
      debugPrint("Upload avatar error: $e");
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  /// 🚪 LOGOUT
  void _logout(BuildContext context) {
    context.read<AuthProvider>().logout(
      context.read<FavoriteProvider>(),
      context.read<PlayerProvider>(),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fav = context.watch<FavoriteProvider>();
    final user = auth.user;

    /// 🔒 Chưa login → chuyển login
    if (!auth.isAuthenticated || user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E2C),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthGate()),
              );
            },
            child: const Text("Đăng nhập"),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("👤 Trang cá nhân",
            style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🔥 AVATAR
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(_avatarUrl(user["avatar"])),
                  onBackgroundImageError: (_, __) => {},
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: /// 🔥 AVATAR (Ấn => chuyển trang chỉnh sửa)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white10,
                          backgroundImage: (user["avatar"] != null && user["avatar"] != "")
                              ? NetworkImage(_avatarUrl(user["avatar"]))
                              : null,
                          child: user["avatar"] == null || user["avatar"] == ""
                              ? const Icon(Icons.person, size: 50, color: Colors.white60)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.greenAccent,
                            child: const Icon(Icons.edit, size: 18, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 📌 NAME + EMAIL
            Text(user["fullName"] ?? "",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(user["email"] ?? "",
                style: const TextStyle(color: Colors.white60)),

            const SizedBox(height: 15),

            /// ❤️ Tổng bài hát yêu thích
            // 🔥 PHẦN HIỂN THỊ TỔNG BÀI HÁT YÊU THÍCH
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text(
                    "Bài hát yêu thích: ${fav.ids.length}",  // ⬅️ sửa ở đây
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 🔧 CÁC CHỨC NĂNG THÊM (gợi ý / mở rộng sau này)
            _profileOption(Icons.history, "Lịch sử nghe nhạc",
                onTap: () => debugPrint("👉 TODO: History")),
            _profileOption(Icons.settings, "Cài đặt tài khoản",
                onTap: () => debugPrint("👉 TODO: Settings")),
            _profileOption(Icons.security, "Đổi mật khẩu",
                onTap: () => debugPrint("👉 TODO: Change Password")),

            _profileOption(
              Icons.library_music,
              "Playlist của tôi",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlaylistScreen()),
                );
              },
            ),


            const Spacer(),

            /// 🚪 Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Đăng xuất"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 Widget shortcut
  Widget _profileOption(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      iconColor: Colors.greenAccent,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }
}
