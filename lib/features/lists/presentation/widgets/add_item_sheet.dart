import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/product.dart';
import '../../../../shared/utils/br_currency_input_formatter.dart';
import '../../../products/data/products_repository.dart';
import '../../../products/presentation/products_controller.dart';

class AddItemSheet extends ConsumerStatefulWidget {
  const AddItemSheet({
    super.key,
    required this.onSubmit,
  });

  final Future<void> Function({
    required int? productId,
    required String name,
    String? brand,
    required double quantity,
    required double price,
  }) onSubmit;

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _searchController = TextEditingController();
  final _brandController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  Timer? _debounce;
  bool _saving = false;
  List<Product> _results = const [];
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _searchProducts('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchText = _searchController.text.trim();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adicionar item',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pesquise um produto e informe apenas quantidade e preço.',
            style: TextStyle(color: Color(0xFF697284)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Buscar produto',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: _results.isEmpty
                ? Center(
                    child: Text(
                      searchText.isEmpty
                          ? 'Seus produtos recentes aparecem aqui.'
                          : 'Nenhum produto encontrado. Você pode criar um novo agora.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF697284)),
                    ),
                  )
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = _results[index];
                      final isSelected = _selectedProduct?.id == product.id;

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: isSelected
                            ? const Color(0xFF2C7BE5).withValues(alpha: 0.08)
                            : null,
                        title: Text(product.name),
                        subtitle: Text(product.brand ?? 'Sem marca'),
                        trailing: product.defaultPrice == null
                            ? null
                            : Text('R\$ ${formatCurrencyInput(product.defaultPrice!)}'),
                        onTap: () {
                          setState(() {
                            _selectedProduct = product;
                            _brandController.text = product.brand ?? '';
                            _priceController.text = product.defaultPrice == null
                                ? ''
                                : formatCurrencyInput(product.defaultPrice!);
                          });
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          if (_selectedProduct == null && searchText.isNotEmpty)
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Marca opcional'),
            ),
          if (_selectedProduct == null && searchText.isNotEmpty) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: const <TextInputFormatter>[
                    BrCurrencyInputFormatter(),
                  ],
                  decoration: const InputDecoration(labelText: 'Preço'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: Text(_saving ? 'Salvando...' : 'Confirmar rápido'),
          ),
        ],
      ),
    );
  }

  void _handleSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      _searchProducts(_searchController.text.trim());
      if (_selectedProduct != null &&
          !_selectedProduct!.name.toLowerCase().contains(_searchController.text.trim().toLowerCase())) {
        setState(() => _selectedProduct = null);
      }
    });
  }

  Future<void> _searchProducts(String query) async {
    final repository = ref.read(productsRepositoryProvider);
    final results = await repository.searchProducts(query);
    if (mounted) {
      setState(() => _results = results);
    }
  }

  Future<void> _submit() async {
    final name = _selectedProduct?.name ?? _searchController.text.trim();
    final brand = _selectedProduct?.brand ?? _brandController.text.trim();
    final quantity = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 1;
    final price = parseCurrencyInput(_priceController.text) ?? 0;

    if (name.isEmpty) {
      return;
    }

    setState(() => _saving = true);
    try {
      final product = _selectedProduct ??
          await ref.read(productsControllerProvider.notifier).create(
                name: name,
                brand: brand.isEmpty ? null : brand,
                defaultPrice: price > 0 ? price : null,
              );

      await widget.onSubmit(
        productId: product.id,
        name: product.name,
        brand: product.brand,
        quantity: quantity,
        price: price > 0 ? price : (product.defaultPrice ?? 0),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
