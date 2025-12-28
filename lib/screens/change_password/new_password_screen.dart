import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/providers/auth_provider.dart';
import 'package:music_player_app/services/auth_service.dart';
import 'otp_verify_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  final int userId;
  final bool fromForget; // 🆕 true khi đi từ quên mật khẩu
  const NewPasswordScreen({super.key, required this.userId, this.fromForget = false});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool hide1 = true, hide2 = true;

  bool get hasUpper => _passCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get hasNumber => _passCtrl.text.contains(RegExp(r'[0-9]'));
  bool get hasLength => _passCtrl.text.length >= 8;
  bool get match => _passCtrl.text == _confirmCtrl.text;

  bool get valid => hasUpper && hasNumber && hasLength && match;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    Widget rule(String text, bool ok) => Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.circle,
            size: 16, color: ok ? Colors.greenAccent : Colors.white38),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(
          color: ok ? Colors.greenAccent : Colors.white54,
        )),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        title: const Text("Tạo mật khẩu mới",
            style: TextStyle(color: Colors.greenAccent)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            TextField(
              controller: _passCtrl,
              obscureText: hide1,
              onChanged: (_) => setState((){}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Mật khẩu mới",
                hintStyle: const TextStyle(color: Colors.white38),
                suffixIcon: IconButton(
                  icon: Icon(hide1 ? Icons.visibility_off : Icons.visibility,
                      color: Colors.greenAccent),
                  onPressed: () => setState(() => hide1 = !hide1),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _confirmCtrl,
              obscureText: hide2,
              onChanged: (_) => setState((){}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Xác nhận mật khẩu",
                hintStyle: const TextStyle(color: Colors.white38),
                suffixIcon: IconButton(
                  icon: Icon(hide2 ? Icons.visibility_off : Icons.visibility,
                      color: Colors.greenAccent),
                  onPressed: () => setState(() => hide2 = !hide2),
                ),
              ),
            ),

            const SizedBox(height: 25),
            rule("Ít nhất 1 chữ in hoa (A-Z)", hasUpper),
            rule("Ít nhất 1 số (0-9)", hasNumber),
            rule("Đủ tối thiểu 8 ký tự", hasLength),
            rule("Khớp với xác nhận mật khẩu", match),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: valid ? Colors.greenAccent : Colors.white12,
                  foregroundColor: valid ? Colors.black : Colors.white38,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: valid
                    ? () async {
                  final sent = await AuthService().sendOtp(auth.userId!);

                  if(!sent){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("❌ Gửi OTP thất bại, thử lại sau!")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtpVerifyScreen(newPassword: _passCtrl.text),
                    ),
                  );
                }
                    : null,
                child: const Text("Gửi OTP xác minh"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
