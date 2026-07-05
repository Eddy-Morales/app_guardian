import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/zone_model.dart';
import '../../providers/zone_provider.dart';

class ZoneFormScreen extends StatefulWidget {
  final ZoneModel? zone;

  const ZoneFormScreen({super.key, this.zone});

  @override
  State<ZoneFormScreen> createState() => _ZoneFormScreenState();
}

class _ZoneFormScreenState extends State<ZoneFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  String riskLevel = 'Bajo';

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.zone?.name ?? '');

    riskLevel = widget.zone?.riskLevel ?? 'Bajo';
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
                  );

                  if (widget.zone == null) {
                    await provider.addZone(zone);
                  } else {
                    await provider.editZone(zone.id, zone);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.zone == null
                    ? "Crear"
                    : "Actualizar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}