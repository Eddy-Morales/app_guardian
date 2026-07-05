import 'package:flutter/material.dart';
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
          ModalRoute.of(context)
              ?.settings
              .arguments;

      if (args != null &&
          args is IncidentModel) {

        _incident = args;
        _isEditing = true;

        _selectedCategory =
            _incident!.category;

        _descriptionController.text =
            _incident!.description;

        _latController.text =
            _incident!.lat.toString();

        _lngController.text =
            _incident!.lng.toString();
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
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
      userId: _incident?.userId ??
          currentUser.id,
      category: _selectedCategory!,
      description:
          _descriptionController.text.trim(),
      lat: double.parse(
          _latController.text),
      lng: double.parse(
          _lngController.text),
      photoUrl:
          _incident?.photoUrl,
      createdAt:
          _incident?.createdAt ??
          DateTime.now(),
    );

    String? error;

    if (_isEditing) {
      error = await provider
          .updateIncident(incident);
    } else {
      error = await provider
          .addIncident(incident);
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
            children: [

              DropdownButtonFormField<String>(
                value:
                    _selectedCategory,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Categoría',
                  border:
                      OutlineInputBorder(),
                ),
                items: categories
                    .map(
                      (e) => DropdownMenuItem(
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

              const SizedBox(
                  height: 16),

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

              const SizedBox(
                  height: 16),

              TextFormField(
                controller:
                    _latController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Latitud',
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value
                          .isEmpty) {
                    return 'Ingrese la latitud';
                  }
                  return null;
                },
              ),

              const SizedBox(
                  height: 16),

              TextFormField(
                controller:
                    _lngController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Longitud',
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value
                          .isEmpty) {
                    return 'Ingrese la longitud';
                  }
                  return null;
                },
              ),

              const SizedBox(
                  height: 30),

              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton(
                  onPressed:
                      provider.isLoading
                          ? null
                          : _saveIncident,
                  child:
                      provider.isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              _isEditing
                                  ? 'Actualizar'
                                  : 'Registrar',
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