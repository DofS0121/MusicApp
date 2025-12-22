import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'auth_gate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  bool _uploading = false;

  /// ================= PICK & UPLOAD AVATAR =================
  Future<void> _changeAvatar() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;

    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);
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

        // 🔥 QUAN TRỌNG: đảm bảo AuthProvider notifyListeners
        await auth.saveLoginData(auth.token!, updatedUser);
      }
    } catch (e) {
      debugPrint("Upload avatar error: $e");
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  /// ================= LOGOUT =================
  void _logout() {
    context.read<AuthProvider>().logout();

    // 🔥 FIX LOGIC: quay về AuthGate (Login)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    /// 🔒 CHƯA ĐĂNG NHẬP → ĐI LOGIN
    if (!auth.isAuthenticated || user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E2C),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthGate()),
                    (route) => false,
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
        title: const Text("👤 Trang cá nhân"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ================= AVATAR =================
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: user["avatar"] != null
                      ? NetworkImage(user["avatar"])
                      : null,
                  child: user["avatar"] == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _uploading ? null : _changeAvatar,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blueAccent,
                      child: _uploading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ================= NAME =================
            Text(
              user["fullName"] ?? "",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            /// ================= EMAIL =================
            Text(
              user["email"] ?? "",
              style: const TextStyle(color: Colors.white60),
            ),

            const Spacer(),

            /// ================= LOGOUT =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Đăng xuất"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
