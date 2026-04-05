import 'package:flutter/material.dart';

import '../../../../shared/models/shopping_list.dart';
import '../../../../shared/utils/formatters.dart';

class ListCard extends StatelessWidget {
  const ListCard({
    super.key,
    required this.list,
    required this.onTap,
    required this.onDuplicate,
    required this.onEdit,
    required this.onDelete,
  });

  final ShoppingList list;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final progressColor = list.progress >= 1 ? const Color(0xFF2FBF71) : const Color(0xFF2C7BE5);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      list.kind == 'monthly' ? 'Mensal' : 'Livre',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'duplicate':
                          onDuplicate();
                          break;
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'duplicate', child: Text('Duplicar')),
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Excluir')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                list.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              if (list.month != null && list.year != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${list.month!.toString().padLeft(2, '0')}/${list.year}',
                  style: const TextStyle(color: Color(0xFF697284)),
                ),
              ],
              const SizedBox(height: 18),
              LinearProgressIndicator(
                value: list.progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: const Color(0xFFF0F3F8),
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _Metric(label: 'Itens', value: '${list.purchasedCount}/${list.itemsCount}'),
                  const SizedBox(width: 14),
                  _Metric(label: 'Total', value: formatCurrency(list.totalAmount)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF697284)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
