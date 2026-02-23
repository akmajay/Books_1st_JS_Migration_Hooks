import 'package:flutter/material.dart';

class AppChipSelector extends StatelessWidget {
  final String label;
  final String? selected;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSelected; // Required by some callers

  const AppChipSelector({
    super.key,
    required this.label,
    this.selected,
    required this.options,
    required this.onChanged,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  onChanged(option);
                  onSelected?.call(option);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
