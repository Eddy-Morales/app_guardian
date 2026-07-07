import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/models/incident_model.dart';
import '/providers/incident_provider.dart';
import '../../config/theme.dart';
import '../../services/geocoding_service.dart';
import '../../services/location_service.dart';
import '../../widgets/custom_text_field.dart';


class IncidentFormScreen extends StatefulWidget {
  const IncidentFormScreen({super.key});

  @override
  State<IncidentFormScreen> createState() =>
      _IncidentFormScreenState();
}

class _IncidentFormScreenState extends State<IncidentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController =
      TextEditingController();
  final _latController =
      TextEditingController();
  final _lngController =
      TextEditingController();
  final _addressController =
      TextEditingController();
  final LocationService _locationService = LocationService();
  final GeocodingService _geocodingService = GeocodingService();

  String? _selectedCategory;
  bool _isEditing = false;
  bool _isLocating = false;
  IncidentModel? _incident;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final List<String> categories = [
    'Robo',
    'Accidente',
    'Incendio',
    'Violencia',
    'Emergencia',
    'Otro',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_incident == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments;

      if (args != null && args is IncidentModel) {
        _incident = args;
        _isEditing = true;

        _selectedCategory = _incident!.category;

        _descriptionController.text =
            _incident!.description;

        _latController.text =
            _incident!.lat.toString();

        _lngController.text =
            _incident!.lng.toString();
        _addressController.text =
            _incident!.address ?? '';
          
      }

    } else {
      // Modo creación: obtenemos la ubicación automáticamente al abrir
      // el formulario.
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchLocation());
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Obtiene coordenadas GPS y luego resuelve la dirección legible
  /// mediante la API externa de Reverse Geocoding (Google Maps).
  Future<void> _fetchLocation() async {
    setState(() => _isLocating = true);
    try {
      final position = await _locationService.getCurrentPosition();

      setState(() {
        _latController.text = position.latitude.toString();
        _lngController.text = position.longitude.toString();
      });

      try {
        final address = await _geocodingService.reverseGeocode(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        if (mounted) setState(() => _addressController.text = address);
      } on GeocodingException catch (e) {
        // La ubicación sí se obtuvo; solo falló resolver el texto de dirección.
        if (mounted) _showSnack(e.toString(), isError: true);
      }
    } on LocationException catch (e) {
      if (mounted) _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );

    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }
  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.alertRed : Colors.green,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latController.text.isEmpty || _lngController.text.isEmpty) {
      _showSnack('Debes obtener la ubicación antes de guardar.', isError: true);
      return;
    }

    final provider = context.read<IncidentProvider>();
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final incident = IncidentModel(
      id: _incident?.id ?? '',
      userId: _incident?.userId ?? currentUser.id,
      category: _selectedCategory!,
      description: _descriptionController.text.trim(),
      lat: double.parse(_latController.text),
      lng: double.parse(_lngController.text),

      // Luego aquí guardaremos la URL
      photoUrl: _incident?.photoUrl,

      createdAt:
          _incident?.createdAt ??
              DateTime.now(),
    );

    final error = _isEditing
        ? await provider.updateIncident(incident, _image)
        : await provider.addIncident(incident, _image);

    if (!mounted) return;

    if (error == null) {
      _showSnack(_isEditing ? 'Incidente actualizado' : 'Incidente registrado');
      Navigator.pop(context);
    } else {
      _showSnack(error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<IncidentProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Editar Incidente'
              : 'Nuevo Incidente',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: categories
                    .map(
                      (e) =>
                          DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory =
                        value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Seleccione una categoría';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Ingrese una descripción';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              const Text(
                "Fotografía",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : _incident?.photoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _incident!.photoUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
              ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text("Tomar fotografía"),
              ),

              const SizedBox(height: 25),

              const Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _addressController,
                label: 'Dirección',
                icon: Icons.location_on_outlined,
                enabled: false,
              ),
              const SizedBox(height: 8),
              if (_latController.text.isNotEmpty && _lngController.text.isNotEmpty)
                Text(
                  'Lat: ${_latController.text}  Lng: ${_lngController.text}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _isLocating ? null : _fetchLocation,
                icon: _isLocating
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location),
                label: Text(_isLocating ? 'Obteniendo ubicación...' : 'Usar mi ubicación actual'),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: provider.isLoading ? null : _save,
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEditing ? 'Actualizar' : 'Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
