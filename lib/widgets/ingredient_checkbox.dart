// lib/widgets/ingredient_checkbox.dart

import 'package:flutter/material.dart';

import '../utils/colors.dart';

class IngredientCheckbox extends StatelessWidget {
  final String ingredient;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const IngredientCheckbox({
    super.key,
    required this.ingredient,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(ingredient),
      value: isSelected,
      activeColor: CustomColors.primaryColor,
      onChanged: onChanged,
    );
  }
}
