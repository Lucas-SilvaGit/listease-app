class ListItem {
  const ListItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.brand,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.purchased,
  });

  final int id;
  final int? productId;
  final String name;
  final String? brand;
  final double quantity;
  final double price;
  final double totalPrice;
  final bool purchased;

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'] as int,
      productId: json['product_id'] as int?,
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      purchased: json['purchased'] as bool? ?? false,
    );
  }
}

