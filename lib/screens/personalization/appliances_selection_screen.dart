// lib/screens/personalization/appliances_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe_preferences.dart';
import '../../utils/colors.dart';

class AppliancesSelectionScreen extends StatefulWidget {
  const AppliancesSelectionScreen({super.key});

  @override
  _AppliancesSelectionScreenState createState() =>
      _AppliancesSelectionScreenState();
}

class _AppliancesSelectionScreenState extends State<AppliancesSelectionScreen> {
  List<String> appliances = [
    'Blender',
    'Airfryer',
    'Electric Oven',
    'Mixer',
    'Microwave',
    'Pressure Cooker',
    'Stove',
    'Food Processor',
    'Sandwich Maker',
    'Grill',
  ];

  Set<String> selectedAppliances = <String>{};
  bool isAnyAppliance = false;

  Widget _buildApplianceButton(String appliance) {
    bool isSelected = selectedAppliances.contains(appliance);

    return GestureDetector(
      onTap: isAnyAppliance
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  selectedAppliances.remove(appliance);
                } else {
                  selectedAppliances.add(appliance);
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
            color: isSelected ? CustomColors.primaryColor : Colors.grey[400]!,
          ),
        ),
        child: Text(
          appliance,
          style: TextStyle(
            color: isSelected ? Colors.white : CustomColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnyOption() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isAnyAppliance = !isAnyAppliance;
          if (isAnyAppliance) {
            selectedAppliances.clear();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(right: 8, bottom: 20),
        decoration: BoxDecoration(
          color: isAnyAppliance ? CustomColors.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isAnyAppliance ? CustomColors.primaryColor : Colors.grey[400]!,
          ),
        ),
        child: Text(
          'Any Appliance',
          style: TextStyle(
            color: isAnyAppliance ? Colors.white : CustomColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'What are your available appliances?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildAnyOption(),
        Expanded(
          child: Wrap(
            children: appliances.map((appliance) {
              return _buildApplianceButton(appliance);
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: selectedAppliances.isNotEmpty || isAnyAppliance
                  ? CustomColors.primaryColor
                  : Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 15),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: selectedAppliances.isNotEmpty || isAnyAppliance
                ? () {
                    // Save the selections in RecipePreferences
                    Provider.of<RecipePreferences>(context, listen: false)
                        .updateSelectedAppliances(
                            selectedAppliances, isAnyAppliance);

                    // Navigate to the loading screen
                    Navigator.pushNamed(context, '/loading');
                  }
                : null,
            child: const Text(
              'Search Recipe!',
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
          'Appliances',
          style: TextStyle(color: CustomColors.textColor),
        ),
        backgroundColor: Color.fromRGBO(255, 134, 64, 0.85),
        elevation: 0,
        iconTheme: IconThemeData(color: CustomColors.textColor),
      ),
      backgroundColor: Colors.grey[200],
      body: _buildContent(),
    );
  }
}
