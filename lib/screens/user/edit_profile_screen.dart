import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../providers/favorite_provider.dart';
import '../../config/api_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _authService = AuthService();
  final _picker = ImagePicker();

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();

  File? selectedAvatar;
  bool saving = false;

  String avatarUrl(dynamic avatar) {
    if (avatar == null) return "";
    if (avatar.toString().startsWith("http")) return avatar;
    return "${ApiConfig.serverUrl}/uploads/avatars/$avatar";
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    nameCtrl.text = user?["fullName"] ?? "";
    emailCtrl.text = user?["email"] ?? "";
  }

  /// 📸 chọn ảnh từ thư viện
  Future pickAvatar() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => selectedAvatar = File(img.path));
  }

  /// 💾 Lưu thông tin
  Future save() async {
    final auth = context.read<AuthProvider>();
    final fav = context.read<FavoriteProvider>();

    if (!auth.isAuthenticated) return;

    setState(() => saving = true);

    try {
      // 1️⃣ cập nhật info cơ bản
      final updated = await _authService.updateProfile(
        userId: auth.userId!,
        fullName: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        token: auth.token!,
      );

      if (updated != null) {
        Map<String, dynamic> newUser = Map.from(auth.user!);
        newUser["fullName"] = nameCtrl.text.trim();
        newUser["email"] = emailCtrl.text.trim();

        // 2️⃣ upload avatar nếu có
        if (selectedAvatar != null) {
          final avatar = await _authService.uploadAvatar(
            auth.userId!,
            auth.token!,
            selectedAvatar!,
          );
          if (avatar != null) newUser["avatar"] = avatar;
        }

        // 3️⃣ lưu vào AuthProvider
        await auth.saveLoginData(auth.token!, newUser, fav);
      }

      if (mounted) Navigator.pop(context);

    } catch (e) {
      debugPrint("❌ SAVE ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Có lỗi xảy ra!")),
      );
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("✏️ Chỉnh sửa hồ sơ",
            style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🔥 Avatar Preview
            GestureDetector(
              onTap: pickAvatar,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: selectedAvatar != null
                        ? FileImage(selectedAvatar!) as ImageProvider
                        : NetworkImage(avatarUrl(user?["avatar"])),
                  ),
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 30, color: Colors.white),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 👤 Full Name
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Họ và tên"),
            ),
            const SizedBox(height: 15),

            /// 📧 Email
            TextField(
              controller: emailCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Email"),
            ),
            const SizedBox(height: 30),

            /// 💾 Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text("Lưu thay đổi",
                    style: TextStyle(
                        color: Colors.black, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white38),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
