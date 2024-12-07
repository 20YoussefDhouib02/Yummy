// lib/screens/loading_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../models/recipe_preferences.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ApiService _apiService;
  bool _hasError = false; // Definindo a variável _hasError

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _apiService = ApiService(dotenv.env['API_KEY_RECIPE']!);

    _fetchRecipe();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchRecipe() async {
    final prefs = Provider.of<RecipePreferences>(context, listen: false);

    print('Meal Type no LoadingScreen: ${prefs.mealType}');

    Map<String, dynamic> requestData = {
      'occasion': prefs.occasion,
      'numberOfPeople': prefs.numberOfPeople,
      'mealType': prefs.mealType,
      'ingredients':
          prefs.selectedIngredients.values.expand((set) => set).toList(),
      'appliances':
          prefs.isAnyAppliance ? [] : prefs.selectedAppliances.toList(),
    };

    Recipe? recipe = await _apiService.fetchRecipe(requestData);

    if (recipe != null) {
      Navigator.pushReplacementNamed(context, '/recipe', arguments: recipe);
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  Widget _buildAnimation() {
    return Center(
      child: CustomPaint(
        size: const Size(100, 100),
        painter: LoadingPainter(_animationController),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 30),
          const Text(
            'Oops! Something went wrong.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'We were unable to generate your revenue. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false; // Reseta o estado para tentar novamente
              });
              _fetchRecipe();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: CustomColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Try again',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimation(),
          const SizedBox(height: 30),
          const Text(
            'We are preparing your recipe...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.primaryColor,
      body: _buildContent(),
    );
  }
}

class LoadingPainter extends CustomPainter {
  final Animation<double> animation;

  LoadingPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * animation.value;

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(center, radius * (1 - i * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
