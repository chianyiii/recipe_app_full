import '../models/recipe.dart';

/// Helper to strip HTML tags from Spoonacular instructions.
String stripHtml(String htmlText) {
  final exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
  return htmlText.replaceAll(exp, "").trim();
}

/// Map Spoonacular dish types to your local recipe type IDs.
int mapDishTypeToLocal(List<dynamic>? dishTypes) {
  if (dishTypes == null) return 0; // Unknown or All

  final lowerTypes = dishTypes.map((e) => e.toString().toLowerCase()).toList();

  if (lowerTypes.contains('dessert')) return 4;
  if (lowerTypes.contains('beverage')) return 5;
  if (lowerTypes.contains('bread')) return 6;
  if (lowerTypes.contains('appetizer')) return 1;
  if (lowerTypes.contains('main course') || lowerTypes.contains('rice')) return 2;
  if (lowerTypes.contains('noodle')) return 3;
  if (lowerTypes.contains('vegetarian')) return 7;
  if (lowerTypes.contains('gluten free')) return 8;
  if (lowerTypes.contains('dairy free')) return 9;

  return 0; // fallback
}

extension SpoonacularMapper on Map<String, dynamic> {
  Recipe toRecipe({int? localTypeId}) {
    // Use the mapping function if localTypeId not provided
    final typeId = localTypeId ?? mapDishTypeToLocal(this['dishTypes'] as List?);

    final ingredients = (this['extendedIngredients'] as List?)
        ?.map((e) => e['original']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .join('\n') ??
        '';

    final stepsRaw = (this['instructions'] as String?) ?? '';
    final steps = stripHtml(stepsRaw);

    return Recipe(
      name: this['title'] ?? 'Untitled Recipe',
      typeId: typeId,
      imagePath: this['image'] ?? '', // Can be local file or URL
      ingredients: ingredients,
      steps: steps.isNotEmpty ? steps : 'No steps provided.',
    );
  }
}
