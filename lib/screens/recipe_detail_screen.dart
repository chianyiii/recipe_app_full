import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe? recipe;
  final Map<String, dynamic>? onlineRecipe;

  const RecipeDetailScreen({Key? key, this.recipe, this.onlineRecipe}) : super(key: key);

  /// Safe image builder
  Widget _buildImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
        color: Colors.grey[200],
        child: const Icon(Icons.restaurant, size: 80),
      );
    } else if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: 220,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 80),
        ),
      );
    } else if (File(imagePath).existsSync()) {
      return Image.file(
        File(imagePath),
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: double.infinity,
        height: 220,
        color: Colors.grey[200],
        child: const Icon(Icons.restaurant, size: 80),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Title
    final String name = recipe?.name ?? onlineRecipe?['title'] ?? 'No title';

    // Image
    final String imagePath = recipe?.imagePath ?? onlineRecipe?['image'] ?? '';

    // Ingredients
    String ingredients = '';
    if (recipe?.ingredients?.isNotEmpty == true) {
      ingredients = recipe!.ingredients;
    } else if (onlineRecipe?['extendedIngredients'] is List) {
      final List list = onlineRecipe!['extendedIngredients'];
      ingredients = list.map((e) => e['original'] ?? '').join('\n');
    }

    // Steps
    String steps = '';
    if (recipe?.steps?.isNotEmpty == true) {
      steps = recipe!.steps;
    } else if (onlineRecipe?['instructions'] is String) {
      steps = onlineRecipe!['instructions'];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: recipe != null
            ? [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/add_edit',
                arguments: {'recipe': recipe},
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text('Are you sure you want to delete this recipe?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true && recipe != null) {
                try {
                  final provider = Provider.of<RecipeProvider>(context, listen: false);
                  await provider.deleteRecipe(recipe!.id!); // delete from DB
                  Navigator.pop(context); // close detail screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recipe deleted successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete recipe: $e')),
                  );
                }
              }
            },
          )

        ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(imagePath),
            const SizedBox(height: 12),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...ingredients
                .split('\n')
                .where((s) => s.trim().isNotEmpty)
                .map((s) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(fontSize: 16)),
                Expanded(child: Text(s.trim(), style: const TextStyle(fontSize: 16))),
              ],
            )),
            const SizedBox(height: 16),
            const Text('Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...steps
                .split('\n')
                .where((s) => s.trim().isNotEmpty)
                .map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(s.trim(), style: const TextStyle(fontSize: 16)),
            )),
          ],
        ),
      ),
    );
  }
}
