import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/providers/auth_provider.dart';
import 'package:music_player_app/services/auth_service.dart';
import 'package:music_player_app/providers/player_provider.dart';
import 'package:music_player_app/providers/favorite_provider.dart';
import '../user/auth_gate.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String newPassword;
  const OtpVerifyScreen({super.key, required this.newPassword});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final _authService = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("Xác minh OTP", style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Nhập OTP 6 số",
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 30),

            loading
                ? const CircularProgressIndicator(color: Colors.greenAccent)
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                setState(() => loading = true);

                final ok = await _authService.verifyOtp(auth.userId!, _otpCtrl.text);

                if (!ok) {
                  setState(() => loading = false);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("❌ OTP sai hoặc hết hạn!")));
                  return;
                }

                final done = await _authService.changePassword(
                    auth.userId!, widget.newPassword);

                if (done) {
                  // 🔥 Logout
                  auth.logout(
                    context.read<FavoriteProvider>(),
                    context.read<PlayerProvider>(),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                        (_) => false,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🎉 Đổi mật khẩu thành công!")));
                }

                setState(() => loading = false);
              },
              child: const Text("Xác nhận"),
            ),
          ],
        ),
      ),
    );
  }
}
