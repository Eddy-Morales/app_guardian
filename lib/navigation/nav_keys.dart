import 'package:flutter/material.dart';

/// Permite navegar desde fuera del árbol de widgets (por ejemplo,
/// desde el listener de deep links en main.dart) sin depender de
/// qué pantalla esté activa en ese momento.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();