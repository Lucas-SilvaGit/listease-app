class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.name,
    required this.kind,
    required this.month,
    required this.year,
    required this.itemsCount,
    required this.purchasedCount,
    required this.totalAmount,
    required this.progress,
  });

  final int id;
  final String name;
  final String kind;
  final int? month;
  final int? year;
  final int itemsCount;
  final int purchasedCount;
  final double totalAmount;
  final double progress;

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      kind: json['kind'] as String? ?? 'free',
      month: json['month'] as int?,
      year: json['year'] as int?,
      itemsCount: json['items_count'] as int? ?? 0,
      purchasedCount: json['purchased_count'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
    );
  }
}

