import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/player_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/chart_provider.dart';
import 'screens/auth_gate.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(
          create: (_) => ChartProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // ❌ bỏ const ở đây
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: const AuthGate(),
    );
  }
}
