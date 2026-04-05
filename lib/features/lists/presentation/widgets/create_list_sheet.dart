import 'package:flutter/material.dart';

import '../../../../shared/models/shopping_list.dart';
import '../../../../shared/widgets/searchable_select_field.dart';

class CreateListSheet extends StatefulWidget {
  const CreateListSheet({
    super.key,
    this.initialList,
    required this.onSubmit,
  });

  final ShoppingList? initialList;
  final Future<void> Function({
    required String name,
    required String kind,
    int? month,
    int? year,
  }) onSubmit;

  @override
  State<CreateListSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends State<CreateListSheet> {
  static const _months = <MapEntry<int, String>>[
    MapEntry(1, 'Janeiro'),
    MapEntry(2, 'Fevereiro'),
    MapEntry(3, 'Marco'),
    MapEntry(4, 'Abril'),
    MapEntry(5, 'Maio'),
    MapEntry(6, 'Junho'),
    MapEntry(7, 'Julho'),
    MapEntry(8, 'Agosto'),
    MapEntry(9, 'Setembro'),
    MapEntry(10, 'Outubro'),
    MapEntry(11, 'Novembro'),
    MapEntry(12, 'Dezembro'),
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _yearController;
  late String _kind;
  int? _selectedMonth;
  bool _saving = false;

  List<SearchableSelectOption<int>> get _monthOptions => _months
      .map(
        (month) => SearchableSelectOption<int>(
          value: month.key,
          label: month.value,
          searchText: '${month.key} ${month.value}',
        ),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialList?.name ?? '');
    _yearController = TextEditingController(
      text: widget.initialList?.year?.toString() ?? '',
    );
    _kind = widget.initialList?.kind ?? 'free';
    _selectedMonth = widget.initialList?.month;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMonthly = _kind == 'monthly';

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
            widget.initialList == null ? 'Nova lista' : 'Editar lista',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome da lista'),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'free', label: Text('Livre')),
              ButtonSegment(value: 'monthly', label: Text('Mensal')),
            ],
            selected: {_kind},
            onSelectionChanged: (value) => setState(() => _kind = value.first),
          ),
          if (isMonthly) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SearchableSelectField<int>(
                    value: _selectedMonth,
                    label: 'Mês',
                    searchLabel: 'Buscar mês',
                    options: _monthOptions,
                    placeholder: 'Selecionar mês',
                    onChanged: (value) {
                      setState(() => _selectedMonth = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ano'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: Text(_saving ? 'Salvando...' : 'Salvar lista'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSubmit(
        name: name,
        kind: _kind,
        month: _kind == 'monthly' ? _selectedMonth : null,
        year: _kind == 'monthly' ? int.tryParse(_yearController.text) : null,
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
