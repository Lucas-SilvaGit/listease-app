import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/models/product.dart';
import '../../../../shared/utils/br_currency_input_formatter.dart';
import '../../../../shared/widgets/searchable_select_field.dart';
import '../product_categories.dart';

class ProductFormSheet extends StatefulWidget {
  const ProductFormSheet({
    super.key,
    this.initialProduct,
    this.availableCategories = const [],
    required this.onSubmit,
  });

  final Product? initialProduct;
  final List<String> availableCategories;
  final Future<void> Function({
    required String name,
    String? brand,
    required String category,
    required double defaultPrice,
  }) onSubmit;

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  static const _newCategoryValue = '__new__';

  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _newCategoryController;
  late final TextEditingController _defaultPriceController;
  String? _selectedCategory;
  String? _nameError;
  String? _categoryError;
  String? _priceError;
  bool _saving = false;

  List<String> get _categories {
    final merged = {
      ...defaultProductCategories,
      ...widget.availableCategories.where((item) => item.trim().isNotEmpty),
    }.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final initialCategory = widget.initialProduct?.category;
    if (initialCategory != null &&
        initialCategory.trim().isNotEmpty &&
        !merged.contains(initialCategory)) {
      merged.add(initialCategory);
      merged.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }

    return merged;
  }

  String get _resolvedSelectedCategory =>
      _selectedCategory ?? _deriveSelectedCategory(widget.initialProduct?.category);

  bool get _isCreatingCategory => _resolvedSelectedCategory == _newCategoryValue;

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
    _nameController = TextEditingController(text: widget.initialProduct?.name ?? '');
    _brandController = TextEditingController(text: widget.initialProduct?.brand ?? '');
    _newCategoryController = TextEditingController();
    _defaultPriceController = TextEditingController(
      text: widget.initialProduct?.defaultPrice == null
          ? ''
          : formatCurrencyInput(widget.initialProduct!.defaultPrice!),
    );
    final initialCategory = widget.initialProduct?.category;
    _selectedCategory = _deriveSelectedCategory(initialCategory);

    if (_resolvedSelectedCategory == _newCategoryValue) {
      _newCategoryController.text = initialCategory ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _newCategoryController.dispose();
    _defaultPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Text(
            widget.initialProduct == null ? 'Novo produto' : 'Editar produto',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome',
              errorText: _nameError,
            ),
            onChanged: (_) {
              if (_nameError != null) {
                setState(() => _nameError = null);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _brandController,
            decoration: const InputDecoration(labelText: 'Marca'),
          ),
          const SizedBox(height: 12),
          SearchableSelectField<String>(
            value: _resolvedSelectedCategory,
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
          if (_isCreatingCategory) ...[
            const SizedBox(height: 12),
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
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _defaultPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const <TextInputFormatter>[
              BrCurrencyInputFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Preço padrão',
              errorText: _priceError,
            ),
            onChanged: (_) {
              if (_priceError != null) {
                setState(() => _priceError = null);
              }
            },
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: Text(_saving ? 'Salvando...' : 'Salvar produto'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final category = _isCreatingCategory
        ? _newCategoryController.text.trim()
        : _resolvedSelectedCategory.trim();
    final defaultPrice = parseCurrencyInput(_defaultPriceController.text);

    if (name.isEmpty) {
      setState(() => _nameError = 'Informe o nome para salvar o produto.');
      return;
    }

    if (category.isEmpty) {
      setState(() {
        _categoryError = _isCreatingCategory
            ? 'Informe a categoria para salvar o produto.'
            : 'Selecione uma categoria para salvar o produto.';
      });
      return;
    }

    if (defaultPrice == null || defaultPrice <= 0) {
      setState(() => _priceError = 'Informe um preco valido para salvar o produto.');
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSubmit(
        name: name,
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        category: category,
        defaultPrice: defaultPrice,
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

  String _deriveSelectedCategory(String? category) {
    if (category == null || category.isEmpty) {
      return '';
    }

    if (_categories.contains(category)) {
      return category;
    }

    return _newCategoryValue;
  }
}
