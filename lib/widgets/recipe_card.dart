import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  RecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: recipe.imagePath.isNotEmpty
          ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(File(recipe.imagePath), width: 56, height: 56, fit: BoxFit.cover))
          : Container(width: 56, height: 56, alignment: Alignment.center, child: Icon(Icons.restaurant)),
      title: Text(recipe.name),
      subtitle: Text('Type: ${recipe.typeId}'),
      onTap: onTap,
    );
  }
}
