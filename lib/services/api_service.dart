import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/recipe.dart';

class ApiService {
  final GenerativeModel model;

  ApiService(String apiKey)
      : model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
        );

  Future<Recipe?> fetchRecipe(Map<String, dynamic> requestData) async {
    try {
      String prompt = _buildPrompt(requestData);

      print("Sending request to API with the prompt:\n$prompt");

      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        print('Error: empty or null response');
        return null;
      }

      String recipeText = response.text!.trim();
      print("Generated recipe:\n$recipeText");

      // Extracts JSON from the response
      recipeText = _extractJsonFromResponse(recipeText);

      // Checks if the JSON is not empty
      if (recipeText.isEmpty || recipeText == '{}') {
        print('Error: empty JSON returned by the API.');
        return null;
      }

      // Tries to decode the JSON
      try {
        final recipeData = jsonDecode(recipeText) as Map<String, dynamic>;
        return Recipe.fromJson(recipeData);
      } catch (e) {
        print("Error decoding JSON: $e");
        if (kDebugMode) {
          print("Received JSON: \n($recipeText)");
        }
        return null;
      }
    } catch (e) {
      print('Exception while calling the Gemini API: $e');
      return null;
    }
  }

  String _buildPrompt(Map<String, dynamic> requestData) {
    final ingredientsList = requestData['ingredients'] ?? [];
    final peopleCount = requestData['numberOfPeople'] ?? 1;
    final occasion = requestData['occasion'] ?? 'a common dish';
    final appliancesList = requestData['appliances'] ?? [];
    final appliances = appliancesList.isNotEmpty
        ? appliancesList.join(', ')
        : 'no specific appliances';

    String ingredientsPrompt;

    if (ingredientsList.isEmpty) {
      ingredientsPrompt = 'using common ingredients available at home';
    } else {
      ingredientsPrompt =
          'with the following ingredients: ${ingredientsList.join(', ')}';
    }

    return '''
Please suggest a recipe considering only the listed available ingredients in $ingredientsPrompt.It’s not necessary to use all of them, just choose those that pair the most based on your knowledge and create a realistic and suitable recipe.
The recipe name should be descriptive enough to clearly identify the suggested dish and suitable for a $occasion. Use precise measurements, preferably in grams or milliliters. 
Make sure that the recipe can be prepared with the available appliances, which are: $appliances.
Format the response ONLY in JSON, without code blocks or additional text, in the following format:
{
  "name": "Recipe Name",
  "preparation_time": "Preparation Time",
  "ingredients": ["ingredient 1", "ingredient 2", ...],
  "instructions": ["step 1", "step 2", ...]
}
''';
  }

  String _extractJsonFromResponse(String response) {
    response =
        response.replaceAll(RegExp(r'^```(\w+)?\n', multiLine: true), '');
    response = response.replaceAll('```', '');
    final start = response.indexOf('{');
    final end = response.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return response.substring(start, end + 1);
    } else {
      return '';
    }
  }
}
