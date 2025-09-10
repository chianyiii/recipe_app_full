class Recipe {
  int? id;
  String name;
  int typeId;
  String imagePath; // local file path or empty
  String ingredients; // newline-separated
  String steps; // newline-separated

  Recipe({
    this.id,
    required this.name,
    required this.typeId,
    required this.imagePath,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromMap(Map<String, dynamic> m) => Recipe(
    id: m['id'] as int?,
    name: m['name'] as String,
    typeId: m['typeId'] as int,
    imagePath: (m['imagePath'] as String?) ?? '',
    ingredients: (m['ingredients'] as String?) ?? '',
    steps: (m['steps'] as String?) ?? '',
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'typeId': typeId,
    'imagePath': imagePath,
    'ingredients': ingredients,
    'steps': steps,
  };
}
