import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/shopping_list.dart';
import '../../../shared/widgets/navigation_frame.dart';
import 'lists_controller.dart';
import 'widgets/create_list_sheet.dart';
import 'widgets/list_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsControllerProvider);

    ref.listen(listsControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return NavigationFrame(
      title: 'Suas listas',
      currentLocation: '/lists',
      actions: [
        IconButton(
          onPressed: () => ref.read(listsControllerProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showListSheet(context, ref),
        label: const Text('Nova lista'),
        icon: const Icon(Icons.add_rounded),
      ),
      child: listsAsync.when(
        data: (lists) {
          return RefreshIndicator(
            onRefresh: () => ref.read(listsControllerProvider.notifier).refresh(),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C7BE5), Color(0xFF2FBF71)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menos toques. Mais velocidade.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Abra a lista, pesquise o produto e registre preço e quantidade na hora. O fluxo foi pensado para uso real no mercado.',
                        style: TextStyle(color: Colors.white, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (lists.isEmpty)
                  const _EmptyListsState()
                else
                  ...lists.map(
                    (list) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: ListCard(
                        list: list,
                        onTap: () => context.go('/lists/${list.id}'),
                        onDuplicate: () async {
                          final duplicated = await ref
                              .read(listsControllerProvider.notifier)
                              .duplicate(list.id);
                          if (duplicated != null && context.mounted) {
                            context.go('/lists/${duplicated.id}');
                          }
                        },
                        onEdit: () => _showListSheet(context, ref, initialList: list),
                        onDelete: () => ref.read(listsControllerProvider.notifier).delete(list.id),
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
    );
  }

  Future<void> _showListSheet(
    BuildContext context,
    WidgetRef ref, {
    ShoppingList? initialList,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CreateListSheet(
          initialList: initialList,
          onSubmit: ({
            required String name,
            required String kind,
            int? month,
            int? year,
          }) {
            final controller = ref.read(listsControllerProvider.notifier);
            if (initialList == null) {
              return controller.create(name: name, kind: kind, month: month, year: year);
            }

            return controller.updateList(
              id: initialList.id,
              name: name,
              kind: kind,
              month: month,
              year: year,
            );
          },
        );
      },
    );
  }
}

class _EmptyListsState extends StatelessWidget {
  const _EmptyListsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: [
          Icon(Icons.shopping_basket_outlined, size: 52, color: Color(0xFF2C7BE5)),
          SizedBox(height: 16),
          Text(
            'Sua primeira lista começa aqui',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'Crie uma lista mensal ou livre e comece a comprar com menos fricção.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF697284)),
          ),
        ],
      ),
    );
  }
}

