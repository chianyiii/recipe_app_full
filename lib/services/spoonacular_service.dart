import 'dart:convert';
import 'package:http/http.dart' as http;

class SpoonacularService {
  final String apiKey;
  SpoonacularService({required this.apiKey});

  Future<List<Map<String, dynamic>>> searchRecipes(String query, {int number = 10}) async {
    final uri = Uri.https('api.spoonacular.com', '/recipes/complexSearch', {
      'query': query,
      'number': number.toString(),
      'apiKey': apiKey,
    });

    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? []);
    } else {
      throw Exception('Failed to fetch from Spoonacular: ${res.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getRecipeInfo(int id) async {
    final uri = Uri.https('api.spoonacular.com', '/recipes/$id/information', {
      'includeNutrition': 'false',
      'apiKey': apiKey,
    });

    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch recipe info: ${res.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getRandomRecipes({int number = 6}) async {
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/random?apiKey=$apiKey&number=$number');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> recipes = data['recipes'] ?? [];
      return List<Map<String, dynamic>>.from(recipes);
    } else {
      throw Exception('Failed to load random recipes');
    }
  }

}
