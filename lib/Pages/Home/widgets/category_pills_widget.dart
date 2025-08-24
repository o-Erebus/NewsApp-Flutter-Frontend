// lib/Pages/Home/widgets/category_pills_widget.dart
import 'package:flutter/material.dart';

class CategoryPillsWidget extends StatefulWidget {
  final Function(String) onCategorySelected;
  final String initialCategory;

  const CategoryPillsWidget({
    super.key,
    required this.onCategorySelected,
    this.initialCategory = 'all',
  });

  @override
  State<CategoryPillsWidget> createState() => _CategoryPillsWidgetState();
}

class _CategoryPillsWidgetState extends State<CategoryPillsWidget> {
  late String _selectedCategory;

  // All possible tags as specified in the requirements
  final List<String> _categories = [
    'all',
    'business',
    'technology',
    'entertainment',
    'science',
    'sports',
    'health',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = category == _selectedCategory;

            return Padding(
              padding: EdgeInsets.only(
                right: index == _categories.length - 1 ? 0 : 8.0,
                left: index == 0 ? 0 : 8.0,
              ),
              child: ChoiceChip(
                label: Text(
                  _formatCategoryName(category),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    widget.onCategorySelected(category);
                  }
                },
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatCategoryName(String category) {
    if (category == 'all') return 'All';
    return category[0].toUpperCase() + category.substring(1);
  }
}
