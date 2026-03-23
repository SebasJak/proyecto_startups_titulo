import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mock_data_provider.dart';
import '../widgets/video_post.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(mockProjectsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return VideoPost(project: project);
        },
      ),
    );
  }
}
