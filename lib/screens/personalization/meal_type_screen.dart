import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe_preferences.dart';
import '../../utils/colors.dart';

class MealTypeScreen extends StatefulWidget {
  const MealTypeScreen({super.key});

  @override
  _MealTypeScreenState createState() => _MealTypeScreenState();
}

class _MealTypeScreenState extends State<MealTypeScreen> {
  String? selectedMealType;

  final List<Map<String, String>> mealTypes = [
    {'title': 'Family', 'icon': 'assets/icons/family.png'},
    {'title': 'Romantic Date', 'icon': 'assets/icons/date.png'},
    {'title': 'Friends', 'icon': 'assets/icons/friends.png'},
  ];

  Widget _buildMealTypeCard(Map<String, String> mealType) {
    bool isSelected = selectedMealType == mealType['title'];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMealType = mealType['title'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 246, 220, 185)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? CustomColors.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              mealType['icon']!,
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 20),
            Text(
              mealType['title']!,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Text(
          'What is the meal type?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: mealTypes.length,
            itemBuilder: (context, index) {
              return _buildMealTypeCard(mealTypes[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: selectedMealType != null
                  ? CustomColors.primaryColor
                  : Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 15),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: selectedMealType != null
                ? () {
                    Provider.of<RecipePreferences>(context, listen: false)
                        .updateMealType(selectedMealType!);

                    print('Selected Meal Type: ${selectedMealType!}');

                    Navigator.pushNamed(context, '/ingredients_selection');
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
          'Meal',
          style: TextStyle(color: Colors.grey[800]),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      backgroundColor: Colors.grey[200],
      body: _buildContent(),
    );
  }
}
