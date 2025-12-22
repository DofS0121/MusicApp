import 'package:flutter/material.dart';

import 'song_list_screen.dart';
import 'favorite_songs_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      SongListScreen(),        // 🏠 Trang chủ
      FavoriteSongsScreen(),   // ❤️ Yêu thích
      Placeholder(),           // 📊 BXH
      ProfileScreen(),         // 👤 Cá nhân
    ];
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E2C),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Yêu thích",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "BXH",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Cá nhân",
          ),
        ],
      ),
    );
  }
}
