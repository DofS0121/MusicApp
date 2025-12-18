import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import 'song_list_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final authService = AuthService();
  bool loading = false;

  Future<void> login() async {
    try {
      setState(() => loading = true);

      print("🟡 [UI] Start login");

      final res = await authService.login(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      print("🟡 [UI] Login response = $res");

      if (res == null) {
        throw Exception("Login failed");
      }

      final token = res["token"];
      final user = res["user"];

      print("🟢 [UI] Token = $token");
      print("🟢 [UI] User = $user");

      await Provider.of<AuthProvider>(context, listen: false)
          .saveLoginData(token, user);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SongListScreen()),
      );
    } catch (e) {
      print("🔴 [UI LOGIN ERROR] $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email hoặc mật khẩu không đúng")),
      );
    } finally {
      setState(() => loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : login,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text("Create new account"),
            ),
          ],
        ),
      ),
    );
  }
}
