import 'package:flutter/material.dart';

class CategoryBar extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String? selectedCategory;

  const CategoryBar({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['Engineering', 'Medical', 'Commerce', 'Arts', 'School', 'Others'];
    
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          
          return ActionChip(
            label: Text(cat),
            onPressed: () => onCategorySelected(cat),
            backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : null,
            ),
          );
        },
      ),
    );
  }
}
