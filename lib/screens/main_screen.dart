import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feed_screen.dart';
import 'favorites_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'tags_screen.dart';

class SelectedTabNotifier extends Notifier<int> {
  @override
  int build() => 2; // Home is at index 2

  void changeTab(int index) {
    state = index;
  }
}

// State provider to track the selected tab
final selectedTabProvider = NotifierProvider<SelectedTabNotifier, int>(
  SelectedTabNotifier.new,
);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(selectedTabProvider);

    final screens = [
      const StatsScreen(),
      const TagsScreen(),
      const FeedScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(selectedTabProvider.notifier).changeTab(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            label: 'Tags',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
