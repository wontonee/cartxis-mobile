# Razorpay Integration Setup Guide

## ✅ Completed Steps

### 1. Package Installation
- Added `razorpay_flutter: ^1.4.0` to `pubspec.yaml`

### 2. Android Configuration
- ✅ Set `minSdk = 19` in `android/app/build.gradle.kts`
- ✅ Created ProGuard rules in `android/app/proguard-rules.pro`
- ✅ Enabled ProGuard in release build configuration

### 3. iOS Configuration
- ✅ Set platform to iOS 13.0 in `ios/Podfile`
- ✅ Enabled bitcode support
- ✅ Configured Swift 5.0 version

### 4. Code Implementation
- ✅ Created `RazorpayService` wrapper class
- ✅ Created test screen for payment integration

---

## 🚀 Next Steps (Required Before Testing)

### Step 1: Install Dependencies

Run these commands in your terminal:

```bash
cd /Volumes/Crucial/mobileapps/vortex
flutter pub get
cd ios
pod install
cd ..
```

### Step 2: Get Razorpay API Keys

1. **Sign up for Razorpay Account:**
   - Visit: https://dashboard.razorpay.com/#/access/signin
   - Sign up or log in to your account

2. **Generate API Keys:**
   - Go to Dashboard → Settings → API Keys
   - Generate Test Keys (for development)
   - Save both:
     - Test Key ID: `rzp_test_xxxxxxxxxxxxx`
     - Test Key Secret: `xxxxxxxxxxxxx` (keep this secure, backend only)

3. **Update Test Key in Code:**
   - Open: `lib/presentation/screens/payment/razorpay_test_screen.dart`
   - Find line 21: `final _razorpayTestKey = 'rzp_test_YOUR_KEY_HERE';`
   - Replace with your actual test key: `final _razorpayTestKey = 'rzp_test_xxxxxxxxxxxxx';`

### Step 3: Add Route to Main App

Open `lib/main.dart` and add the route:

```dart
import 'package:vortex_app/presentation/screens/payment/razorpay_test_screen.dart';

// In your MaterialApp routes:
routes: {
  '/razorpay-test': (context) => const RazorpayTestScreen(),
  // ... other routes
}
```

### Step 4: Test the Integration

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Navigate to test screen:**
   - Add a button in your app to navigate to `/razorpay-test`
   - Or use: `Navigator.pushNamed(context, '/razorpay-test')`

3. **Test Payment Flow:**
   - Enter amount (e.g., 100 for ₹100)
   - Fill in product details
   - Click "Pay with Razorpay"
   - Use test card details:
     - **Card Number:** 4111 1111 1111 1111
     - **CVV:** Any 3 digits (e.g., 123)
     - **Expiry:** Any future date (e.g., 12/25)
     - **Name:** Any name

---

## 📱 Platform-Specific Notes

### Android
- Minimum SDK version set to 19 (Android 4.4+)
- ProGuard rules configured for release builds
- Test on physical device for best results

### iOS
- Minimum deployment target: iOS 13.0
- Bitcode enabled
- Test on simulator or physical device
- If you get build errors, try:
  ```bash
  cd ios
  rm -rf Pods Podfile.lock
  pod install
  cd ..
  flutter clean
  flutter pub get
  ```

---

## 🔐 Payment Verification (Backend Integration)

After successful payment, you need to verify the payment on your backend:

### Payment Success Response Contains:
- `paymentId`: Razorpay payment ID
- `orderId`: Your order ID (if created)
- `signature`: Payment signature for verification

### Backend Verification Steps:

1. **Create Order API (Optional but Recommended):**
   ```
   POST https://api.razorpay.com/v1/orders
   Authorization: Basic <base64(key_id:key_secret)>
   
   Body:
   {
     "amount": 50000,  // amount in paise
     "currency": "INR",
     "receipt": "order_rcptid_11"
   }
   ```

2. **Verify Payment Signature:**
   ```
   generated_signature = hmac_sha256(order_id + "|" + payment_id, key_secret)
   
   if generated_signature == signature:
       payment is authentic
   ```

3. **Update in your auth_service.dart or create new payment_service.dart:**
   ```dart
   Future<bool> verifyPayment({
     required String paymentId,
     required String orderId,
     required String signature,
   }) async {
     final response = await _apiClient.post(
       '/api/v1/payment/verify',
       body: {
         'payment_id': paymentId,
         'order_id': orderId,
         'signature': signature,
       },
     );
     return response['success'];
   }
   ```

---

## 🧪 Testing Checklist

- [ ] Dependencies installed (`flutter pub get`, `pod install`)
- [ ] Razorpay test key added to code
- [ ] App builds successfully on Android
- [ ] App builds successfully on iOS
- [ ] Test screen accessible via route
- [ ] Payment checkout opens successfully
- [ ] Test card payment succeeds
- [ ] Success callback receives payment details
- [ ] Error handling works (cancel payment, network error)
- [ ] Console logs show payment flow

---

## 🔄 Integration with Your Checkout Flow

Once testing is complete, integrate Razorpay into your actual checkout:

1. **In Cart/Checkout Screen:**
   ```dart
   import '../../../data/services/razorpay_service.dart';
   
   final _razorpayService = RazorpayService();
   
   void initState() {
     super.initState();
     _razorpayService.onSuccess = (response) {
       // Verify payment on backend
       // Update order status
       // Navigate to success screen
     };
     _razorpayService.onError = (response) {
       // Show error message
       // Log failure for retry
     };
   }
   
   void _proceedToPayment() {
     _razorpayService.openCheckout(
       amount: totalAmount * 100,  // Convert to paise
       key: 'YOUR_RAZORPAY_KEY',
       name: 'Vortex Store',
       description: 'Order #12345',
       prefillEmail: userEmail,
       prefillContact: userPhone,
       orderId: backendOrderId,  // From your backend
     );
   }
   ```

2. **Add to dispose:**
   ```dart
   @override
   void dispose() {
     _razorpayService.dispose();
     super.dispose();
   }
   ```

---

## 📚 Documentation References

- **Razorpay Flutter SDK:** https://pub.dev/packages/razorpay_flutter
- **Razorpay Android Docs:** https://razorpay.com/docs/checkout/android/
- **Razorpay iOS Docs:** https://razorpay.com/docs/ios/
- **Payment Verification:** https://razorpay.com/docs/payments/server-integration/nodejs/payment-gateway/build-integration/
- **Test Cards:** https://razorpay.com/docs/payments/payments/test-card-upi-details/

---

## ⚠️ Important Notes

1. **Test vs Live Keys:**
   - Use Test keys (`rzp_test_xxx`) during development
   - Switch to Live keys (`rzp_live_xxx`) only when going to production
   - Never commit API keys to version control

2. **Amount Format:**
   - Always send amount in smallest currency unit
   - For INR: ₹100 = 10000 paise
   - For USD: $10 = 1000 cents

3. **Payment Verification:**
   - ALWAYS verify payment signature on your backend
   - Client-side verification is not secure
   - Do not rely solely on success callback

4. **Error Handling:**
   - Handle network errors gracefully
   - Log payment failures for debugging
   - Implement retry mechanism for failed payments

---

## 🐛 Troubleshooting

### Issue: "uses-sdk:minSdkVersion cannot be smaller than version 19"
**Solution:** Already fixed by setting `minSdk = 19` in `android/app/build.gradle.kts`

### Issue: "CocoaPods could not find compatible versions"
**Solution:** Already fixed by setting `platform :ios, '10.0'` in `ios/Podfile`

### Issue: "razorpay_flutter-Swift.h file not found"
**Solution:** Already fixed by adding `use_frameworks!` in `ios/Podfile`

### Issue: Payment checkout not opening
**Solution:** 
- Check if Razorpay key is correct
- Verify amount is greater than 0
- Check console logs for errors
- Ensure internet connection is available

---

## ✨ What's Next?

After successful Razorpay testing:
1. Test payment verification with your backend
2. Integrate into actual cart/checkout flow
3. Add order management
4. Test refund flow (if needed)
5. Then proceed with Stripe integration

---

**Status:** ✅ Razorpay setup complete and ready for testing!

**Your Action Required:**
1. Run `flutter pub get` and `pod install`
2. Add your Razorpay test key to `razorpay_test_screen.dart`
3. Test the payment flow
4. Share test results for next steps
