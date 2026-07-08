import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/zone_model.dart';
import '../../providers/zone_provider.dart';
import '../../services/location_service.dart';

class ZoneFormScreen extends StatefulWidget {
  final ZoneModel? zone;

  const ZoneFormScreen({super.key, this.zone});

  @override
  State<ZoneFormScreen> createState() => _ZoneFormScreenState();
}

class _ZoneFormScreenState extends State<ZoneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocationService _locationService = LocationService();

  late TextEditingController nameController;
  late TextEditingController radiusController;
  String riskLevel = 'Bajo';

  double? _centerLat;
  double? _centerLng;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.zone?.name ?? '');

    radiusController = TextEditingController(
      text: (widget.zone?.radiusKm ?? 1.0).toString(),
    );

    riskLevel = widget.zone?.riskLevel ?? 'Bajo';
    _centerLat = widget.zone?.centerLat;
    _centerLng = widget.zone?.centerLng;
  }

  @override
  void dispose() {
    nameController.dispose();
    radiusController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _centerLat = position.latitude;
        _centerLng = position.longitude;
      });
    } on LocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ZoneProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.zone == null
            ? "Crear zona"
            : "Editar zona"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre de zona",
                ),
                validator: (v) =>
                    v!.isEmpty ? "Campo obligatorio" : null,
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: riskLevel,
                items: const [
                  DropdownMenuItem(
                      value: 'Bajo', child: Text('Bajo')),
                  DropdownMenuItem(
                      value: 'Medio', child: Text('Medio')),
                  DropdownMenuItem(
                      value: 'Alto', child: Text('Alto')),
                ],
                onChanged: (value) {
                  setState(() {
                    riskLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ubicación de la zona',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _centerLat != null && _centerLng != null
                    ? 'Centro: ${_centerLat!.toStringAsFixed(5)}, '
                      '${_centerLng!.toStringAsFixed(5)}'
                    : 'Sin ubicación definida — los incidentes no se '
                      'asignarán automáticamente a esta zona.',
                style: TextStyle(
                  fontSize: 12,
                  color: _centerLat != null ? Colors.black87 : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLocating ? null : _useCurrentLocation,
                icon: _isLocating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_isLocating
                    ? 'Obteniendo ubicación...'
                    : 'Usar mi ubicación actual como centro'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: radiusController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Radio de cobertura (km)',
                  helperText: 'Un incidente reportado dentro de este radio '
                      'se asignará automáticamente a esta zona.',
                ),
                validator: (v) {
                  final parsed = double.tryParse(v ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Ingrese un radio válido (mayor a 0)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final zone = ZoneModel(
                    id: widget.zone?.id ?? '',
                    name: nameController.text,
                    riskLevel: riskLevel,
                    incidentCount:
                        widget.zone?.incidentCount ?? 0,
                    centerLat: _centerLat,
                    centerLng: _centerLng,
                    radiusKm: double.tryParse(radiusController.text),
                  );

                  final error = widget.zone == null
                      ? await provider.addZone(zone)
                      : await provider.editZone(zone.id, zone);

                  if (context.mounted) {
                    if (error == null) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  }
                },
                child: Text(widget.zone == null ? "Crear" : "Actualizar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}