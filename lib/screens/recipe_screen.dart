import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/recipe.dart';
import '../models/recipe_preferences.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  bool isFavorite = false;
  String? recipeImageUrl;
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  String? userId;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipeData();
    });
  }

  void _loadRecipeData() async {
    final Recipe recipe = ModalRoute.of(context)!.settings.arguments as Recipe;

    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        userId = user.uid;
        _dbService.isFavorite(userId!, recipe.name).then((value) async {
          setState(() {
            isFavorite = value;
          });
          if (value) {
            final favoriteRecipes =
                await _dbService.getFavoriteRecipes(userId!);
            final favoriteRecipe =
                favoriteRecipes.firstWhere((r) => r.name == recipe.name);
            setState(() {
              recipeImageUrl = favoriteRecipe.imageUrl;
            });
          } else {
            _fetchAndSetImage(recipe.name);
          }
        });
      });
    } else {
      print("Error: user not authenticated");
    }
  }

  void _fetchAndSetImage(String recipeName) async {
    try {
      String? imageUrl = await ImageService().fetchImage(recipeName);
      setState(() {
        recipeImageUrl = imageUrl;
      });

      if (isFavorite && userId != null) {
        final Recipe recipe =
            ModalRoute.of(context)!.settings.arguments as Recipe;
        await _dbService.saveFavoriteRecipe(userId!, recipe, imageUrl!);
      }
    } catch (e) {
      print("Error when searching for image: $e");
      setState(() {
        recipeImageUrl = 'assets/replace.png';
      });
    }
  }

  void toggleFavorite() async {
    if (userId == null) {
      print("Error: user not authenticated");
      return;
    }

    setState(() {
      isFavorite = !isFavorite;
    });

    final Recipe recipe = ModalRoute.of(context)!.settings.arguments as Recipe;
    if (isFavorite) {
      await _dbService.saveFavoriteRecipe(userId!, recipe, recipeImageUrl!);
    } else {
      await _dbService.removeFavoriteRecipe(userId!, recipe.name);
    }
  }

  void shareRecipe() {
    final Recipe recipe = ModalRoute.of(context)!.settings.arguments as Recipe;
    final String recipeText = '''
${recipe.name}

Preparation time: ${recipe.preparation_time}

Ingredients:
${recipe.ingredients.join('\n')}

Preparation method:
${recipe.instructions.join('\n')}
''';
    Share.share(recipeText);
  }

  void _showRegeneratePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'A New Recipe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Do you want to generate a new recipe with the same ingredients or select new ones?',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          contentPadding: const EdgeInsets.all(20),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Provider.of<RecipePreferences>(context, listen: false)
                        .resetPreferences();
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/meal_type', (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: CustomColors.primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  ),
                  child: const Text(
                    'New Ingredients',
                    style: TextStyle(
                      color: CustomColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/loading');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                  ),
                  child: const Text(
                    'Same Ingredients',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _navigateToProfile() {
    if (isFavorite) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Favorite Recipe',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'You\'ve favorited this recipe and can leave without worrying about losing it!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            contentPadding: const EdgeInsets.all(20),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: const Text(
                  'Go to Profile',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Unfavorite Recipe',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'You didn\'t favorite the recipe and will lose it if you leave. Are you sure you want to leave?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            contentPadding: const EdgeInsets.all(20),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: CustomColors.primaryColor,
                  side: const BorderSide(
                      color: CustomColors.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: const Text(
                  'No',
                  style: TextStyle(
                    color: CustomColors.backgroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.backgroundColor,
                  side: const BorderSide(
                      color: CustomColors.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(color: CustomColors.primaryColor),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Recipe recipe = ModalRoute.of(context)!.settings.arguments as Recipe;

    List<Widget> tabs = [
      _buildDetailsTab(recipe),
      _buildIngredientsTab(recipe),
      _buildInstructionsTab(recipe),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yummy',
          style: TextStyle(color: CustomColors.textColor),
        ),
        backgroundColor: Color.fromRGBO(255, 134, 64, 0.85),
        elevation: 0,
        iconTheme: IconThemeData(color: CustomColors.textColor),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: const Color.fromARGB(255, 255, 0, 0),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: shareRecipe,
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            if (recipeImageUrl != null) const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                recipeImageUrl!,
                fit: BoxFit.cover,
                height: 150,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              recipe.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTabBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: tabs[_selectedTab],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: CustomColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _showRegeneratePopup,
                      child: const Text(
                        'A New Recipe',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: CustomColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _navigateToProfile,
                      child: const Text(
                        'Go to profile',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabButton('Detail', 0),
        _buildTabButton('Ingredients', 1),
        _buildTabButton('Prepare', 2),
      ],
    );
  }

  Widget _buildTabButton(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: _selectedTab == index
                ? const Color.fromARGB(255, 246, 220, 185).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: _selectedTab == index
                ? Border.all(color: CustomColors.primaryColor, width: 1.5)
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _selectedTab == index
                  ? CustomColors.primaryColor
                  : CustomColors.textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildInfoRow(
            Icons.timer, 'Preparation Time: ', recipe.preparation_time),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: CustomColors.primaryColor),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(Recipe recipe) {
    return ListView(
      children: recipe.ingredients.map((ingredient) {
        return ListTile(
          leading: const Icon(Icons.circle, color: CustomColors.primaryColor),
          title: Text(ingredient),
        );
      }).toList(),
    );
  }

  Widget _buildInstructionsTab(Recipe recipe) {
    return ListView(
      children: recipe.instructions.asMap().entries.map((entry) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: CustomColors.primaryColor,
            foregroundColor: Colors.white,
            child: Text('${entry.key + 1}'),
          ),
          title: Text(entry.value),
        );
      }).toList(),
    );
  }
}
