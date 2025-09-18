import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/recipe.dart';
import '../models/recipetype.dart';
import '../models/user.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;
  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipe_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, filePath);
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      passwordHash TEXT NOT NULL
    );
    ''');

    await db.execute('''
    CREATE TABLE recipetypes (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL
    );
    ''');

    await db.execute('''
    CREATE TABLE recipes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      typeId INTEGER NOT NULL,
      imagePath TEXT,
      ingredients TEXT,
      steps TEXT,
      FOREIGN KEY (typeId) REFERENCES recipetypes(id)
    );
    ''');

    // Load recipe types asynchronously (doesn't block register/login)
    _loadAndInsertRecipeTypes(db);

    // Insert a couple of sample recipes immediately
    await db.insert('recipes', {
      'name': 'Simple Pancakes',
      'typeId': 3,
      'imagePath': 'pancakes.jpg',
      'ingredients': '2 cups flour\n1.5 cups milk\n2 eggs\n2 tbsp sugar\n2 tsp baking powder',
      'steps': 'Mix dry ingredients\nAdd wet ingredients and stir\nPour batter onto hot pan\nFlip when bubbles form\nServe warm'
    });

    await db.insert('recipes', {
      'name': 'Chicken Noodle Soup',
      'typeId': 2,
      'imagePath': 'chicken_noodle.jpg',
      'ingredients': '1 whole chicken\n200g egg noodles\n2 carrots\n2 celery stalks\n1 onion\nSalt\nPepper',
      'steps': 'Boil chicken to make stock\nAdd chopped vegetables\nAdd noodles and cook\nSeason to taste\nServe hot'
    });

  }

  /// Load recipe types JSON in background
  Future<void> _loadAndInsertRecipeTypes(Database db) async {
    try {
      String jsonStr = await rootBundle.loadString('assets/data/recipetypes.json');
      final List types = json.decode(jsonStr);
      final batch = db.batch();
      for (var t in types) {
        batch.insert('recipetypes', {'id': t['id'], 'name': t['name']});
      }
      await batch.commit(noResult: true);
      print('Recipe types inserted successfully.');
    } catch (e) {
      print('Error loading recipe types: $e');
    }
  }

  // ---------- USER ----------
  Future<int> createUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await instance.database;
    final res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (res.isNotEmpty) return User.fromMap(res.first);
    return null;
  }

  // ---------- RECIPETYPES ----------
  Future<List<RecipeType>> getAllRecipeTypes() async {
    final db = await instance.database;
    final res = await db.query('recipetypes', orderBy: 'id');
    return res.map((r) => RecipeType(id: r['id'] as int, name: r['name'] as String)).toList();
  }

  // ---------- RECIPES ----------
  Future<int> insertRecipe(Recipe recipe) async {
    final db = await instance.database;
    return await db.insert('recipes', recipe.toMap());
  }

  Future<List<Recipe>> getRecipes({int? typeId}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> res;
    if (typeId != null) {
      res = await db.query('recipes',
          where: 'typeId = ?', whereArgs: [typeId], orderBy: 'name');
    } else {
      res = await db.query('recipes', orderBy: 'name');
    }
    return res.map((m) => Recipe.fromMap(m)).toList();
  }

  Future<Recipe?> getRecipeById(int id) async {
    final db = await instance.database;
    final res = await db.query('recipes', where: 'id = ?', whereArgs: [id], limit: 1);
    if (res.isNotEmpty) return Recipe.fromMap(res.first);
    return null;
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await instance.database;
    return await db.update('recipes', recipe.toMap(),
        where: 'id = ?', whereArgs: [recipe.id]);
  }

  Future<int> deleteRecipe(int id) async {
    final db = await instance.database;
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
