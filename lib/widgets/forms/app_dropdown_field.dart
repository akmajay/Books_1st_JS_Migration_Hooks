import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final List<String>? itemLabels;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final void Function(T?)? onSaved;

  const AppDropdownField({
    super.key,
    required this.label,
    this.value,
    this.items = const [],
    this.itemLabels,
    this.validator,
    this.onChanged,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: List.generate(items.length, (index) {
        final item = items[index];
        final label = itemLabels != null && itemLabels!.length > index
            ? itemLabels![index]
            : item.toString();
        return DropdownMenuItem<T>(
          value: item,
          child: Text(label),
        );
      }).toList(),
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}
