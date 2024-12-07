import 'package:flutter/foundation.dart';

class RecipePreferences with ChangeNotifier {
  String? occasion;
  int numberOfPeople = 1;
  String? mealType;
  Map<String, Set<String>> selectedIngredients = {};
  Set<String> selectedAppliances = {};
  bool isAnyAppliance = false;

  void updateOccasion(String newOccasion) {
    occasion = newOccasion;
    notifyListeners();
  }

  void updateMealType(String type) {
    mealType = type;
    notifyListeners();
  }

  void updateNumberOfPeople(int people) {
    numberOfPeople = people;
    notifyListeners();
  }

  void updateSelectedIngredients(Map<String, Set<String>> ingredients) {
    selectedIngredients = ingredients;
    notifyListeners();
  }

  void updateSelectedAppliances(Set<String> appliances, bool anyAppliance) {
    selectedAppliances = appliances;
    isAnyAppliance = anyAppliance;
    notifyListeners();
  }

  void resetPreferences() {
    occasion = null;
    numberOfPeople = 1;
    mealType = null;
    selectedIngredients.clear();
    selectedAppliances.clear();
    isAnyAppliance = false;
    notifyListeners();
  }
}
