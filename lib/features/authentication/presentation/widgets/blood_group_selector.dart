import 'package:flutter/material.dart';

class BloodGroupSelector extends StatelessWidget {
  final String? selectedGroup;
  final Function(String) onSelected;

  const BloodGroupSelector({
    super.key,
    required this.selectedGroup,
    required this.onSelected,
  });

  static const List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Group',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _bloodGroups.length,
            itemBuilder: (context, index) {
              final group = _bloodGroups[index];
              final isSelected = group == selectedGroup;

              return GestureDetector(
                onTap: () => onSelected(group),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    group,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
