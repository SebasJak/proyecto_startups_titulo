import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'favorite_startup_ids';

  @override
  Set<String> build() {
    _loadFavorites();
    return {};
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedIds = prefs.getStringList(_prefsKey);
    if (savedIds != null) {
      state = savedIds.toSet();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state}..add(id);
    }
    await prefs.setStringList(_prefsKey, state.toList());
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(() {
  return FavoritesNotifier();
});
