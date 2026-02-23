import 'package:flutter/material.dart';
import '../../utils/validators.dart';
import '../../utils/input_formatters.dart';
import 'app_text_field.dart';

class AppPriceField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const AppPriceField({
    super.key,
    this.controller,
    this.label = 'Price',
    this.hint = '0',
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      formatters: [AppInputFormatters.price()],
      validator: validator ?? AppValidators.price,
      onChanged: onChanged,
      prefix: const Icon(Icons.currency_rupee, size: 20),
    );
  }
}
