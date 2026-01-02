import 'package:flutter/material.dart';
import '../../core/utils/currency_utils.dart';

/// Widget to display formatted price with currency
class PriceText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool showLoading;
  final String? fallbackText;

  const PriceText({
    super.key,
    required this.amount,
    this.style,
    this.showLoading = false,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: CurrencyUtils.format(amount),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && showLoading) {
          return SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                style?.color ?? Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
              ),
            ),
          );
        }

        // Use cached currency for immediate display
        final formattedAmount = snapshot.data ?? CurrencyUtils.formatSync(amount);

        return Text(
          formattedAmount,
          style: style,
        );
      },
    );
  }
}

/// Widget to display formatted price with custom styling options
class StyledPriceText extends StatelessWidget {
  final double amount;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final bool showLoading;
  final TextDecoration? decoration;
  final TextAlign? textAlign;

  const StyledPriceText({
    super.key,
    required this.amount,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.showLoading = false,
    this.decoration,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return PriceText(
      amount: amount,
      showLoading: showLoading,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
      ),
    );
  }
}

/// Widget to display original and discounted prices
class DiscountedPriceText extends StatelessWidget {
  final double originalPrice;
  final double discountedPrice;
  final double? fontSize;
  final Color? originalPriceColor;
  final Color? discountedPriceColor;
  final MainAxisAlignment? alignment;

  const DiscountedPriceText({
    super.key,
    required this.originalPrice,
    required this.discountedPrice,
    this.fontSize,
    this.originalPriceColor,
    this.discountedPriceColor,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: alignment ?? MainAxisAlignment.start,
      children: [
        // Discounted price (prominent)
        StyledPriceText(
          amount: discountedPrice,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.bold,
          color: discountedPriceColor,
        ),
        const SizedBox(width: 8),
        // Original price (strikethrough)
        StyledPriceText(
          amount: originalPrice,
          fontSize: (fontSize ?? 16) * 0.85,
          color: originalPriceColor ?? (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
          decoration: TextDecoration.lineThrough,
        ),
      ],
    );
  }
}

/// Widget to display currency symbol only
class CurrencySymbol extends StatelessWidget {
  final TextStyle? style;

  const CurrencySymbol({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: CurrencyUtils.getSymbol(),
      builder: (context, snapshot) {
        final symbol = snapshot.data ?? CurrencyUtils.getCachedCurrency()?.symbol ?? '\$';
        return Text(symbol, style: style);
      },
    );
  }
}
