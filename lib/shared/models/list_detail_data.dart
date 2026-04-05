import 'list_item.dart';
import 'shopping_list.dart';

class ListDetailData {
  const ListDetailData({
    required this.list,
    required this.items,
  });

  final ShoppingList list;
  final List<ListItem> items;
}

