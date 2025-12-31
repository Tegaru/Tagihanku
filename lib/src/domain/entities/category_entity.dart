class CategoryEntity {
  const CategoryEntity({
    this.id,
    required this.name,
    this.colorHex,
  });

  final int? id;
  final String name;
  final String? colorHex;
}
