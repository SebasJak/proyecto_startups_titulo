import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/firebase_provider.dart';

class NewStartupScreen extends ConsumerStatefulWidget {
  const NewStartupScreen({super.key});

  @override
  ConsumerState<NewStartupScreen> createState() => _NewStartupScreenState();
}

class _NewStartupScreenState extends ConsumerState<NewStartupScreen> {
  int _currentExpandedIndex = 0; // Starts with the first one expanded
  final int _totalCategories = 6;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? _selectedVideoFile;
  File? _selectedPdfFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedVideoFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdfFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitStartup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre de la startup es obligatorio.')));
      return;
    }

    if (_selectedVideoFile == null || _selectedPdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debe seleccionar obligatoriamente un Video y un archivo PDF (Deck).')));
      return;
    }

    final desc = _descController.text.trim().isEmpty ? "Startups platform testing submission." : _descController.text.trim();

    setState(() {
      _isUploading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final videoRef = storageRef.child("startups/videos/$timestamp.mp4");
      final pdfRef = storageRef.child("startups/decks/$timestamp.pdf");

      await videoRef.putFile(_selectedVideoFile!);
      final videoUrl = await videoRef.getDownloadURL();

      await pdfRef.putFile(_selectedPdfFile!);
      final deckUrl = await pdfRef.getDownloadURL();

      await submitStartupToFirebase({
        "name": name,
        "description": desc,
        "videoUrl": videoUrl, // Replaced dummy with actual upload
        "deckUrl": deckUrl,
        "ownerPhoneNumber": "+51904275799",
        "likesCount": 0,
        "isLikedByMe": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Startup subida exitosamente a Firebase!')),
        );
        ref.invalidate(apiProjectsProvider);
        context.pop();
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de Firebase: $e')),
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

  @override
  Widget build(BuildContext context) {
    // Progress based on the furthest category they clicked (or just the active one)
    double progress = (_currentExpandedIndex + 1) / _totalCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Startup'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), 
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progreso', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                if (isExpanded) {
                   _currentExpandedIndex = index;
                }
              });
            },
            dividerColor: Colors.grey[800],
            elevation: 1,
            children: [
              _buildPanel(0, 'Información básica', _buildBasicInfoFields()),
              _buildPanel(1, 'Categorización', _buildCategorizationFields()),
              _buildPanel(2, 'Material (Deck y Video)', _buildMaterialFields()),
              _buildPanel(3, 'Datos de Founders', _buildFoundersFields()),
              _buildPanel(4, 'Requerimientos de Inversión', _buildInvestmentFields()),
              _buildPanel(5, 'Roadmap', _buildRoadmapFields()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isUploading ? Colors.grey : Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isUploading ? null : _submitStartup,
              icon: _isUploading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? 'Subiendo datos y archivos...' : 'Subir Startup', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  ExpansionPanel _buildPanel(int index, String title, Widget body) {
    return ExpansionPanel(
      backgroundColor: Colors.grey[900],
      isExpanded: _currentExpandedIndex == index,
      canTapOnHeader: true,
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      },
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: body,
      ),
    );
  }

  Widget _buildBasicInfoFields() {
    return Column(
      children: [
        _buildTextField('Nombre de la Startup', controller: _nameController),
        const SizedBox(height: 16),
        _buildTextField('Descripción Corta', hintText: 'Describe tu propuesta de valor en 140 caracteres...', maxLines: 2, controller: _descController),
      ],
    );
  }

  Widget _buildCategorizationFields() {
    return Column(
      children: [
        _buildTextField('Industria / Sector (ej. FinTech, HealthTech)'),
        const SizedBox(height: 16),
        _buildTextField('Modelo de Negocio (ej. B2B, B2C)'),
        const SizedBox(height: 16),
        _buildTextField('Etapa Actual (ej. Idea, MVP, Seed)'),
      ],
    );
  }

  Widget _buildMaterialFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Pitch Video (TikTok format)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickVideo,
          icon: Icon(_selectedVideoFile == null ? Icons.video_call : Icons.check_circle, 
                 color: _selectedVideoFile == null ? Colors.white : Colors.greenAccent),
          label: Text(_selectedVideoFile == null ? 'Seleccionar Video' : 'Video Seleccionado'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            side: BorderSide(color: _selectedVideoFile == null ? Colors.deepPurpleAccent : Colors.green),
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text('Pitch Deck (PDF)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickPdf,
          icon: Icon(_selectedPdfFile == null ? Icons.picture_as_pdf : Icons.check_circle,
                 color: _selectedPdfFile == null ? Colors.white : Colors.greenAccent),
          label: Text(_selectedPdfFile == null ? 'Seleccionar archivo PDF' : 'PDF Seleccionado'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            side: BorderSide(color: _selectedPdfFile == null ? Colors.deepPurpleAccent : Colors.green),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFoundersFields() {
    return Column(
      children: [
        _buildTextField('Nombre del Founder / Líder'),
        const SizedBox(height: 16),
        _buildTextField('Número de WhatsApp de Contacto'),
        const SizedBox(height: 16),
        _buildTextField('LinkedIn del Equipo'),
      ],
    );
  }

  Widget _buildInvestmentFields() {
    return Column(
      children: [
        _buildTextField('Monto Buscado (USD)'),
        const SizedBox(height: 16),
        _buildTextField('Uso de Fondos (ej. 40% Marketing, 60% Dev)', maxLines: 3),
      ],
    );
  }

  Widget _buildRoadmapFields() {
    return Column(
      children: [
        _buildTextField('Hitos a 6 Meses', maxLines: 3),
        const SizedBox(height: 16),
        _buildTextField('Visión a 2 Años', maxLines: 3),
      ],
    );
  }

  Widget _buildTextField(String label, {String? hintText, int maxLines = 1, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38),
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
      ),
    );
  }
}
