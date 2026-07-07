import 'package:geolocator/geolocator.dart';

/// Excepción de dominio para errores de ubicación. Permite a la capa
/// superior (provider/UI) reaccionar sin depender de tipos de Geolocator.
class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  @override
  String toString() => message;
}

/// Servicio responsable EXCLUSIVAMENTE de obtener la posición GPS del
/// dispositivo y gestionar los permisos de ubicación (SRP).
///
/// Flujo de permisos en Android (runtime, API 23+):
/// 1. Verificar si el servicio de ubicación del dispositivo está
///    encendido (`isLocationServiceEnabled`). Si está apagado, no basta
///    con tener permiso: hay que pedir al usuario que active el GPS.
/// 2. Verificar el estado del permiso con `checkPermission()`.
///    - `denied`      -> aún no se ha pedido o el usuario lo negó una vez.
///    - `deniedForever` (Android: "No preguntar de nuevo") -> ya no se
///      puede solicitar por diálogo; hay que enviar al usuario a los
///      Ajustes de la app (`openAppSettings()`).
///    - `whileInUse` / `always` -> concedido, se puede leer el GPS.
/// 3. Si está `denied`, se solicita con `requestPermission()`, que
///    dispara el diálogo nativo del sistema operativo.
///
/// Estos permisos ya están declarados de forma estática en
/// android/app/src/main/AndroidManifest.xml:
///   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
///   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
/// pero en Android 6+ (API 23+) SIEMPRE hay que solicitarlos también en
/// tiempo de ejecución, que es justamente lo que hace esta clase.
class LocationService {
  /// Verifica servicio + permisos y, si todo está en orden, retorna la
  /// posición actual del dispositivo con alta precisión.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'El GPS está desactivado. Actívalo desde los ajustes del dispositivo.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(
          'Permiso de ubicación denegado. Guardian necesita tu ubicación '
          'para registrar dónde ocurrió el incidente.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'El permiso de ubicación fue bloqueado permanentemente. '
        'Habilítalo manualmente desde Ajustes > Aplicaciones > Guardian > Permisos.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on Exception {
      throw LocationException(
        'No se pudo obtener la ubicación. Verifica tu señal GPS e inténtalo de nuevo.',
      );
    }
  }

  /// Escucha cambios de posición en tiempo real (útil para el mapa
  /// mostrando "mi ubicación" en vivo).
  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  /// Abre la pantalla de ajustes de la app (para permisos "denegados para siempre").
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  /// Abre los ajustes de ubicación del sistema (para activar el GPS).
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
