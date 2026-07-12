import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Excepción de dominio para errores al consumir la API externa.
class GeocodingException implements Exception {
  final String message;
  GeocodingException(this.message);
  @override
  String toString() => message;
}

/// Servicio que consume la API externa **Google Maps Geocoding API**
/// (Reverse Geocoding) para convertir coordenadas (lat, lng) en una
/// dirección legible para el usuario. Es la integración de "API
/// externa" que exige el Project Kit.
///
/// --------------------------------------------------------------
/// CÓMO CONSUMIR LA API
/// --------------------------------------------------------------
/// Endpoint:
///   GET https://maps.googleapis.com/maps/api/geocode/json
///       ?latlng={lat},{lng}
///       &key={API_KEY}
///       &language=es
///
/// Requisitos previos en Google Cloud Console:
///   1. Crear un proyecto y habilitar "Geocoding API".
///   2. Generar una API Key y restringirla (por app / por IP) para
///      producción.
///   3. Habilitar facturación (la API es de pago por uso, con cuota
///      gratuita mensual suficiente para un proyecto universitario).
///
/// --------------------------------------------------------------
/// CÓMO SE INTERPRETA EL JSON DE RESPUESTA
/// --------------------------------------------------------------
/// La respuesta tiene esta forma simplificada:
/// {
///   "status": "OK",
///   "results": [
///     {
///       "formatted_address": "Av. Amazonas N34-100, Quito, Ecuador",
///       "address_components": [ ... ]
///     },
///     ... (Google devuelve varios resultados, del más específico
///          -una dirección exacta- al más general -un país-)
///   ]
/// }
///
/// Para un MVP basta con tomar `results[0].formatted_address`, que es
/// el resultado más preciso. El campo `status` indica si hubo error:
///   "OK"               -> hay resultados válidos.
///   "ZERO_RESULTS"     -> coordenadas válidas pero sin dirección conocida.
///   "OVER_QUERY_LIMIT" -> se superó la cuota de la API Key.
///   "REQUEST_DENIED"   -> la API Key es inválida o no tiene el servicio habilitado.
///   "INVALID_REQUEST"  -> faltan parámetros obligatorios.
///
/// --------------------------------------------------------------
/// MANEJO DE ERRORES, TIMEOUTS Y VALIDACIONES
/// --------------------------------------------------------------
/// - Se usa `.timeout()` para no dejar a la UI esperando indefinidamente
///   si no hay respuesta del servidor (aquí: 8 segundos).
/// - Se valida el código HTTP (`response.statusCode == 200`) antes de
///   intentar decodificar el JSON.
/// - Se valida el campo `status` del propio JSON de Google (un 200 OK
///   de HTTP no garantiza que Google haya encontrado una dirección).
/// - Cualquier fallo se traduce a `GeocodingException` con un mensaje
///   entendible, para que la UI pueda mostrarlo directamente sin tener
///   que interpretar códigos internos de HTTP o de la API.
class GeocodingService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw GeocodingException(
        'Falta GOOGLE_MAPS_API_KEY en el archivo .env.',
      );
    }

    final uri = Uri.parse(
      '$_baseUrl?latlng=$latitude,$longitude&key=$apiKey&language=es',
    );

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw GeocodingException(
          'La solicitud de dirección tardó demasiado. Verifica tu conexión.',
        ),
      );
      print("HTTP: ${response.statusCode}");
      print(response.body);

      if (response.statusCode != 200) {
        throw GeocodingException(
          'El servicio de mapas respondió con un error '
          '(HTTP ${response.statusCode}).',
        );
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      final String status = body['status'] as String? ?? 'UNKNOWN_ERROR';

      switch (status) {
        case 'OK':
          final results = body['results'] as List<dynamic>;
          if (results.isEmpty) {
            return 'Dirección no disponible';
          }
          return results.first['formatted_address'] as String? ??
              'Dirección no disponible';
        case 'ZERO_RESULTS':
          return 'Ubicación sin dirección registrada';
        case 'OVER_QUERY_LIMIT':
          throw GeocodingException(
            'Se alcanzó el límite de solicitudes de la API de mapas.',
          );
        case 'REQUEST_DENIED':
          throw GeocodingException(
            'La clave de la API de Google Maps no es válida o no tiene '
            'habilitada la Geocoding API.',
          );
        default:
          throw GeocodingException(
            'No se pudo interpretar la dirección (status: $status).',
          );
      }
    } on GeocodingException {
      rethrow;
    } catch (e) {
      throw GeocodingException('Error de red al consultar la dirección: $e');
    }
  }
}
