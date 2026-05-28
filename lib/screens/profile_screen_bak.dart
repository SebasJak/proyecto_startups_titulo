import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/firebase_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _founderController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController(text: '+51904275799');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _surveyUrlController = TextEditingController();

  bool _isUploading = false;

  @override
  void dispose() {
    _founderController.dispose();
    _whatsappController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _surveyUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    final founderName = _founderController.text.trim();
    final whatsapp = _whatsappController.text.trim();
    final startupName = _nameController.text.trim();
    final desc = _descController.text.trim();
    final surveyUrl = _surveyUrlController.text.trim().isEmpty ? null : _surveyUrlController.text.trim();

    if (founderName.isEmpty || whatsapp.isEmpty || startupName.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos requeridos.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final combinedDesc = "$founderName - $desc";

      await submitStartupToFirebase({
        "name": startupName,
        "description": combinedDesc,
        "videoUrl": "", // Managed manually by project owner
        "deckUrl": "", // Managed manually by project owner
        "surveyUrl": surveyUrl,
        "ownerPhoneNumber": "+51904275799", // MVP fixed number
        "likesCount": 0,
        "isLikedByMe": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Datos subidos exitosamente!')),
        );
        _founderController.clear();
        _whatsappController.clear();
        _nameController.clear();
        _descController.clear();
        _surveyUrlController.clear();
        ref.invalidate(apiProjectsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Widget _buildTextField(String label, {String? hintText, int maxLines = 1, required TextEditingController controller, bool readOnly = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        labelStyle: TextStyle(color: theme.primaryColor),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Registro de Startup',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('Nombre del Founder / Líder', controller: _founderController),
            const SizedBox(height: 16),
            _buildTextField('Número de WhatsApp de Contacto', controller: _whatsappController, readOnly: true),
            const SizedBox(height: 16),
            _buildTextField('Nombre de la Startup', controller: _nameController),
            const SizedBox(height: 16),
            _buildTextField(
              'Descripción Corta',
              hintText: 'Describe tu propuesta de valor en 140 caracteres...',
              maxLines: 2,
              controller: _descController,
            ),
            const SizedBox(height: 16),
            _buildTextField('URL de Encuesta (Opcional - Google Forms)', controller: _surveyUrlController),
            const SizedBox(height: 32),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Subir datos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }
}
