import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import 'new_password_screen.dart';

class VerifyCurrentPasswordScreen extends StatefulWidget {
  const VerifyCurrentPasswordScreen({super.key});

  @override
  State<VerifyCurrentPasswordScreen> createState() => _VerifyCurrentPasswordScreenState();
}

class _VerifyCurrentPasswordScreenState extends State<VerifyCurrentPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        title: const Text("Xác nhận mật khẩu",
            style: TextStyle(color: Colors.greenAccent)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _passwordCtrl,
              obscureText: _hide,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Nhập mật khẩu hiện tại",
                hintStyle: const TextStyle(color: Colors.white38),
                suffixIcon: IconButton(
                  icon: Icon(_hide ? Icons.visibility_off : Icons.visibility,
                      color: Colors.greenAccent),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),
            ),
            const SizedBox(height: 30),

            _loading
                ? const CircularProgressIndicator(color: Colors.greenAccent)
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  setState(() => _loading = true);

                  final res = await _authService.verifyCurrentPassword(
                    auth.userId!, _passwordCtrl.text,
                  );

                  setState(() => _loading = false);

                  if (res != null && res["success"] == true) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewPasswordScreen(
                          userId: auth.userId!,   // 👈 truyền vào
                          fromForget: false,      // 👈 đang đổi mật khẩu khi login
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("❌ Mật khẩu sai!")),
                    );
                  }
                },
                child: const Text("Tiếp tục"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
