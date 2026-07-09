import 'package:flutter/material.dart';

/// Campo de texto reutilizable en toda la app (login, registro,
/// formulario de incidentes, perfil). Evita duplicar la misma
/// configuración de estilo en cada pantalla (Clean Code: DRY).
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool enabled;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
