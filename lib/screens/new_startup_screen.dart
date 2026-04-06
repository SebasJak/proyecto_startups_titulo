import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/api_data_provider.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitStartup() async {
    final name = _nameController.text.trim().isEmpty ? "Startup Nueva (Sin Nombre)" : _nameController.text.trim();
    final desc = _descController.text.trim().isEmpty ? "Startups platform testing submission." : _descController.text.trim();

    try {
      // POST payload to the backend
      await submitStartupNetwork({
        "name": name,
        "description": desc,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Startup subida exitosamente al Backend!')),
        );
        
        // Invalidate the cache to trigger a network refresh on the feed screen!
        ref.invalidate(apiProjectsProvider);
        
        context.pop();
      }
    } catch(e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de red: $e')),
        );
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
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _submitStartup,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Subir Startup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        _buildTextField('URL del Pitch Video (TikTok format)'),
        const SizedBox(height: 24),
        const Text('Pitch Deck (PDF)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Subir archivo PDF'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            side: const BorderSide(color: Colors.deepPurpleAccent),
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
