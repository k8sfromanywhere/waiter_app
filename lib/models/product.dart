class Product {
  final int id;
  final String name;
  final int categoryId;
  final String imageName;

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.imageName,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      categoryId: map['category_id'],
      imageName: map['image_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'image_name': imageName,
    };
  }
}
