import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/product.dart';
import '../../../../shared/utils/br_currency_input_formatter.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../shared/widgets/searchable_select_field.dart';
import '../../../products/data/products_repository.dart';
import '../../../products/presentation/product_categories.dart';
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
  static const _newCategoryValue = '__new__';

  final _searchController = TextEditingController();
  final _brandController = TextEditingController();
  final _newCategoryController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  Timer? _debounce;
  bool _saving = false;
  List<Product> _results = const [];
  Product? _selectedProduct;
  String _selectedCategory = '';
  String? _nameError;
  String? _categoryError;
  String? _priceError;

  List<String> get _categories {
    final products = ref.read(productsControllerProvider).valueOrNull ?? const <Product>[];
    return {
      ...defaultProductCategories,
      ...products
          .map((product) => product.category)
          .whereType<String>()
          .where((category) => category.trim().isNotEmpty),
    }.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  bool get _isCreatingCategory => _selectedCategory == _newCategoryValue;

  List<SearchableSelectOption<String>> get _categoryOptions => [
        ..._categories.map(
          (category) => SearchableSelectOption<String>(
            value: category,
            label: category,
          ),
        ),
        const SearchableSelectOption<String>(
          value: _newCategoryValue,
          label: 'Nova categoria',
          searchText: 'nova categoria adicionar criar',
        ),
      ];

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
    _newCategoryController.dispose();
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
            'Pesquise por nome ou categoria e informe apenas quantidade e preço.',
            style: TextStyle(color: Color(0xFF697284)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Buscar produto',
              prefixIcon: const Icon(Icons.search_rounded),
              errorText: _nameError,
            ),
            onChanged: (_) {
              if (_nameError != null) {
                setState(() => _nameError = null);
              }
            },
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
                        subtitle: Text(
                          [
                            if (product.brand != null && product.brand!.isNotEmpty) product.brand,
                            if (product.category != null && product.category!.isNotEmpty) product.category,
                          ].whereType<String>().join(' • '),
                        ),
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
                            _selectedCategory = product.category ?? '';
                            _nameError = null;
                            _categoryError = null;
                            _priceError = null;
                            _newCategoryController.clear();
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
          if (_selectedProduct == null && searchText.isNotEmpty)
            SearchableSelectField<String>(
              value: _selectedCategory.isEmpty ? null : _selectedCategory,
              label: 'Categoria',
              searchLabel: 'Buscar categoria',
              options: _categoryOptions,
              placeholder: 'Selecionar categoria',
              errorText: _isCreatingCategory ? null : _categoryError,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _categoryError = null;
                  if (value != _newCategoryValue) {
                    _newCategoryController.clear();
                  }
                });
              },
            ),
          if (_selectedProduct == null && searchText.isNotEmpty && _isCreatingCategory)
            const SizedBox(height: 12),
          if (_selectedProduct == null && searchText.isNotEmpty && _isCreatingCategory)
            TextField(
              controller: _newCategoryController,
              decoration: InputDecoration(
                labelText: 'Nome da nova categoria',
                errorText: _categoryError,
              ),
              onChanged: (_) {
                if (_categoryError != null) {
                  setState(() => _categoryError = null);
                }
              },
            ),
          if (_selectedProduct == null && searchText.isNotEmpty) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FB),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _decreaseQuantity,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Quantidade',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _increaseQuantity,
                        icon: const Icon(Icons.keyboard_arrow_up_rounded),
                      ),
                    ],
                  ),
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
                  decoration: InputDecoration(
                    labelText: 'Preço',
                    errorText: _priceError,
                  ),
                  onChanged: (_) {
                    if (_priceError != null) {
                      setState(() => _priceError = null);
                    }
                  },
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
    });
  }

  Future<void> _searchProducts(String query) async {
    final repository = ref.read(productsRepositoryProvider);
    final results = await repository.searchProducts(query);
    if (mounted) {
      setState(() {
        _results = results;

        if (_selectedProduct != null &&
            results.every((product) => product.id != _selectedProduct!.id)) {
          _selectedProduct = null;
        }
      });
    }
  }

  Future<void> _submit() async {
    final name = _selectedProduct?.name ?? _searchController.text.trim();
    final brand = _selectedProduct?.brand ?? _brandController.text.trim();
    final category = _selectedProduct?.category ??
        (_isCreatingCategory ? _newCategoryController.text.trim() : _selectedCategory.trim());
    final quantity = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 1;
    final typedPrice = parseCurrencyInput(_priceController.text);
    final fallbackPrice = _selectedProduct?.defaultPrice;
    final resolvedPrice = typedPrice ?? fallbackPrice;

    if (name.isEmpty) {
      setState(() => _nameError = 'Informe o nome do produto.');
      return;
    }

    if (category.isEmpty) {
      setState(() {
        _categoryError = _isCreatingCategory
            ? 'Informe a categoria para adicionar o item.'
            : 'Selecione uma categoria para adicionar o item.';
      });
      return;
    }

    if (resolvedPrice == null || resolvedPrice <= 0) {
      setState(() => _priceError = 'Informe um preco valido para adicionar o item.');
      return;
    }

    setState(() => _saving = true);
    try {
      final product = _selectedProduct ??
          await ref.read(productsControllerProvider.notifier).create(
                name: name,
                brand: brand.isEmpty ? null : brand,
                category: category,
                defaultPrice: resolvedPrice,
              );

      await widget.onSubmit(
        productId: product.id,
        name: product.name,
        brand: product.brand,
        quantity: quantity,
        price: resolvedPrice,
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

  void _increaseQuantity() {
    final currentQuantity = _currentQuantity;
    _quantityController.text = formatQuantity(currentQuantity + 1);
  }

  void _decreaseQuantity() {
    final currentQuantity = _currentQuantity;
    final nextQuantity = currentQuantity <= 1 ? 1.0 : currentQuantity - 1;
    _quantityController.text = formatQuantity(nextQuantity);
  }

  double get _currentQuantity =>
      double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 1;
}
