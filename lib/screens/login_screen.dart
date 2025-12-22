import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import 'song_list_screen.dart';
import 'register_screen.dart';
import 'main_screen.dart'; // ✅ IMPORT MAIN SCREEN

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    try {
      setState(() => loading = true);

      final res = await AuthService().login(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      if (res == null ||
          res["token"] == null ||
          res["user"] == null) {
        throw Exception("Login failed");
      }

      final token = res["token"] as String;
      final user = res["user"] as Map<String, dynamic>;

      await context.read<AuthProvider>().saveLoginData(
        token,
        user,
        context.read<FavoriteProvider>(),
      );
    } catch (_) {
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
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(title: const Text("LOGIN")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            TextField(
              controller: emailCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _input("Email"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _input("Password"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                  "LOGIN",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text(
                "Create new account",
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
