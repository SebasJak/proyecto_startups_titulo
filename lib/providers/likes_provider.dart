import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikesNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'liked_startup_ids';

  @override
  Set<String> build() {
    _loadLikes();
    return {};
  }

  Future<void> _loadLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedIds = prefs.getStringList(_prefsKey);
    if (savedIds != null) {
      state = savedIds.toSet();
    }
  }

  Future<void> addLike(String id) async {
    if (state.contains(id)) return;
    final prefs = await SharedPreferences.getInstance();
    state = {...state}..add(id);
    await prefs.setStringList(_prefsKey, state.toList());
  }

  Future<void> removeLike(String id) async {
    if (!state.contains(id)) return;
    final prefs = await SharedPreferences.getInstance();
    state = {...state}..remove(id);
    await prefs.setStringList(_prefsKey, state.toList());
  }
}

final likesProvider = NotifierProvider<LikesNotifier, Set<String>>(() {
  return LikesNotifier();
});
