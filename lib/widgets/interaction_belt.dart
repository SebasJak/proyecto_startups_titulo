import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/startup_project.dart';

class InteractionBelt extends ConsumerWidget {
  final StartupProject project;

  const InteractionBelt({super.key, required this.project});

  Future<void> _launchWhatsApp(BuildContext context) async {
    // According to MVP requirements, team leader number is constant, hardcoded in model
    final url = Uri.parse("whatsapp://send?phone=${project.ownerPhoneNumber}&text=Hi, I am interested in investing in your MVP: ${project.name}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildIcon(Icons.lightbulb_outline, 'Buena idea', () {}),
        _buildIcon(Icons.share, 'Recomendar', () {
           Share.share('Check out this awesome startup idea: ${project.name}! \n\n${project.description}');
        }),
        _buildIcon(Icons.slideshow, 'Ver Deck', () {}),
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
