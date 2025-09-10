class RecipeType {
  final int id;
  final String name;
  RecipeType({required this.id, required this.name});
  factory RecipeType.fromJson(Map<String, dynamic> j) =>
      RecipeType(id: j['id'] as int, name: j['name'] as String);
  Map<String, dynamic> toMap() => {'id': id, 'name': name};
}
