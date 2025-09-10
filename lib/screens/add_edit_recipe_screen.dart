import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;
  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _ingredientsCtrl;
  late TextEditingController _stepsCtrl;
  String _imagePath = '';
  int? _selectedTypeId; // New: store selected category

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.recipe?.name ?? '');
    _ingredientsCtrl =
        TextEditingController(text: widget.recipe?.ingredients ?? '');
    _stepsCtrl = TextEditingController(text: widget.recipe?.steps ?? '');
    _imagePath = widget.recipe?.imagePath ?? '';
    _selectedTypeId = widget.recipe?.typeId ?? 0; // default to first category
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, width: 120, height: 120, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    } else if (imagePath.isNotEmpty) {
      return Image.file(File(imagePath), width: 120, height: 120, fit: BoxFit.cover);
    } else {
      return Container(
        width: 120,
        height: 120,
        color: Colors.grey[200],
        child: const Icon(Icons.image),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final recipe = Recipe(
      id: widget.recipe?.id,
      name: _nameCtrl.text,
      typeId: _selectedTypeId ?? 1, // Use selected category
      imagePath: _imagePath,
      ingredients: _ingredientsCtrl.text,
      steps: _stepsCtrl.text,
    );
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    if (widget.recipe == null) {
      await provider.addRecipe(recipe);
    } else {
      await provider.updateRecipe(recipe);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final types = context.read<RecipeProvider>().categories; // Get category names

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Add Recipe' : 'Edit Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(child: _buildImage(_imagePath)),
              TextButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text('Pick Image'),
                onPressed: _pickImage,
              ),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter recipe name' : null,
              ),
              const SizedBox(height: 8),
              // Dropdown for category selection
              DropdownButtonFormField<int>(
                value: _selectedTypeId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: List.generate(
                  types.length,
                      (i) => DropdownMenuItem(
                    value: i,
                    child: Text(types[i]),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _selectedTypeId = value);
                },
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ingredientsCtrl,
                decoration: const InputDecoration(labelText: 'Ingredients'),
                maxLines: 4,
              ),
              TextFormField(
                controller: _stepsCtrl,
                decoration: const InputDecoration(labelText: 'Steps'),
                maxLines: 6,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
