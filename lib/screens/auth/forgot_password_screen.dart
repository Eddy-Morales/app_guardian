import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';

/// Pantalla de recuperación de contraseña. Envía un correo con un
/// enlace de restablecimiento mediante Supabase Auth.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final error = await authProvider.resetPassword(_emailController.text.trim());

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.alertRed),
      );
      return;
    }

    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _sent
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mark_email_read_outlined,
                        size: 64, color: AppColors.darkBlue),
                    const SizedBox(height: 16),
                    Text(
                      'Enviamos un enlace de recuperación a '
                      '${_emailController.text.trim()}. Revisa tu bandeja de entrada.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver al inicio de sesión'),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Ingresa el correo con el que te registraste. '
                        'Te enviaremos un enlace para restablecer tu contraseña.',
                        style: TextStyle(color: AppColors.gray),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || !val.contains('@')
                            ? 'Ingresa un correo válido'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      authProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : FilledButton(
                              onPressed: _submit,
                              child: const Text('Enviar enlace'),
                            ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
