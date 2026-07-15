import 'package:flutter/material.dart';

/// Utilidad centralizada (Clean Code: evita "magic strings" repetidos
/// en toda la app) para mapear una categoría de incidente a un color
/// e ícono consistentes, usados tanto en las tarjetas de la lista
/// como en los marcadores del mapa.
class CategoryUtils {
  CategoryUtils._();

  static const List<String> all = [
    'Robo',
    'Accidente',
    'Vandalismo',
    'Persona sospechosa',
    'Incendio',
    'Violencia',
    'Otro',
  ];

  static const Map<String, Color> _colors = {
    'Robo': Color(0xFFD32F2F),
    'Accidente': Color(0xFFF57C00),
    'Vandalismo': Color(0xFF7B1FA2),
    'Persona sospechosa': Color(0xFF455A64),
    'Incendio': Color(0xFFE64A19),
    'Violencia': Color(0xFFC2185B),
    'Otro': Color(0xFF616161),
  };

  static const Map<String, IconData> _icons = {
    'Robo': Icons.lock_open,
    'Accidente': Icons.car_crash,
    'Vandalismo': Icons.broken_image,
    'Persona sospechosa': Icons.visibility,
    'Incendio': Icons.local_fire_department,
    'Violencia': Icons.report_problem,
    'Otro': Icons.report,
  };

  static Color colorOf(String category) =>
      _colors[category] ?? const Color(0xFF616161);

  static IconData iconOf(String category) =>
      _icons[category] ?? Icons.report;

  /// Tono de marcador de Google Maps (BitmapDescriptor.hueX) según
  /// categoría, para que cada tipo de incidente se distinga en el mapa.
  static double markerHueOf(String category) {
    switch (category) {
      case 'Robo':
        return 0;      // rojo
      case 'Accidente':
        return 30;     // naranja
      case 'Vandalismo':
        return 270;    // morado
      case 'Persona sospechosa':
        return 180;    // azul grisáceo
      case 'Incendio':
        return 15;     // rojo-naranja
      case 'Violencia':
        return 300;    // magenta 
      case 'Otro':
        return 60;     // amarillo 
      default:
        return 0;
    }
  }
}
