import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/models/list_item.dart';
import '../../../../shared/utils/br_currency_input_formatter.dart';
import '../../../../shared/utils/formatters.dart';

class ListItemTile extends StatelessWidget {
  const ListItemTile({
    super.key,
    required this.item,
    required this.onTogglePurchased,
    required this.onIncrease,
    required this.onDecrease,
    required this.onUpdatePrice,
    required this.onDelete,
  });

  final ListItem item;
  final VoidCallback onTogglePurchased;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<double> onUpdatePrice;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: onTogglePurchased,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: item.purchased
                          ? const Color(0xFF2FBF71)
                          : const Color(0xFFF2F5FA),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: item.purchased
                        ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          decoration: item.purchased ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (item.brand != null && item.brand!.isNotEmpty)
                        Text(
                          item.brand!,
                          style: const TextStyle(color: Color(0xFF697284)),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FB),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: onDecrease,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      Text(
                        formatQuantity(item.quantity),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        onPressed: onIncrease,
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: item.price == 0
                        ? ''
                        : formatCurrencyInput(item.price),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: const <TextInputFormatter>[
                      BrCurrencyInputFormatter(),
                    ],
                    decoration: const InputDecoration(labelText: 'Preço'),
                    onFieldSubmitted: (value) {
                      final price = parseCurrencyInput(value);
                      if (price != null) {
                        onUpdatePrice(price);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatCurrency(item.totalPrice),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
