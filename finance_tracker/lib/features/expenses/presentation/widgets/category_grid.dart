import 'package:finance_tracker/core/constants/app_categories.dart';
import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 720 ? 4 : width >= 460 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appCategories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemBuilder: (context, index) {
            final category = appCategories[index];
            final isSelected = selectedCategory == category.name;

            return ChoiceChip(
              selected: isSelected,
              onSelected: (_) => onSelected(category.name),
              avatar: Icon(category.icon, size: 18, color: category.color),
              label: Text(category.name, overflow: TextOverflow.ellipsis),
            );
          },
        );
      },
    );
  }
}
