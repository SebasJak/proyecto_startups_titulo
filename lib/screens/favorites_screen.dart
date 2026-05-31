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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el Deck')),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(
    BuildContext context,
    String phoneNumber,
    String projectName,
  ) async {
    final url = Uri.parse(
      "whatsapp://send?phone=$phoneNumber&text=Hola, estoy interesado en avalar tu MVP: $projectName",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsyncValue = ref.watch(apiProjectsProvider);
    final favoriteIds = ref.watch(favoritesProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-friendly adaptive colors
    final scaffoldBgColor = isDark ? const Color(0xFF0F0E17) : theme.scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E1B2E) : theme.cardColor;
    final appBarTitleColor = theme.appBarTheme.titleTextStyle?.color ?? theme.textTheme.titleLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final titleColor = isDark ? Colors.white : (theme.textTheme.titleMedium?.color ?? Colors.black87);
    final descriptionColor = isDark ? Colors.white70 : (theme.textTheme.bodyMedium?.color ?? Colors.black54);
    final dividerColor = isDark ? Colors.white10 : theme.dividerColor;
    final outlinedBtnTextColor = isDark ? Colors.white : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          'Mis Favoritos',
          style: TextStyle(
            color: appBarTitleColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: projectsAsyncValue.when(
        data: (projects) {
          final favoriteProjects = projects
              .where((p) => favoriteIds.contains(p.id))
              .toList();

          if (favoriteProjects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border_rounded,
                        size: 80,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No tienes favoritos guardados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explora proyectos en el feed y guarda los que más te llamen la atención.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: descriptionColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteProjects.length,
            itemBuilder: (context, index) {
              final project = favoriteProjects[index];
              final initial = project.name.isNotEmpty
                  ? project.name[0].toUpperCase()
                  : '?';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.deepPurple.withOpacity(isDark ? 0.2 : 0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.name,
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  project.description,
                                  style: TextStyle(
                                    color: descriptionColor,
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.bookmark_remove_rounded,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              ref
                                  .read(favoritesProvider.notifier)
                                  .toggleFavorite(project.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Eliminado de favoritos'),
                                  duration: Duration(milliseconds: 700),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(color: dividerColor),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: outlinedBtnTextColor,
                                side: BorderSide(
                                  color: Colors.deepPurpleAccent.withOpacity(isDark ? 1.0 : 0.6),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.co_present, size: 18),
                              label: const Text(
                                'Ver Deck',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () =>
                                  _launchDeck(context, project.deckUrl),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 2,
                              ),
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                'Avalar',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _launchWhatsApp(
                                context,
                                project.ownerPhoneNumber,
                                project.name,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
