import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recipe_preferences.dart';
import '../../utils/colors.dart';

class IngredientsSelectionScreen extends StatefulWidget {
  const IngredientsSelectionScreen({super.key});

  @override
  _IngredientsSelectionScreenState createState() =>
      _IngredientsSelectionScreenState();
}

class _IngredientsSelectionScreenState
    extends State<IngredientsSelectionScreen> {
  Map<String, List<String>> ingredients = {
    'Essentials': [
      'Salt',
      'Sugar',
      'Flour',
      'Semolina',
      'Egg',
      'Whole Milk',
      'Olive Oil',
      'Vegetable Oil',
      'Baking Powder',
      'Water',
      'Garlic',
      'Black Pepper',
      'Harissa',
      'White Vinegar',
      'Tomato Paste'
    ],
    'Poultry': [
      'Chicken',
      'Chicken Breast',
      'Chicken Thigh',
      'Chicken Wing',
      'Turkey',
      'Free-Range Chicken'
    ],
    'Meat': [
      'Beef',
      'Ground Beef',
      'Lamb',
      'Veal',
      'Merguez',
      'Sun-dried Meat (Kadid)'
    ],
    'Seafood': [
      'Shrimp',
      'Tuna',
      'Sardines',
      'Octopus',
      'Squid',
      'Sea Bass',
      'Sea Bream',
      'Mussels'
    ],
    'Vegetables': [
      'Tomato',
      'Onion',
      'Potato',
      'Carrot',
      'Green Bell Pepper',
      'Red Bell Pepper',
      'Eggplant',
      'Zucchini',
      'Pumpkin',
      'Chickpeas',
      'Broad Beans',
      'Turnip',
      'Spinach',
      'Parsley',
      'Coriander'
    ],
    'Fruits': [
      'Apple',
      'Orange',
      'Banana',
      'Grapes',
      'Dates',
      'Lemon',
      'Pomegranate',
      'Peach',
      'Apricot',
      'Watermelon',
      'Melon',
      'Fig'
    ],
    'Legumes': ['Lentils', 'Chickpeas', 'Beans', 'Split Peas'],
    'Cereals': ['Couscous', 'Barley', 'White Rice', 'Brown Rice', 'Pasta'],
    'Dairy': [
      'Mozzarella',
      'Ricotta',
      'Butter',
      'Yogurt',
      'Cream Cheese',
      'Fresh Cheese (Jben)',
      'Condensed Milk'
    ],
    'Condiments': [
      'Paprika',
      'Cumin',
      'Coriander Seeds',
      'Turmeric',
      'Dried Oregano',
      'Fresh Mint',
      'Bay Leaves',
      'Ras El Hanout',
      'Ketchup',
      'Mustard'
    ],
    'Nuts and Seeds': [
      'Almonds',
      'Hazelnuts',
      'Pistachios',
      'Sesame Seeds',
      'Flax Seeds',
      'Pumpkin Seeds'
    ],
    'Sweets': [
      'Honey',
      'Dark Chocolate',
      'Milk Chocolate',
      'Dried Figs',
      'Dried Apricots',
      'Halva',
      'Loukoum'
    ],
    'Others': [
      'Chicken Stock',
      'Beef Stock',
      'Fish Stock',
      'Soy Sauce',
      'Rose Water',
      'Orange Blossom Water',
      'Coffee',
      'Green Tea',
      'Black Tea',
      'Harissa Paste'
    ]
  };

  Map<String, Set<String>> selectedIngredients = {};

  Widget _buildIngredientButton(String category, String ingredient) {
    bool isSelected =
        selectedIngredients[category]?.contains(ingredient) ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedIngredients[category]?.remove(ingredient);
          } else {
            selectedIngredients
                .putIfAbsent(category, () => <String>{})
                .add(ingredient);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? CustomColors.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  isSelected ? CustomColors.primaryColor : Colors.grey[400]!),
        ),
        child: Text(
          ingredient,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          children: ingredients[category]!
              .map((ingredient) => _buildIngredientButton(category, ingredient))
              .toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'What Ingredients yo you have?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: ingredients.keys.map((category) {
              return _buildCategory(category);
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor:
                  selectedIngredients.values.any((set) => set.isNotEmpty)
                      ? CustomColors.primaryColor
                      : Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 15),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: selectedIngredients.values.any((set) => set.isNotEmpty)
                ? () {
                    // Save selections in RecipePreferences and navigate to the next screen
                    Provider.of<RecipePreferences>(context, listen: false)
                        .updateSelectedIngredients(selectedIngredients);

                    Navigator.pushNamed(context, '/appliances_selection');
                  }
                : null,
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ingredients',
          style: TextStyle(color: Colors.grey[800]),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(child: _buildContent()),
    );
  }
}
