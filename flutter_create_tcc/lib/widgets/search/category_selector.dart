import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_category.dart';
import '../../providers/product_provider.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ProductCategory.values;

    return SizedBox(
      height: 50,
      child: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length + 1, // +1 para opção "Todos"
            itemBuilder: (context, index) {
              // Primeira opção: "Todos"
              if (index == 0) {
                final isSelected = provider.selectedCategory == null;
                return _CategoryChip(
                  label: 'Todos',
                  isSelected: isSelected,
                  onTap: () => provider.setCategory(null),
                );
              }

              // Demais opções: categorias
              final category = categories[index - 1];
              final isSelected = provider.selectedCategory == category.name;

              return _CategoryChip(
                label: category.displayName,
                isSelected: isSelected,
                onTap: () => provider.setCategory(category.name),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4C4C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4C4C) : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4C4C).withAlpha((0.3 * 255).toInt()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}