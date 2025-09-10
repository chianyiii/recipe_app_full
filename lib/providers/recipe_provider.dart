import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _service = RecipeService();

  List<Recipe> _recipes = [];
  int? _filterTypeId;

  /// New list of categories (string names)
  final List<String> categories = [
    'All',
    'Appetizer',
    'Rice',
    'Noodle',
    'Desserts',
    'Beverages',
    'Breads',
    'Vegetarian',
    'Gluten Free',
    'Dairy Free',
  ];

  List<Recipe> get recipes => _recipes;

  /// Getter for filter type id
  int? get filterTypeId => _filterTypeId;

  /// Setter for filter type id
  set filterTypeId(int? value) {
    _filterTypeId = value;
    loadRecipes(typeId: value); // reload recipes when filter changes
  }

  /// Load recipes optionally filtered by type
  Future<void> loadRecipes({int? typeId}) async {
    _filterTypeId = typeId;
    _recipes = await _service.getRecipes(typeId: typeId == 0 ? null : typeId);
    notifyListeners();
  }

  /// Add a recipe
  Future<int> addRecipe(Recipe r) async {
    final id = await _service.addRecipe(r);
    await loadRecipes(typeId: _filterTypeId);
    return id;
  }

  /// Update a recipe
  Future<void> updateRecipe(Recipe r) async {
    await _service.updateRecipe(r);
    await loadRecipes(typeId: _filterTypeId);
  }

  /// Delete a recipe
  Future<void> deleteRecipe(int id) async {
    await _service.deleteRecipe(id);
    await loadRecipes(typeId: _filterTypeId);
  }

  /// Helper to get category name by typeId
  String getCategoryName(int? typeId) {
    if (typeId == null || typeId == 0) return 'All';
    if (typeId - 1 < 0 || typeId - 1 >= categories.length) return 'Unknown';
    return categories[typeId];
  }
}
