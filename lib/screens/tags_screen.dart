import 'package:flutter/material.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Etiquetas')),
      body: const Center(
        child: Text('En desarrollo: Categorías / Etiquetas de Startups'),
      ),
    );
  }
}
