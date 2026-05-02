import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/list_detail_data.dart';
import '../data/lists_repository.dart';

final listDetailControllerProvider = AsyncNotifierProvider.family<
    ListDetailController, ListDetailState, int>(ListDetailController.new);

class ListDetailState {
  const ListDetailState({
    required this.data,
    required this.filter,
    required this.sort,
  });

  final ListDetailData data;
  final String filter;
  final String sort;

  ListDetailState copyWith({
    ListDetailData? data,
    String? filter,
    String? sort,
  }) {
    return ListDetailState(
      data: data ?? this.data,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
    );
  }
}

class ListDetailController extends FamilyAsyncNotifier<ListDetailState, int> {
  late final int _listId;

  ListsRepository get _repository => ref.read(listsRepositoryProvider);

  @override
  Future<ListDetailState> build(int arg) async {
    _listId = arg;
    final detail = await _repository.fetchListDetail(_listId);
    return ListDetailState(data: detail, filter: 'all', sort: 'default');
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    if (current == null) {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() => build(_listId));
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final detail = await _repository.fetchListDetail(
        _listId,
        filter: current.filter,
        sort: current.sort,
      );
      return current.copyWith(data: detail);
    });
  }

  Future<void> changeFilter(String filter) async {
    final current = state.requireValue;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final detail = await _repository.fetchListDetail(
        _listId,
        filter: filter,
        sort: current.sort,
      );
      return current.copyWith(data: detail, filter: filter);
    });
  }

  Future<void> changeSort(String sort) async {
    final current = state.requireValue;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final detail = await _repository.fetchListDetail(
        _listId,
        filter: current.filter,
        sort: sort,
      );
      return current.copyWith(data: detail, sort: sort);
    });
  }

  Future<void> addItem({
    required int? productId,
    required String name,
    String? brand,
    required double quantity,
    required double price,
  }) async {
    final current = state.requireValue;
    final detail = await _repository.addItem(
      listId: _listId,
      productId: productId,
      name: name,
      brand: brand,
      quantity: quantity,
      price: price,
      filter: current.filter,
      sort: current.sort,
    );
    state = AsyncData(current.copyWith(data: detail));
  }

  Future<void> togglePurchased(int itemId) async {
    final current = state.requireValue;
    final detail = await _repository.togglePurchased(
      listId: _listId,
      itemId: itemId,
      filter: current.filter,
      sort: current.sort,
    );
    state = AsyncData(current.copyWith(data: detail));
  }

  Future<void> updatePrice(int itemId, double price) async {
    final current = state.requireValue;
    final detail = await _repository.updatePrice(
      listId: _listId,
      itemId: itemId,
      price: price,
      filter: current.filter,
      sort: current.sort,
    );
    state = AsyncData(current.copyWith(data: detail));
  }

  Future<void> updateQuantity(int itemId, double quantity) async {
    final current = state.requireValue;
    final detail = await _repository.updateQuantity(
      listId: _listId,
      itemId: itemId,
      quantity: quantity,
      filter: current.filter,
      sort: current.sort,
    );
    state = AsyncData(current.copyWith(data: detail));
  }

  Future<void> removePurchased() async {
    await _repository.removePurchased(_listId);
    await refresh();
  }

  Future<void> deleteItem(int itemId) async {
    await _repository.deleteItem(listId: _listId, itemId: itemId);
    await refresh();
  }
}
