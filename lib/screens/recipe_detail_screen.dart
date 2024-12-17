import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isFavorite = false;
  String? recipeImageUrl;
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  String? userId;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
  }

  void _loadRecipeData() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      userId = user.uid;
      isFavorite = await _dbService.isFavorite(userId!, widget.recipe.name);

      if (isFavorite) {
        final favoriteRecipes = await _dbService.getFavoriteRecipes(userId!);
        final favoriteRecipe =
            favoriteRecipes.firstWhere((r) => r.name == widget.recipe.name);
        setState(() {
          recipeImageUrl = favoriteRecipe.imageUrl;
        });
      } else {
        _fetchAndSetImage(widget.recipe.name);
      }
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
        await _dbService.saveFavoriteRecipe(userId!, widget.recipe, imageUrl!);
      }
    } catch (e) {
      print("Error when searching for image: $e");
      setState(() {
        recipeImageUrl = 'assets/replace.png';
      });
    }
  }

  void toggleFavorite() async {
    if (userId == null) return;

    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      await _dbService.saveFavoriteRecipe(
          userId!, widget.recipe, recipeImageUrl!);
    } else {
      await _dbService.removeFavoriteRecipe(userId!, widget.recipe.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      _buildDetailsTab(widget.recipe),
      _buildIngredientsTab(widget.recipe),
      _buildInstructionsTab(widget.recipe),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.6,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 10),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 36,
                          ),
                          color: Colors.black87,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          widget.recipe.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (recipeImageUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              recipeImageUrl!,
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                            ),
                          ),
                        ),
                    ],
                  ),
                  expandedHeight: 320,
                  toolbarHeight: 20,
                  collapsedHeight: 20,
                ),
                SliverFillRemaining(
                  child: Column(
                    children: [
                      _buildTabBar(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: tabs[_selectedTab],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabButton('Details', 0),
        _buildTabButton('Ingredients', 1),
        _buildTabButton('Preparation', 2),
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
            Icons.timer, 'Preparation time:', recipe.preparation_time),
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
            child: Text(
              '${entry.key + 1}',
              style: const TextStyle(
                color: CustomColors.backgroundColor,
              ),
            ),
          ),
          title: Text(entry.value),
        );
      }).toList(),
    );
  }
}
