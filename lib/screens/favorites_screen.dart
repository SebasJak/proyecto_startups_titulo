import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/firebase_provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  Future<void> _launchDeck(BuildContext context, String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el Deck')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsyncValue = ref.watch(apiProjectsProvider);
    final favoriteIds = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Favoritos')),
      body: projectsAsyncValue.when(
        data: (projects) {
          final favoriteProjects = projects.where((p) => favoriteIds.contains(p.id)).toList();

          if (favoriteProjects.isEmpty) {
            return const Center(
              child: Text('Tus proyectos guardados aparecerán aquí.', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            itemCount: favoriteProjects.length,
            itemBuilder: (context, index) {
              final project = favoriteProjects[index];
              final initial = project.name.isNotEmpty ? project.name[0].toUpperCase() : '?';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(project.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  project.description,
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                onTap: () => _launchDeck(context, project.deckUrl),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
