import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/recipe.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._();
  static Database? _database;

  DatabaseService._();

  factory DatabaseService() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'recipeApp.db');

    return await openDatabase(
      path,
      version: 2, // Update version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        recipeId TEXT UNIQUE,
        name TEXT,
        preparationTime TEXT,
        ingredients TEXT,
        instructions TEXT,
        imageUrl TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE favorites ADD COLUMN imageUrl TEXT
      ''');
    }
  }

  Future<void> saveFavoriteRecipe(
      String userId, Recipe recipe, String imageUrl) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'userId': userId,
        'recipeId': recipe.name,
        'name': recipe.name,
        'preparationTime': recipe.preparation_time,
        'ingredients': recipe.ingredients.join('|'),
        'instructions': recipe.instructions.join('|'),
        'imageUrl': imageUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Recipe>> getFavoriteRecipes(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Recipe(
        name: maps[i]['name'],
        preparation_time: maps[i]['preparationTime'],
        ingredients: maps[i]['ingredients'].split('|'),
        instructions: maps[i]['instructions'].split('|'),
        imageUrl: maps[i]['imageUrl'], // New field
      );
    });
  }

  Future<bool> isFavorite(String userId, String recipeId) async {
    final db = await database;
    final maps = await db.query(
      'favorites',
      where: 'userId = ? AND recipeId = ?',
      whereArgs: [userId, recipeId],
    );
    return maps.isNotEmpty;
  }

  Future<void> removeFavoriteRecipe(String userId, String recipeId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'userId = ? AND recipeId = ?',
      whereArgs: [userId, recipeId],
    );
  }

  Future<void> deleteUserData(String userId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> printAllFavorites() async {
    final db = await database;
    final result = await db.query('favorites');
    print("Contents of the Favorites Table: $result");
  }
}
