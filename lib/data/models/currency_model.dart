class CurrencyModel {
  final int? id;
  final String name;
  final String code;
  final String symbol;
  final String symbolPosition; // 'left', 'right', 'before', or 'after'
  final int decimalPlaces;
  final String decimalSeparator;
  final String thousandSeparator;

  CurrencyModel({
    this.id,
    required this.name,
    required this.code,
    required this.symbol,
    required this.symbolPosition,
    required this.decimalPlaces,
    String? decimalSeparator,
    String? thousandSeparator,
  })  : decimalSeparator = decimalSeparator ?? '.',
        thousandSeparator = thousandSeparator ?? ',';

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      code: json['code'] as String,
      symbol: json['symbol'] as String,
      symbolPosition: json['symbol_position'] as String? ?? 'left',
      decimalPlaces: json['decimal_places'] as int? ?? 2,
      decimalSeparator: json['decimal_separator'] as String?,
      thousandSeparator: json['thousands_separator'] as String? ?? json['thousand_separator'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'symbol': symbol,
      'symbol_position': symbolPosition,
      'decimal_places': decimalPlaces,
      'decimal_separator': decimalSeparator,
      'thousand_separator': thousandSeparator,
    };
  }

  /// Format amount according to currency settings
  /// Example: $1,234.56 or 1.234,56 €
  String formatAmount(double amount) {
    // Split amount into integer and decimal parts
    final parts = amount.toStringAsFixed(decimalPlaces).split('.');
    String integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Add thousand separators
    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(thousandSeparator);
      }
      buffer.write(integerPart[i]);
    }

    // Combine with decimal part
    String formattedAmount = buffer.toString();
    if (decimalPlaces > 0 && decimalPart.isNotEmpty) {
      formattedAmount += '$decimalSeparator$decimalPart';
    }

    // Add currency symbol based on position
    // Support both 'right'/'left' and 'before'/'after'
    if (symbolPosition == 'right' || symbolPosition == 'after') {
      return '$formattedAmount$symbol';
    } else {
      return '$symbol$formattedAmount';
    }
  }

  @override
  String toString() {
    return 'CurrencyModel(code: $code, symbol: $symbol, name: $name)';
  }
}
