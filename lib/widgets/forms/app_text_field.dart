import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final int? maxLines;
  final Widget? prefix;
  final bool obscureText;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.keyboardType,
    this.formatters,
    this.maxLines = 1,
    this.prefix,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      maxLines: maxLines,
      obscureText: obscureText,
    );
  }
}
