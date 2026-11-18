import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../services/publicjob_service.dart';
import '../widgets/te_ayudo_app_bar.dart';

class PublicJobScreen extends StatefulWidget {
  const PublicJobScreen({super.key});

  @override
  State<PublicJobScreen> createState() => _PublicJobScreenState();
}

class _PublicJobScreenState extends State<PublicJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _paymentController = TextEditingController();
  final _imagePicker = ImagePicker();
  Position? _jobLocation;
  Uint8List? _selectedPhotoBytes;
  String? _selectedPhotoName;
  bool _submitted = false;

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  Future<void> _selectCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showFormMessage('Activa los servicios de ubicación.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        _showFormMessage('Permiso de ubicación denegado.');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _showFormMessage(
          'Permiso denegado permanentemente. Actívalo en la configuración.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _jobLocation = position);
    } catch (error) {
      debugPrint('Error obteniendo la ubicación del trabajo: $error');
      _showFormMessage('No se pudo obtener tu ubicación.');
    }
  }

  Future<void> _chooseJobPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar una foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (photo == null) return;

      final bytes = await photo.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedPhotoBytes = bytes;
        _selectedPhotoName = photo.name;
      });
    } catch (error) {
      debugPrint('Error seleccionando la foto del trabajo: $error');
      _showFormMessage('No se pudo cargar la foto.');
    }
  }

  void _showFormMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _publishJob() {
    setState(() => _submitted = true);
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid ||
        _jobLocation == null ||
        _selectedPhotoBytes == null ||
        _selectedPhotoName == null) {
      return;
    }

    publicJobs.add(
      PublicJobData(
        serviceType: _serviceTypeController.text.trim(),
        description: _descriptionController.text.trim(),
        payment: _paymentController.text.trim(),
        latitude: _jobLocation!.latitude,
        longitude: _jobLocation!.longitude,
        photoBytes: _selectedPhotoBytes!,
        photoName: _selectedPhotoName!,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1976D2);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.grey[800]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Publicar Nuevo Trabajo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Crea una nueva solicitud de microturno',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Todos los campos son obligatorios.',
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _serviceTypeController,
                    decoration: InputDecoration(
                      labelText:
                          'Tipo de servicio (obligatorio; ej. Soporte técnico)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cardColor,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Ingresa el tipo de servicio.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descripción detallada (obligatoria)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cardColor,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Ingresa una descripción.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _paymentController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Ofrecimiento económico (MXN, obligatorio)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cardColor,
                    ),
                    validator: (value) {
                      final payment = double.tryParse(value?.trim() ?? '');
                      if (payment == null ||
                          !payment.isFinite ||
                          payment <= 0) {
                        return 'Ingresa un monto válido mayor que cero.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubicación actual (obligatoria)',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _selectCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: Text(
                      _jobLocation == null
                          ? 'Usar mi ubicación actual'
                          : 'Actualizar ubicación',
                    ),
                  ),
                  if (_jobLocation != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Latitud: ${_jobLocation!.latitude.toStringAsFixed(6)}, '
                      'Longitud: ${_jobLocation!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(color: textColor, fontSize: 13),
                    ),
                  ],
                  if (_submitted && _jobLocation == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Selecciona la ubicación del trabajo.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subir foto (obligatoria)',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _chooseJobPhoto,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(
                      _selectedPhotoName == null
                          ? 'Elegir foto o tomar una'
                          : 'Cambiar foto',
                    ),
                  ),
                  if (_selectedPhotoBytes != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _selectedPhotoBytes!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedPhotoName!,
                      style: TextStyle(color: textColor, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (_submitted && _selectedPhotoBytes == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Selecciona una foto para el trabajo.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _publishJob,
              child: const Text(
                'Publicar Trabajo Ahora',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
