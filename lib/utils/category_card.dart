import 'package:flutter/material.dart';
import 'package:narrative/models/user_preference_model.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final String displayName;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    required this.category,
    required this.displayName,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case NewsCategories.business:
        return Icons.business;
      case NewsCategories.entertainment:
        return Icons.movie;
      case NewsCategories.health:
        return Icons.health_and_safety;
      case NewsCategories.science:
        return Icons.science;
      case NewsCategories.sports:
        return Icons.sports_soccer;
      case NewsCategories.technology:
        return Icons.computer;
      default:
        return Icons.newspaper;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 40,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(height: 8),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}