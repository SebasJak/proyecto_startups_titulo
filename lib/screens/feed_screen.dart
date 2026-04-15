import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/firebase_provider.dart';
import '../widgets/video_post.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(apiProjectsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return const Center(
                child: Text("No hay startups aún", style: TextStyle(color: Colors.white)));
          }
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return VideoPost(project: project);
            },
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.deepPurpleAccent)),
        error: (err, stack) => Center(
            child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
