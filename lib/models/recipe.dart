// lib/models/recipe.dart

class Recipe {
  final String name;
  final String preparation_time;
  final List<String> ingredients;
  final List<String> instructions;
  final String? imageUrl;

  Recipe(
      {required this.name,
      required this.preparation_time,
      required this.ingredients,
      required this.instructions,
      this.imageUrl});

  // Convert a JSON map into a Recipe object
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'],
      preparation_time: json['preparation_time'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
    );
  }

  // Converts a Recipe object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'preparationTime': preparation_time,
      'ingredients': ingredients,
      'instructions': instructions,
    };
  }
}
