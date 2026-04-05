import 'package:flutter/material.dart';

class SearchableSelectOption<T> {
  const SearchableSelectOption({
    required this.value,
    required this.label,
    this.searchText,
  });

  final T value;
  final String label;
  final String? searchText;
}

class SearchableSelectField<T> extends StatelessWidget {
  const SearchableSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.placeholder = 'Selecionar',
    this.searchLabel = 'Buscar',
  });

  final String label;
  final T? value;
  final List<SearchableSelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final String placeholder;
  final String searchLabel;

  @override
  Widget build(BuildContext context) {
    final selected = options.cast<SearchableSelectOption<T>?>().firstWhere(
          (option) => option?.value == value,
          orElse: () => null,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final selectedValue = await showModalBottomSheet<T>(
          context: context,
          isScrollControlled: true,
          builder: (context) => _SearchableSelectSheet<T>(
            label: label,
            searchLabel: searchLabel,
            options: options,
            selectedValue: value,
          ),
        );

        if (selectedValue != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onChanged(selectedValue);
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: Text(
          selected?.label ?? placeholder,
          style: TextStyle(
            color: selected == null ? const Color(0xFF697284) : null,
          ),
        ),
      ),
    );
  }
}

class _SearchableSelectSheet<T> extends StatefulWidget {
  const _SearchableSelectSheet({
    required this.label,
    required this.searchLabel,
    required this.options,
    required this.selectedValue,
  });

  final String label;
  final String searchLabel;
  final List<SearchableSelectOption<T>> options;
  final T? selectedValue;

  @override
  State<_SearchableSelectSheet<T>> createState() =>
      _SearchableSelectSheetState<T>();
}

class _SearchableSelectSheetState<T> extends State<_SearchableSelectSheet<T>> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredOptions = widget.options.where((option) {
      final haystack = (option.searchText ?? option.label).toLowerCase();
      return haystack.contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SizedBox(
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: widget.searchLabel,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredOptions.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum resultado encontrado.',
                        style: TextStyle(color: Color(0xFF697284)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredOptions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final option = filteredOptions[index];
                        final isSelected = option.value == widget.selectedValue;

                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          tileColor: isSelected
                              ? const Color(0xFF2C7BE5).withValues(alpha: 0.08)
                              : null,
                          title: Text(option.label),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF2C7BE5),
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(option.value),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
