import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/favorites_provider.dart';
import '../providers/firebase_provider.dart';
import '../providers/likes_provider.dart';
import '../models/startup_project.dart';

class InteractionBelt extends ConsumerStatefulWidget {
  final StartupProject project;

  const InteractionBelt({super.key, required this.project});

  @override
  ConsumerState<InteractionBelt> createState() => _InteractionBeltState();
}

class _InteractionBeltState extends ConsumerState<InteractionBelt> {
  late int _localLikesCount;

  @override
  void initState() {
    super.initState();
    _localLikesCount = widget.project.likesCount;
  }

  String _formatLikes(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final url = Uri.parse("whatsapp://send?phone=${widget.project.ownerPhoneNumber}&text=Hola, estoy interesado en invertir en tu MVP: ${widget.project.name}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir WhatsApp')));
      }
    }
  }

  Future<void> _launchDeck(BuildContext context) async {
    final url = Uri.parse(widget.project.deckUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el Deck PDF')));
      }
    }
  }

  Future<void> _launchSurvey(BuildContext context) async {
    if (widget.project.surveyUrl == null || widget.project.surveyUrl!.isEmpty) return;
    final url = Uri.parse(widget.project.surveyUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir la encuesta')));
      }
    }
  }

  void _onGuardarTap(BuildContext context) {
    ref.read(favoritesProvider.notifier).toggleFavorite(widget.project.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favoritos actualizados'), duration: Duration(milliseconds: 500)),
    );
  }

  void _onLikeTap() {
    final likes = ref.read(likesProvider);
    final isCurrentlyLiked = likes.contains(widget.project.id);

    if (isCurrentlyLiked) {
      setState(() {
        _localLikesCount--;
      });
      ref.read(likesProvider.notifier).removeLike(widget.project.id);
      decrementLikeCount(widget.project.id);
    } else {
      setState(() {
        _localLikesCount++;
      });
      ref.read(likesProvider.notifier).addLike(widget.project.id);
      incrementLikeCount(widget.project.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(widget.project.id);
    
    final likes = ref.watch(likesProvider);
    final isLiked = likes.contains(widget.project.id);
    
    final likeLabel = _localLikesCount > 0 ? _formatLikes(_localLikesCount) : 'Buena idea';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.project.surveyUrl != null && widget.project.surveyUrl!.trim().isNotEmpty)
          _buildIcon(Icons.assignment, 'Encuesta', () => _launchSurvey(context)),
        _buildIcon(isFavorite ? Icons.bookmark : Icons.bookmark_border, 'Guardar', () => _onGuardarTap(context)),
        _buildIcon(isLiked ? Icons.lightbulb : Icons.lightbulb_outline, likeLabel, _onLikeTap),
        _buildIcon(Icons.share, 'Recomendar', () {
           Share.share('¡Mira esta increíble idea de startup: ${widget.project.name}! \n\n${widget.project.description}');
        }),
        _buildIcon(Icons.slideshow, 'Ver Deck', () => _launchDeck(context)),
        _buildIcon(Icons.attach_money, 'Invertir', () => _launchWhatsApp(context)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildIcon(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          IconButton(
            icon: Icon(icon, size: 36, color: Colors.white),
            onPressed: onTap,
          ),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
