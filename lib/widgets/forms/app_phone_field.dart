import 'package:flutter/material.dart';
import '../../utils/validators.dart';
import '../../utils/input_formatters.dart';
import 'app_text_field.dart';

class AppPhoneField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final void Function(String)? onChanged;

  const AppPhoneField({
    super.key,
    this.controller,
    this.label = 'Phone Number',
    this.hint = '10-digit mobile number',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: TextInputType.phone,
      formatters: [
        AppInputFormatters.phone(),
        AppInputFormatters.maxLen(10),
      ],
      validator: AppValidators.phone,
      onChanged: onChanged,
      prefix: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Text(
          '+91 ',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
