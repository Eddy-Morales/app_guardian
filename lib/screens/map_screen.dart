import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/incident_provider.dart';
import '../services/location_service.dart';
import '../utils/category_utils.dart';
import 'incidents/incident_detail_screen.dart';

/// Mapa interactivo (Google Maps) que muestra:
/// - La ubicación actual del usuario.
/// - Todos los incidentes reportados, con un marcador coloreado según
///   su categoría.
/// Al tocar un marcador se abre un mini-resumen y se puede navegar
/// al detalle completo del incidente.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _controller;
  CameraPosition _initialPosition =
      const CameraPosition(target: LatLng(-0.1807, -78.4678), zoom: 12); // Quito, EC
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().loadIncidents();
    });
    _centerOnUser();
  }

  Future<void> _centerOnUser() async {
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        );
        _loadingLocation = false;
      });
      _controller?.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
    } catch (_) {
      setState(() => _loadingLocation = false);
    }
  }

  Set<Marker> _buildMarkers(IncidentProvider provider) {
    return provider.incidents.map((incident) {
      return Marker(
        markerId: MarkerId(incident.id),
        position: LatLng(incident.lat, incident.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          CategoryUtils.markerHueOf(incident.category),
        ),
        infoWindow: InfoWindow(
          title: incident.category,
          snippet: incident.description,
          onTap: () => Navigator.pushNamed(
            context,
            '/incident-detail',
            arguments: incident,
          ),
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de incidentes')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (controller) => _controller = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _buildMarkers(provider),
          ),
          if (_loadingLocation || provider.isLoading)
            const Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.darkBlue),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            child: _Legend(),
          ),
        ],
      ),
    );
  }
}

/// Leyenda de colores por categoría, visible sobre el mapa.
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: CategoryUtils.all.take(4).map((c) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: CategoryUtils.colorOf(c),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(c, style: const TextStyle(fontSize: 11)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
