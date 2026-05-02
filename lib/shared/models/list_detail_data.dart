import 'list_item.dart';
import 'shopping_list.dart';

class ListDetailData {
  const ListDetailData({
    required this.list,
    required this.items,
    required this.filteredTotal,
  });

  final ShoppingList list;
  final List<ListItem> items;
  final double filteredTotal;
}
