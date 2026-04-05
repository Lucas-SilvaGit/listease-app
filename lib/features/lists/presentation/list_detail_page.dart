import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/formatters.dart';
import 'list_detail_controller.dart';
import 'widgets/add_item_sheet.dart';
import 'widgets/list_item_tile.dart';

class ListDetailPage extends ConsumerWidget {
  const ListDetailPage({
    super.key,
    required this.listId,
  });

  final int listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(listDetailControllerProvider(listId));
    final controller = ref.read(listDetailControllerProvider(listId).notifier);

    ref.listen(listDetailControllerProvider(listId), (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo compra'),
        actions: [
          IconButton(
            onPressed: detailAsync.isLoading ? null : controller.removePurchased,
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) => AddItemSheet(
            onSubmit: ({
              required int? productId,
              required String name,
              String? brand,
              required double quantity,
              required double price,
            }) {
              return controller.addItem(
                productId: productId,
                name: name,
                brand: brand,
                quantity: quantity,
                price: price,
              );
            },
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar item'),
      ),
      body: SafeArea(
        child: detailAsync.when(
          data: (state) {
            final list = state.data.list;
            final items = state.data.items;

            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${list.purchasedCount} de ${list.itemsCount} comprados',
                          style: const TextStyle(color: Color(0xFF697284)),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryMetric(
                                label: 'Total',
                                value: formatCurrency(list.totalAmount),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryMetric(
                                label: 'Progresso',
                                value: '${(list.progress * 100).round()}%',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        LinearProgressIndicator(
                          value: list.progress,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor: const Color(0xFFF0F3F8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Todos'),
                        selected: state.filter == 'all',
                        onSelected: (_) => controller.changeFilter('all'),
                      ),
                      ChoiceChip(
                        label: const Text('Faltantes'),
                        selected: state.filter == 'pending',
                        onSelected: (_) => controller.changeFilter('pending'),
                      ),
                      ChoiceChip(
                        label: const Text('Comprados'),
                        selected: state.filter == 'purchased',
                        onSelected: (_) => controller.changeFilter('purchased'),
                      ),
                      PopupMenuButton<String>(
                        onSelected: controller.changeSort,
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'default', child: Text('Mais recentes')),
                          PopupMenuItem(value: 'name', child: Text('Ordem alfabética')),
                          PopupMenuItem(value: 'category', child: Text('Categoria')),
                          PopupMenuItem(value: 'highest_price', child: Text('Maior preço')),
                          PopupMenuItem(value: 'lowest_price', child: Text('Menor preço')),
                        ],
                        child: Chip(
                          avatar: const Icon(Icons.sort_rounded, size: 18),
                          label: Text(_sortLabel(state.sort)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    const _EmptyItemsState()
                  else
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ListItemTile(
                          item: item,
                          onTogglePurchased: () => controller.togglePurchased(item.id),
                          onIncrease: () => controller.updateQuantity(item.id, item.quantity + 1.0),
                          onDecrease: () {
                            final nextValue = item.quantity <= 1 ? 1.0 : item.quantity - 1.0;
                            controller.updateQuantity(item.id, nextValue);
                          },
                          onUpdatePrice: (price) => controller.updatePrice(item.id, price),
                          onDelete: () => controller.deleteItem(item.id),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          error: (error, _) => Center(child: Text(error.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  String _sortLabel(String sort) {
    switch (sort) {
      case 'name':
        return 'Nome';
      case 'category':
        return 'Categoria';
      case 'highest_price':
        return 'Maior preço';
      case 'lowest_price':
        return 'Menor preço';
      default:
        return 'Ordenar';
    }
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF697284))),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _EmptyItemsState extends StatelessWidget {
  const _EmptyItemsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: [
          Icon(Icons.flash_on_rounded, size: 52, color: Color(0xFF2C7BE5)),
          SizedBox(height: 16),
          Text(
            'Nenhum item ainda',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'Toque em "Adicionar item" para usar a busca rápida de produtos e registrar a compra na hora.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF697284)),
          ),
        ],
      ),
    );
  }
}
