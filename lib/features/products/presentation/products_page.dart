import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/product.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/navigation_frame.dart';
import 'product_categories.dart';
import 'products_controller.dart';
import 'widgets/product_form_sheet.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsControllerProvider);

    ref.listen(productsControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return NavigationFrame(
      title: 'Produtos',
      currentLocation: '/products',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo produto'),
      ),
      child: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado ainda.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(productsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      [
                        if (product.brand != null && product.brand!.isNotEmpty) product.brand,
                        if (product.category != null && product.category!.isNotEmpty) product.category,
                      ].whereType<String>().join(' • ').ifEmpty('Sem detalhes'),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _showProductForm(context, ref, initialProduct: product);
                            break;
                          case 'delete':
                            ref.read(productsControllerProvider.notifier).delete(product.id);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (product.defaultPrice != null)
                          PopupMenuItem<String>(
                            enabled: false,
                            child: Text(formatCurrency(product.defaultPrice!)),
                          ),
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _showProductForm(
    BuildContext context,
    WidgetRef ref, {
    Product? initialProduct,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final categories = {
          ...defaultProductCategories,
          ...ref
              .read(productsControllerProvider)
              .valueOrNull
              ?.map((product) => product.category)
              .whereType<String>()
              .where((category) => category.trim().isNotEmpty) ??
              const <String>[],
        }.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        return ProductFormSheet(
          initialProduct: initialProduct,
          availableCategories: categories,
          onSubmit: ({
            required String name,
            String? brand,
            required String category,
            required double defaultPrice,
          }) {
            if (initialProduct == null) {
              return ref.read(productsControllerProvider.notifier).create(
                    name: name,
                    brand: brand,
                    category: category,
                    defaultPrice: defaultPrice,
                  );
            }

            return ref.read(productsControllerProvider.notifier).updateProduct(
                  id: initialProduct.id,
                  name: name,
                  brand: brand,
                  category: category,
                  defaultPrice: defaultPrice,
                );
          },
        );
      },
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
