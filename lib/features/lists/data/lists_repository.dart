import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/list_detail_data.dart';
import '../../../shared/models/list_item.dart';
import '../../../shared/models/shopping_list.dart';

final listsRepositoryProvider = Provider<ListsRepository>((ref) {
  return ListsRepository(ref.watch(apiClientProvider));
});

class ListsRepository {
  ListsRepository(this._dio);

  final Dio _dio;

  Future<List<ShoppingList>> fetchLists() async {
    final response = await _dio.get<Map<String, dynamic>>('/lists');
    final payload = (response.data?['lists'] as List<dynamic>? ?? const []);
    return payload
        .map((item) => ShoppingList.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ShoppingList> createList({
    required String name,
    required String kind,
    int? month,
    int? year,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/lists',
      data: {
        'list': {
          'name': name,
          'kind': kind,
          'month': month,
          'year': year,
        },
      },
    );

    return ShoppingList.fromJson(response.data?['list'] as Map<String, dynamic>);
  }

  Future<ShoppingList> updateList({
    required int id,
    required String name,
    required String kind,
    int? month,
    int? year,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/lists/$id',
      data: {
        'list': {
          'name': name,
          'kind': kind,
          'month': month,
          'year': year,
        },
      },
    );

    return ShoppingList.fromJson(response.data?['list'] as Map<String, dynamic>);
  }

  Future<void> deleteList(int id) async {
    await _dio.delete<void>('/lists/$id');
  }

  Future<ShoppingList> duplicateList(int id) async {
    final response = await _dio.post<Map<String, dynamic>>('/lists/$id/duplicate');
    return ShoppingList.fromJson(response.data?['list'] as Map<String, dynamic>);
  }

  Future<ListDetailData> fetchListDetail(
    int listId, {
    String? filter,
    String? sort,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/lists/$listId/items',
      queryParameters: {
        if (filter != null && filter != 'all') 'filter': filter,
        if (sort != null && sort != 'default') 'sort': sort,
      },
    );

    final data = response.data ?? const {};
    final itemsPayload = data['items'] as List<dynamic>? ?? const [];
    final filteredTotal = (data['total'] as num?)?.toDouble() ?? 0;

    return ListDetailData(
      list: ShoppingList.fromJson(data['list'] as Map<String, dynamic>),
      items: itemsPayload
          .map((item) => ListItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      filteredTotal: filteredTotal,
    );
  }

  Future<ListDetailData> addItem({
    required int listId,
    required int? productId,
    required String name,
    String? brand,
    required double quantity,
    required double price,
    String? filter,
    String? sort,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/lists/$listId/items',
      data: {
        'item': {
          'product_id': productId,
          'name_snapshot': name,
          'brand_snapshot': brand,
          'quantity': quantity,
          'price': price,
        },
      },
    );

    return _resolveSingleItemMutation(
      listId,
      response.data ?? const {},
      filter: filter,
      sort: sort,
    );
  }

  Future<ListDetailData> updateItem({
    required int listId,
    required int itemId,
    double? quantity,
    double? price,
    bool? purchased,
    String? filter,
    String? sort,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/lists/$listId/items/$itemId',
      data: {
        'item': {
          if (quantity != null) 'quantity': quantity,
          if (price != null) 'price': price,
          if (purchased != null) 'purchased': purchased,
        },
      },
    );

    return _resolveSingleItemMutation(
      listId,
      response.data ?? const {},
      filter: filter,
      sort: sort,
    );
  }

  Future<ListDetailData> togglePurchased({
    required int listId,
    required int itemId,
    String? filter,
    String? sort,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/lists/$listId/items/$itemId/toggle_purchased',
    );

    return _resolveSingleItemMutation(
      listId,
      response.data ?? const {},
      filter: filter,
      sort: sort,
    );
  }

  Future<ListDetailData> updatePrice({
    required int listId,
    required int itemId,
    required double price,
    String? filter,
    String? sort,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/lists/$listId/items/$itemId/update_price',
      data: {'price': price},
    );

    return _resolveSingleItemMutation(
      listId,
      response.data ?? const {},
      filter: filter,
      sort: sort,
    );
  }

  Future<ListDetailData> updateQuantity({
    required int listId,
    required int itemId,
    required double quantity,
    String? filter,
    String? sort,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/lists/$listId/items/$itemId/update_quantity',
      data: {'quantity': quantity},
    );

    return _resolveSingleItemMutation(
      listId,
      response.data ?? const {},
      filter: filter,
      sort: sort,
    );
  }

  Future<void> deleteItem({
    required int listId,
    required int itemId,
  }) async {
    await _dio.delete<void>('/lists/$listId/items/$itemId');
  }

  Future<ShoppingList> removePurchased(int listId) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/lists/$listId/items/remove_purchased',
    );

    return ShoppingList.fromJson(response.data?['list'] as Map<String, dynamic>);
  }

  Future<ListDetailData> _resolveSingleItemMutation(
    int listId,
    Map<String, dynamic> payload,
    {
    String? filter,
    String? sort,
    }
  ) async {
    final list = ShoppingList.fromJson(payload['list'] as Map<String, dynamic>);
    final detail = await fetchListDetail(listId, filter: filter, sort: sort);
    return ListDetailData(
      list: list,
      items: detail.items,
      filteredTotal: detail.filteredTotal,
    );
  }
}
