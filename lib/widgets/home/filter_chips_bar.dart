import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class FilterChipsBar extends StatefulWidget {
  final String selectedFilter;
  final Function(String) onSelect;

  const FilterChipsBar({
    super.key,
    required this.selectedFilter,
    required this.onSelect,
  });

  @override
  State<FilterChipsBar> createState() => _FilterChipsBarState();
}

class _FilterChipsBarState extends State<FilterChipsBar> {
  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).primaryColor;
    final user = AuthService().currentUser;

    final List<Map<String, String>> filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Near Me', 'value': 'near_me'},
      {'label': 'Free', 'value': 'free'},
    ];

    // Add My School if logged in and has school
    if (user != null && user.school != null) {
      filters.insert(2, {'label': 'My School', 'value': 'my_school'});
    }

    // Add classes
    for (int i = 6; i <= 12; i++) {
      filters.add({'label': 'Class $i', 'value': 'class_$i'});
    }

    // Boards
    filters.addAll([
      {'label': 'CBSE', 'value': 'cbse'},
      {'label': 'ICSE', 'value': 'icse'},
      {'label': 'State Board', 'value': 'state_board'},
    ]);

    // Exams
    filters.addAll([
      {'label': 'JEE', 'value': 'jee'},
      {'label': 'NEET', 'value': 'neet'},
    ]);

    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = widget.selectedFilter == filter['value'];

          return ChoiceChip(
            label: Text(filter['label']!),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                widget.onSelect(filter['value']!);
              }
            },
            selectedColor: baseColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.white,
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? baseColor : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }
}
