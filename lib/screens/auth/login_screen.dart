import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

/// Pantalla de inicio de sesión. Responsabilidad única: capturar
/// credenciales y delegar la autenticación al AuthProvider.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// Mensaje de error proveniente del servidor (credenciales incorrectas,
  /// usuario inexistente, etc.). Se limpia cada vez que el usuario
  /// modifica algún campo.
  String? _authError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Limpia el banner de error cuando el usuario empieza a corregir
  /// su entrada, para no dejar un mensaje obsoleto en pantalla.
  void _clearError() {
    if (_authError != null) setState(() => _authError = null);
  }

  Future<void> _submit() async {
    // Limpia error anterior antes de un nuevo intento
    setState(() => _authError = null);

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final error = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      // Muestra el error dentro del formulario (más visible y permanente
      // que un SnackBar, que desaparece en segundos).
      setState(() => _authError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo ─────────────────────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.shield,
                        size: 72,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Título ────────────────────────────────────────────────
                  const Text(
                    'Guardian',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const Text(
                    'Reportes comunitarios de seguridad',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.gray),
                  ),
                  const SizedBox(height: 32),

                  // ── Campos ────────────────────────────────────────────────
                  CustomTextField(
                    controller: _emailController,
                    label: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => _clearError(),
                    validator: (val) => val == null || !val.contains('@')
                        ? 'Ingresa un correo válido'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    onChanged: (_) => _clearError(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (val) => val == null || val.length < 6
                        ? 'La contraseña debe tener al menos 6 caracteres'
                        : null,
                  ),

                  // ── Banner de error de autenticación ──────────────────────
                  // Solo se muestra cuando el servidor devuelve un error
                  // (credenciales incorrectas, usuario no encontrado, etc.).
                  if (_authError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.alertRed.withOpacity(0.08),
                        border: Border.all(
                            color: AppColors.alertRed.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.alertRed, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _authError!,
                              style: const TextStyle(
                                color: AppColors.alertRed,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Olvidé contraseña ─────────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen()),
                      ),
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),

                  // ── Botón de ingreso ──────────────────────────────────────
                  authProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FilledButton(
                          onPressed: _submit,
                          child: const Text('Iniciar sesión'),
                        ),
                  const SizedBox(height: 16),

                  // ── Registro ──────────────────────────────────────────────
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
