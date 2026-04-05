import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/shopping_list.dart';
import '../data/lists_repository.dart';

final listsControllerProvider =
    AsyncNotifierProvider<ListsController, List<ShoppingList>>(
      ListsController.new,
    );

class ListsController extends AsyncNotifier<List<ShoppingList>> {
  ListsRepository get _repository => ref.read(listsRepositoryProvider);

  @override
  Future<List<ShoppingList>> build() => _repository.fetchLists();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.fetchLists);
  }

  Future<void> create({
    required String name,
    required String kind,
    int? month,
    int? year,
  }) async {
    await _repository.createList(name: name, kind: kind, month: month, year: year);
    await refresh();
  }

  Future<void> updateList({
    required int id,
    required String name,
    required String kind,
    int? month,
    int? year,
  }) async {
    await _repository.updateList(
      id: id,
      name: name,
      kind: kind,
      month: month,
      year: year,
    );
    await refresh();
  }

  Future<void> delete(int id) async {
    await _repository.deleteList(id);
    await refresh();
  }

  Future<ShoppingList?> duplicate(int id) async {
    final duplicated = await _repository.duplicateList(id);
    await refresh();
    return duplicated;
  }
}

