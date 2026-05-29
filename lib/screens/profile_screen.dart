import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/firebase_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();

  bool _isUploading = false;
  PlatformFile? _pickedFile;

  @override
  void dispose() {
    _emailController.dispose();
    _whatsappController.dispose();
    _nameController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.image);

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _contactSupport() async {
    final whatsappUrl = Uri.parse(
      "whatsapp://send?phone=+51904275799&text=Hola,%20necesito%20soporte%20con%20la%20app%20Pegasus",
    );
    final fallbackUrl = Uri.parse(
      "https://wa.me/51904275799?text=Hola,%20necesito%20soporte%20con%20la%20app%20Pegasus",
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir WhatsApp para soporte.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al intentar abrir WhatsApp: $e')),
        );
      }
    }
  }

  Future<void> _submitData() async {
    final email = _emailController.text.trim();
    final whatsapp = _whatsappController.text.trim();
    final name = _nameController.text.trim();
    final dni = _dniController.text.trim();

    if (email.isEmpty || whatsapp.isEmpty || name.isEmpty || dni.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos requeridos.'),
        ),
      );
      return;
    }

    if (dni.length != 8 || int.tryParse(dni) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El DNI debe tener exactamente 8 dígitos numéricos.'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? profilePicUrl;

    // 1. Attempt Image Upload to Firebase Storage with a Graceful Fallback
    if (_pickedFile != null && _pickedFile!.path != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pics')
            .child(
              '${DateTime.now().millisecondsSinceEpoch}_${_pickedFile!.name}',
            );

        final uploadTask = await storageRef.putFile(File(_pickedFile!.path!));
        profilePicUrl = await uploadTask.ref.getDownloadURL();
      } catch (storageError) {
        debugPrint('Firebase Storage upload failed: $storageError');
        // Graceful fallback - display a snackbar but let account creation proceed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Nota: No se pudo subir la foto de perfil, pero se guardarán tus datos.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }

    // 2. Submit data to Firestore
    try {
      await submitSimpleUserToFirebase({
        "name": name,
        "email": email,
        "phoneNumber": whatsapp,
        "dni": dni,
        "profilePicUrl": profilePicUrl,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cuenta creada exitosamente!')),
        );
        _emailController.clear();
        _whatsappController.clear();
        _nameController.clear();
        _dniController.clear();
        setState(() {
          _pickedFile = null;
        });
        ref.invalidate(apiSimpleUsersProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Widget _buildTextField(
    String label, {
    String? hintText,
    int maxLines = 1,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLength: maxLength,
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
        counterText: "", // Keep layout clean and distraction-free
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.deepPurple,
                      backgroundImage:
                          _pickedFile != null && _pickedFile!.path != null
                          ? FileImage(File(_pickedFile!.path!))
                          : null,
                      child: _pickedFile == null
                          ? const Icon(
                              Icons.person,
                              size: 45,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Registro de Usuario',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Correo de contacto',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Número de contacto',
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Nombre Completo',
              controller: _nameController,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'DNI (Perú - 8 dígitos)',
              controller: _dniController,
              keyboardType: TextInputType.number,
              maxLength: 8,
            ),
            const SizedBox(height: 32),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Crear cuenta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _contactSupport,
              icon: Icon(Icons.support_agent, color: theme.primaryColor),
              label: Text(
                'Soporte y Contacto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: theme.primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
