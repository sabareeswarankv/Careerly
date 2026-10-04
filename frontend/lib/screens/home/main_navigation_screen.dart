import 'package:flutter/material.dart';
import '../../widgets/responsive_scaffold.dart';
import 'home_screen.dart';
import '../explore/explore_screen.dart';
import '../progress/progress_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onIndexChanged(int index) {
    setState(() => _currentIndex = index);
  }

  String? _getTitle(int index) {
    switch (index) {
      case 0:
        return null;
      case 1:
        return 'Explore Pathways';
      case 2:
        return 'Progress';
      case 3:
        return 'Student Profile';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateTab: _onIndexChanged),
      const ExploreScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return ResponsiveScaffold(
      currentIndex: _currentIndex,
      onIndexChanged: _onIndexChanged,
      title: _getTitle(_currentIndex),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
    );
  }
}
