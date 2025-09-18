import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/recipe_list_screen.dart';
import 'screens/search_online_screen.dart';
import 'screens/add_edit_recipe_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'models/recipe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Recipe App',
            theme: ThemeData(primarySwatch: Colors.teal),
            debugShowCheckedModeBanner: false,
            // Home depends on login state
            home: auth.loggedIn ? const RecipeListScreen() : const LoginScreen(),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/recipes': (_) => const RecipeListScreen(),
              '/search_online': (_) => const SearchOnlineScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/recipe_detail') {
                final recipe = settings.arguments as Recipe;
                return MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(recipe: recipe),
                );
              }
              if (settings.name == '/add_edit') {
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (_) => AddEditRecipeScreen(recipe: args?['recipe']),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
