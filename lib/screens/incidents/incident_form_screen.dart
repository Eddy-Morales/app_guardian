import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/models/incident_model.dart';
import '/providers/incident_provider.dart';

class IncidentFormScreen extends StatefulWidget {
  const IncidentFormScreen({super.key});

  @override
  State<IncidentFormScreen> createState() =>
      _IncidentFormScreenState();
}

class _IncidentFormScreenState
    extends State<IncidentFormScreen> {

  final _formKey = GlobalKey<FormState>();

  final _descriptionController =
      TextEditingController();

  final _latController =
      TextEditingController();

  final _lngController =
      TextEditingController();

  String? _selectedCategory;

  bool _isEditing = false;

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
          
      }

    }
    if (!_isEditing) {
  _getCurrentLocation();
}
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Active el GPS del dispositivo'),
        ),
      );
      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Permiso de ubicación denegado'),
        ),
      );
      return;
    }

    Position position =
        await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _latController.text =
          position.latitude.toString();

      _lngController.text =
          position.longitude.toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text("Ubicación obtenida correctamente"),
      ),
    );
  }

  Future<void> _saveIncident() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider =
        context.read<IncidentProvider>();

    final currentUser =
        Supabase.instance.client.auth.currentUser;

    if (currentUser == null) return;

    final incident = IncidentModel(
      id: _incident?.id ?? '',
      userId:
          _incident?.userId ?? currentUser.id,
      category: _selectedCategory!,
      description:
          _descriptionController.text.trim(),
      lat: double.parse(_latController.text),
      lng: double.parse(_lngController.text),

      // Luego aquí guardaremos la URL
      photoUrl: _incident?.photoUrl,

      createdAt:
          _incident?.createdAt ??
              DateTime.now(),
    );

    String? error;

    if (_isEditing) {
  error = await provider.updateIncident(
    incident,
    _image,
  );
} else {
  error = await provider.addIncident(
    incident,
    _image,
  );
}

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Incidente actualizado'
                : 'Incidente registrado',
          ),
        ),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final provider =
        context.watch<IncidentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Editar Incidente'
              : 'Nuevo Incidente',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration:
                    const InputDecoration(
                  labelText: 'Categoría',
                  border:
                      OutlineInputBorder(),
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
                decoration:
                    const InputDecoration(
                  labelText:
                      'Descripción',
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
          ),),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: _pickImage,
                icon:
                    const Icon(Icons.camera_alt),
                label:
                    const Text("Tomar fotografía"),
              ),

              const SizedBox(height: 25),

              const Text(
                "Ubicación",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller:
                    _latController,
                readOnly: true,
                decoration:
                    const InputDecoration(
                  labelText: "Latitud",
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "Obtenga la ubicación";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _lngController,
                readOnly: true,
                decoration:
                    const InputDecoration(
                  labelText: "Longitud",
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "Obtenga la ubicación";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed:
                    _getCurrentLocation,
                icon:
                    const Icon(Icons.my_location),
                label: const Text(
                  "Usar mi ubicación actual",
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      provider.isLoading
                          ? null
                          : _saveIncident,
                  child:
                      provider.isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              _isEditing
                                  ? "Actualizar"
                                  : "Registrar",
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}