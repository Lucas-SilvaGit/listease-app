import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/product.dart';
import '../data/products_repository.dart';

final productsControllerProvider =
    AsyncNotifierProvider<ProductsController, List<Product>>(
      ProductsController.new,
    );

class ProductsController extends AsyncNotifier<List<Product>> {
  ProductsRepository get _repository => ref.read(productsRepositoryProvider);

  @override
  Future<List<Product>> build() => _repository.fetchProducts();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.fetchProducts);
  }

  Future<Product> create({
    required String name,
    String? brand,
    required String category,
    required double defaultPrice,
  }) async {
    final product = await _repository.createProduct(
      name: name,
      brand: brand,
      category: category,
      defaultPrice: defaultPrice,
    );
    await refresh();
    return product;
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    String? brand,
    required String category,
    required double defaultPrice,
  }) async {
    await _repository.updateProduct(
      id: id,
      name: name,
      brand: brand,
      category: category,
      defaultPrice: defaultPrice,
    );
    await refresh();
  }

  Future<void> delete(int id) async {
    await _repository.deleteProduct(id);
    await refresh();
  }
}
