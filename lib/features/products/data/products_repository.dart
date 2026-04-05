import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/product.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(ref.watch(apiClientProvider));
});

class ProductsRepository {
  ProductsRepository(this._dio);

  final Dio _dio;

  Future<List<Product>> fetchProducts() async {
    final response = await _dio.get<Map<String, dynamic>>('/products');
    final payload = (response.data?['products'] as List<dynamic>? ?? const []);
    return payload
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/products/search',
      queryParameters: {'q': query},
    );
    final payload = (response.data?['products'] as List<dynamic>? ?? const []);
    return payload
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> createProduct({
    required String name,
    String? brand,
    required String category,
    required double defaultPrice,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/products',
      data: {
        'product': {
          'name': name,
          'brand': brand,
          'category': category,
          'default_price': defaultPrice,
        },
      },
    );

    return Product.fromJson(response.data?['product'] as Map<String, dynamic>);
  }

  Future<Product> updateProduct({
    required int id,
    required String name,
    String? brand,
    required String category,
    required double defaultPrice,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/products/$id',
      data: {
        'product': {
          'name': name,
          'brand': brand,
          'category': category,
          'default_price': defaultPrice,
        },
      },
    );

    return Product.fromJson(response.data?['product'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    await _dio.delete<void>('/products/$id');
  }
}
