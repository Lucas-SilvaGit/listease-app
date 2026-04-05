class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.defaultPrice,
  });

  final int id;
  final String name;
  final String? brand;
  final String? category;
  final double? defaultPrice;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      defaultPrice: (json['default_price'] as num?)?.toDouble(),
    );
  }
}

