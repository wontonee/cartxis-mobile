# Currency System Documentation

## Overview
The app now fetches and uses a default currency from the backend API endpoint `/api/v1/currency/default`. This currency format is cached and used consistently throughout the app.

## Files Created

### 1. **Models**
- `lib/data/models/currency_model.dart` - Currency data model with formatting logic

### 2. **Services**
- `lib/data/services/currency_service.dart` - Service to fetch and cache currency from API

### 3. **Utils**
- `lib/core/utils/currency_utils.dart` - Global utility for easy currency access

### 4. **Widgets**
- `lib/presentation/widgets/price_text.dart` - Reusable widgets for displaying prices

### 5. **Configuration**
- Updated `lib/core/config/api_config.dart` - Added currency endpoint

## Currency API Response Format

Expected response from `GET /api/v1/currency/default`:

```json
{
  "success": true,
  "message": "Default currency retrieved successfully",
  "data": {
    "id": 1,
    "name": "Indian Rupee",
    "code": "INR",
    "symbol": "₹",
    "symbol_position": "left",
    "decimal_places": 2,
    "decimal_separator": ".",
    "thousand_separator": ","
  }
}
```

## Usage Examples

### 1. Using CurrencyUtils (Recommended for Services/Logic)

```dart
import 'package:vortex_app/core/utils/currency_utils.dart';

// Format an amount
String formatted = await CurrencyUtils.format(1234.56);
// Output: "₹1,234.56" or "$1,234.56" depending on currency

// Get currency symbol
String symbol = await CurrencyUtils.getSymbol();
// Output: "₹" or "$"

// Get currency code
String code = await CurrencyUtils.getCode();
// Output: "INR" or "USD"

// Get full currency model
CurrencyModel currency = await CurrencyUtils.getCurrency();

// Synchronous formatting (uses cached currency)
String formatted = CurrencyUtils.formatSync(1234.56);
```

### 2. Using PriceText Widget (Recommended for UI)

```dart
import 'package:vortex_app/presentation/widgets/price_text.dart';

// Basic usage
PriceText(amount: 1234.56)

// With custom styling
PriceText(
  amount: 1234.56,
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  ),
)

// Using StyledPriceText for convenience
StyledPriceText(
  amount: 1234.56,
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.green,
)
```

### 3. Using DiscountedPriceText Widget

```dart
import 'package:vortex_app/presentation/widgets/price_text.dart';

// Display original and discounted prices
DiscountedPriceText(
  originalPrice: 1999.99,
  discountedPrice: 1499.99,
  fontSize: 16,
)
// Output: ₹1,499.99  ₹1,999.99 (strikethrough)
```

### 4. Using CurrencySymbol Widget

```dart
import 'package:vortex_app/presentation/widgets/price_text.dart';

// Display just the currency symbol
CurrencySymbol(
  style: TextStyle(fontSize: 20),
)
```

## Integration Points

### App Startup (Already Implemented)
Currency is preloaded in `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Preload default currency
  CurrencyUtils.preload();
  
  runApp(const VortexApp());
}
```

### Product Displays
Replace hardcoded currency symbols with PriceText:

**Before:**
```dart
Text('\$${product.price}')
```

**After:**
```dart
PriceText(amount: product.price)
```

### Cart Items
```dart
// Item price
PriceText(
  amount: item.price,
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
)

// Item total (price × quantity)
PriceText(
  amount: item.price * item.quantity,
  style: TextStyle(fontSize: 14),
)
```

### Checkout Summary
```dart
// Subtotal
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Subtotal:'),
    PriceText(amount: subtotal),
  ],
)

// Total
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
    StyledPriceText(
      amount: total,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
  ],
)
```

### Product Cards with Discounts
```dart
// Show both original and discounted prices
if (product.hasDiscount) {
  DiscountedPriceText(
    originalPrice: product.originalPrice,
    discountedPrice: product.discountedPrice,
  )
} else {
  PriceText(amount: product.price)
}
```

## Features

### 1. **Automatic Caching**
- Currency is fetched from API once and cached locally
- Subsequent app launches use cached currency (no API call needed)
- Cache is updated when `CurrencyUtils.refresh()` is called

### 2. **Offline Support**
- If API fails, uses cached currency
- If no cache available, falls back to USD with basic formatting

### 3. **Flexible Formatting**
- Supports different symbol positions (left/right)
- Configurable decimal places
- Customizable thousand and decimal separators
- Example formats:
  - `$1,234.56` (USD, left symbol)
  - `1.234,56€` (EUR, right symbol)
  - `₹1,234.56` (INR, left symbol)

### 4. **Synchronous Access**
- `formatSync()` provides immediate formatting using cached currency
- Useful in build methods where async is not possible
- Falls back to basic USD format if nothing is cached

## Cache Management

### Clear Cache
```dart
await CurrencyUtils.clearCache();
```

### Force Refresh from API
```dart
await CurrencyUtils.refresh();
```

### Check if Currency is Cached
```dart
CurrencyModel? cached = CurrencyUtils.getCachedCurrency();
if (cached != null) {
  print('Currency cached: ${cached.code}');
} else {
  print('No cached currency');
}
```

## Backend API Requirements

### Endpoint
```
GET /api/v1/currency/default
```

### Response Structure
```json
{
  "success": true,
  "message": "Success message",
  "data": {
    "id": 1,
    "name": "Currency Name",
    "code": "CUR",
    "symbol": "¤",
    "symbol_position": "left" | "right",
    "decimal_places": 2,
    "decimal_separator": ".",
    "thousand_separator": ","
  }
}
```

### Required Fields
- `id` (int): Currency ID
- `name` (string): Full currency name (e.g., "US Dollar")
- `code` (string): ISO currency code (e.g., "USD")
- `symbol` (string): Currency symbol (e.g., "$")
- `symbol_position` (string): "left" or "right"

### Optional Fields
- `decimal_places` (int): Default is 2
- `decimal_separator` (string): Default is "."
- `thousand_separator` (string): Default is ","

## Testing

### Test the Currency Service
```dart
void testCurrency() async {
  // Get currency
  final currency = await CurrencyUtils.getCurrency();
  print('Currency: ${currency.name} (${currency.code})');
  print('Symbol: ${currency.symbol}');
  
  // Test formatting
  final formatted = currency.formatAmount(1234.56);
  print('Formatted: $formatted');
  
  // Test various amounts
  print(await CurrencyUtils.format(0.99));
  print(await CurrencyUtils.format(10.00));
  print(await CurrencyUtils.format(999.99));
  print(await CurrencyUtils.format(1234.56));
  print(await CurrencyUtils.format(1000000.00));
}
```

## Migration Guide

### Replace Existing Currency Displays

1. **Find all hardcoded currency symbols:**
   - Search for: `\$`, `₹`, `€`, etc. in price displays

2. **Replace with PriceText widget:**
   ```dart
   // Old
   Text('\$${price.toStringAsFixed(2)}')
   
   // New
   PriceText(amount: price)
   ```

3. **Update string formatting:**
   ```dart
   // Old
   String priceText = '\$${price.toStringAsFixed(2)}';
   
   // New
   String priceText = await CurrencyUtils.format(price);
   // Or for sync contexts:
   String priceText = CurrencyUtils.formatSync(price);
   ```

## Notes

- Currency is loaded asynchronously on app startup
- First app launch requires internet to fetch currency
- Subsequent launches work offline using cache
- Cache persists across app restarts
- Currency updates only when explicitly refreshed or cache is cleared

## Console Logs

The currency system provides helpful logs:
- `🌍 Fetching default currency from API...`
- `✅ Default currency loaded: USD ($)`
- `💾 Currency cached successfully`
- `📦 Using cached currency as fallback`
- `⚠️ Using hardcoded fallback currency`

## Summary

✅ **Implemented:**
- Currency API integration
- Automatic caching system
- Formatting utilities
- Reusable UI widgets
- App startup preloading
- Offline fallback support

🎯 **Next Steps:**
1. Test the API endpoint returns correct data
2. Replace all hardcoded currency symbols in the app
3. Test different currency configurations
4. Implement currency selector (if needed for multi-currency support)
