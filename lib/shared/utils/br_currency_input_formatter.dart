import 'package:flutter/services.dart';

String formatCurrencyInput(num value) {
  final cents = (value * 100).round();
  final integerPart = (cents ~/ 100).toString();
  final decimalPart = (cents % 100).toString().padLeft(2, '0');

  final buffer = StringBuffer();
  for (var index = 0; index < integerPart.length; index++) {
    final reverseIndex = integerPart.length - index;
    buffer.write(integerPart[index]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return '${buffer.toString()},$decimalPart';
}

double? parseCurrencyInput(String value) {
  final normalized = value
      .replaceAll('.', '')
      .replaceAll(' ', '')
      .replaceAll('R\$', '')
      .replaceAll(',', '.')
      .trim();

  return normalized.isEmpty ? null : double.tryParse(normalized);
}

class BrCurrencyInputFormatter extends TextInputFormatter {
  const BrCurrencyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }

    final value = double.parse(digits) / 100;
    final formatted = formatCurrencyInput(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

