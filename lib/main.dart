import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:yummy/screens/registration_screen.dart';
import 'models/recipe_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/personalization/appliances_selection_screen.dart';
import 'screens/personalization/ingredients_selection_screen.dart';
import 'screens/personalization/meal_type_screen.dart';
import 'screens/personalization/ocasion_screen.dart';
import 'screens/personalization/people_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recipe_screen.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const ReceitaApp());
}

class ReceitaApp extends StatelessWidget {
  const ReceitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipePreferences(),
      child: MaterialApp(
        title: 'Yummy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.grey[800],
          hintColor: Colors.greenAccent[400],
          scaffoldBackgroundColor: Colors.grey[200],
          fontFamily: 'Roboto',
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.grey[900]),
            bodyMedium: TextStyle(color: Colors.grey[800]),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/occasion': (context) => const OccasionScreen(),
          '/people': (context) => const PeopleScreen(),
          '/meal_type': (context) => const MealTypeScreen(),
          '/ingredients_selection': (context) =>
              const IngredientsSelectionScreen(),
          '/appliances_selection': (context) =>
              const AppliancesSelectionScreen(),
          '/loading': (context) => const LoadingScreen(),
          '/recipe': (context) => const RecipeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/register': (context) => RegistrationScreen(),
          '/favorites': (context) => const RecipeScreen(),
        },
      ),
    );
  }
}
