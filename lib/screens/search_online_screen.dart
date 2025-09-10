import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/spoonacular_service.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../screens/recipe_detail_screen.dart';
import '../secrets.dart';

class SearchOnlineScreen extends StatefulWidget {
  const SearchOnlineScreen({Key? key}) : super(key: key);

  @override
  State<SearchOnlineScreen> createState() => _SearchOnlineScreenState();
}

class _SearchOnlineScreenState extends State<SearchOnlineScreen> {
  final _controller = TextEditingController();
  late final SpoonacularService _service =
  SpoonacularService(apiKey: Secrets.spoonacularApiKey);

  bool _loading = false;
  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _popular = [];

  @override
  void initState() {
    super.initState();
    _loadPopularRecipes();
  }

  Future<void> _loadPopularRecipes() async {
    try {
      final data = await _service.getRandomRecipes(number: 6);
      setState(() => _popular = data);
    } catch (_) {}
  }

  int mapDishTypeToLocalType(List<String> dishTypes) {
    final types = dishTypes.map((e) => e.toLowerCase()).toList();
    if (types.contains('appetizer')) return 1;
    if (types.contains('rice')) return 2;
    if (types.contains('noodle')) return 3;
    if (types.contains('dessert')) return 4;
    if (types.contains('beverage')) return 5;
    if (types.contains('bread')) return 6;
    if (types.contains('vegetarian')) return 7;
    if (types.contains('gluten free')) return 8;
    if (types.contains('dairy free')) return 9;
    return 0;
  }

  Future<void> _search() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _loading = true);

    try {
      final data =
      await _service.searchRecipes(_controller.text.trim(), number: 10);
      setState(() => _results = data);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveRecipe(Map<String, dynamic> info) async {
    try {
      final provider = Provider.of<RecipeProvider>(context, listen: false);

      // Map Spoonacular dishTypes to local typeId
      final dishTypes = List<String>.from(info['dishTypes'] ?? []);
      int defaultTypeId = mapDishTypeToLocalType(dishTypes);

      // Let user select category
      int? selectedTypeId = await showDialog<int>(
        context: context,
        builder: (ctx) {
          int tempTypeId = defaultTypeId;
          return AlertDialog(
            title: const Text('Select Recipe Category'),
            content: StatefulBuilder(
              builder: (ctx, setState) {
                return DropdownButton<int>(
                  value: tempTypeId,
                  items: List.generate(provider.categories.length, (i) {
                    return DropdownMenuItem(
                      value: i,
                      child: Text(provider.categories[i]),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) setState(() => tempTypeId = val);
                  },
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(tempTypeId),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      // If user cancels, do nothing
      if (selectedTypeId == null) return;

      // Create Recipe object
      final recipe = Recipe(
        name: info['title'] ?? 'No title',
        typeId: selectedTypeId,
        imagePath: info['image'] ?? '',
        ingredients: (info['extendedIngredients'] as List<dynamic>?)
            ?.map((e) => e['original'] ?? '')
            .join('\n') ??
            '',
        steps: info['instructions'] ?? '',
      );

      // Save to local DB
      final id = await provider.addRecipe(recipe);
      recipe.id = id;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved successfully!')),
        );

        // Optionally redirect to detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }



  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final image = recipe['image'] ?? '';
    return GestureDetector(
      onTap: () {
        // Open detail screen for online recipe
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(onlineRecipe: recipe),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: image.startsWith('http')
                    ? Image.network(image, fit: BoxFit.cover)
                    : const Icon(Icons.fastfood, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                recipe['title'] ?? 'No title',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                // Call the _saveRecipe function with category selection
                await _saveRecipe(recipe);
              },
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final showResults = _results.isNotEmpty || _loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Search Online Recipes')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Search recipes...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _search, child: const Text('Search')),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: showResults
                  ? GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: _results.length,
                itemBuilder: (_, i) => _buildRecipeCard(_results[i]),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular Recipes',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _popular.length,
                      itemBuilder: (_, i) => _buildRecipeCard(_popular[i]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
