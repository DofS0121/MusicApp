import 'package:flutter/material.dart';

import 'song_list_screen.dart';
import 'favorite_screen.dart';
import 'user/profile_screen.dart';
import 'chart_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 🔑 KEY để ép rebuild Trang chủ
  Key _homeKey = UniqueKey();

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _buildScreens();
  }

  void _buildScreens() {
    _screens = [
      SongListScreen(key: _homeKey), // 🏠 Trang chủ
      const FavoriteScreen(),   // ❤️ Yêu thích
      const ChartScreen(),           // 📊 BXH
      const ProfileScreen(),         // 👤 Cá nhân
    ];
  }

  void _onTabChanged(int index) {
    // 👉 Nếu đang ở Trang chủ và bấm lại Trang chủ
    if (_currentIndex == index && index == 0) {
      setState(() {
        _homeKey = UniqueKey(); // 🔥 ép rebuild
        _buildScreens();
      });
      return;
    }

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
