import '../services/app_database.dart';
import '../models/recipe.dart';
import '../models/recipetype.dart';

class RecipeService {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<RecipeType>> getTypes() => _db.getAllRecipeTypes();
  Future<List<Recipe>> getRecipes({int? typeId}) => _db.getRecipes(typeId: typeId);
  Future<Recipe?> getById(int id) => _db.getRecipeById(id);
  Future<int> addRecipe(Recipe r) => _db.insertRecipe(r);
  Future<int> updateRecipe(Recipe r) => _db.updateRecipe(r);
  Future<int> deleteRecipe(int id) => _db.deleteRecipe(id);
}
