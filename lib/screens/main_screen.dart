import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feed_screen.dart';
import 'deck_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

// State provider to track the selected tab
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(selectedTabProvider);

    final screens = [
      const FeedScreen(),
      const DeckScreen(),
      const StatsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_carousel), // Deck icon
            label: 'Deck',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
