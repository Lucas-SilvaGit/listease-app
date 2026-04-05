String formatCurrency(double value) {
  final normalized = value.isFinite ? value : 0;
  return 'R\$ ${normalized.toStringAsFixed(2).replaceAll('.', ',')}';
}

String formatQuantity(double value) {
  if (value.truncateToDouble() == value) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(2).replaceAll('.', ',');
}
