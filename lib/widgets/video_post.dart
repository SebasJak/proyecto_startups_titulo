import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/startup_project.dart';
import 'interaction_belt.dart';

class VideoPost extends StatefulWidget {
  final StartupProject project;

  const VideoPost({super.key, required this.project});

  @override
  State<VideoPost> createState() => _VideoPostState();
}

class _VideoPostState extends State<VideoPost> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.project.videoUrl))
      ..initialize().then((_) {
        setState(() {}); // Ensure the first frame is shown after the video is initialized
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Video Player
        Positioned.fill(
          child: _controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  // Use AspectRatio and VideoPlayer to ensure it fills the screen like TikTok
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
        ),
        
        // Dark Gradient Overlay for text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.7), Colors.transparent, Colors.black.withOpacity(0.4)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Text Info (Name & Description)
        Positioned(
          bottom: 20,
          left: 16,
          right: 80, // Leave space for interaction belt
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.project.name,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.project.description,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Interaction Belt
        Positioned(
          bottom: 20,
          right: 8,
          child: InteractionBelt(project: widget.project),
        ),
      ],
    );
  }
}
