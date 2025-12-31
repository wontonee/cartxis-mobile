# Vortex eCommerce - Flutter Mobile App Specification

## 1. Project Overview

### 1.1 Application Purpose
A full-featured, open-source Flutter eCommerce mobile application for both iOS and Android platforms, integrated with Vortex eCommerce backend API.

### 1.2 Target Platforms
- **iOS**: 13.0+
- **Android**: API 21+ (Android 5.0 Lollipop)

### 1.3 Technology Stack
- **Framework**: Flutter 3.16+
- **Language**: Dart 3.0+
- **State Management**: Provider / Riverpod / Bloc (recommended: Riverpod)
- **HTTP Client**: Dio
- **Local Storage**: Shared Preferences + Hive/Drift
- **Image Handling**: Cached Network Image
- **Payment Integration**: Razorpay, Stripe
- **Authentication**: Laravel Sanctum Token-based

### 1.4 API Integration
- **Base URL**: Configurable endpoint
- **API Version**: v1
- **Authentication**: Bearer Token (Sanctum)
- **Response Format**: JSON
- **Rate Limits**: 
  - Guest: 60 requests/minute
  - Authenticated: 300 requests/minute

---

## 2. Architecture & Project Structure

### 2.1 Folder Structure
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_sizes.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── helpers.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── network/
│       ├── api_client.dart
│       ├── dio_client.dart
│       ├── network_info.dart
│       └── interceptors.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   ├── category_model.dart
│   │   ├── cart_model.dart
│   │   ├── order_model.dart
│   │   ├── address_model.dart
│   │   ├── review_model.dart
│   │   └── wishlist_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── product_repository.dart
│   │   ├── cart_repository.dart
│   │   ├── order_repository.dart
│   │   ├── customer_repository.dart
│   │   └── wishlist_repository.dart
│   └── datasources/
│       ├── local/
│       │   ├── auth_local_datasource.dart
│       │   ├── cart_local_datasource.dart
│       │   └── wishlist_local_datasource.dart
│       └── remote/
│           ├── auth_remote_datasource.dart
│           ├── product_remote_datasource.dart
│           ├── cart_remote_datasource.dart
│           ├── order_remote_datasource.dart
│           └── customer_remote_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   ├── product.dart
│   │   ├── category.dart
│   │   ├── cart.dart
│   │   ├── order.dart
│   │   └── address.dart
│   └── usecases/
│       ├── auth/
│       ├── product/
│       ├── cart/
│       └── order/
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── product_provider.dart
│   │   ├── cart_provider.dart
│   │   ├── order_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── splash/
│   │   ├── onboarding/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── products/
│   │   │   ├── product_list_screen.dart
│   │   │   ├── product_detail_screen.dart
│   │   │   └── search_screen.dart
│   │   ├── categories/
│   │   │   └── category_screen.dart
│   │   ├── cart/
│   │   │   └── cart_screen.dart
│   │   ├── checkout/
│   │   │   ├── checkout_screen.dart
│   │   │   ├── address_selection_screen.dart
│   │   │   ├── shipping_method_screen.dart
│   │   │   └── payment_method_screen.dart
│   │   ├── orders/
│   │   │   ├── order_list_screen.dart
│   │   │   ├── order_detail_screen.dart
│   │   │   └── order_tracking_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   ├── edit_profile_screen.dart
│   │   │   └── address_management_screen.dart
│   │   └── wishlist/
│   │       └── wishlist_screen.dart
│   └── widgets/
│       ├── common/
│       │   ├── custom_button.dart
│       │   ├── custom_text_field.dart
│       │   ├── loading_indicator.dart
│       │   ├── error_widget.dart
│       │   └── empty_state_widget.dart
│       ├── product/
│       │   ├── product_card.dart
│       │   ├── product_grid.dart
│       │   ├── product_list_item.dart
│       │   └── product_image_slider.dart
│       ├── cart/
│       │   ├── cart_item_card.dart
│       │   └── cart_summary.dart
│       └── navigation/
│           └── bottom_nav_bar.dart
└── routes/
    └── app_router.dart
```

### 2.2 Clean Architecture Layers
1. **Presentation Layer**: UI, State Management, Providers
2. **Domain Layer**: Business Logic, Entities, Use Cases
3. **Data Layer**: Models, Repositories, Data Sources (Remote/Local)

---

## 3. API Integration Specifications

### 3.1 API Client Configuration

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://your-domain.com';
  static const String apiVersion = 'v1';
  static const String apiBasePath = '/api/$apiVersion';
  
  // Endpoints
  static const String login = '$apiBasePath/auth/login';
  static const String register = '$apiBasePath/auth/register';
  static const String logout = '$apiBasePath/auth/logout';
  static const String profile = '$apiBasePath/auth/me';
  static const String products = '$apiBasePath/products';
  static const String categories = '$apiBasePath/categories';
  static const String cart = '$apiBasePath/cart';
  static const String checkout = '$apiBasePath/checkout';
  static const String orders = '$apiBasePath/customer/orders';
  static const String wishlist = '$apiBasePath/customer/wishlist';
  static const String reviews = '$apiBasePath/reviews';
  static const String search = '$apiBasePath/search';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

### 3.2 Authentication Flow

**Token Storage**: Store Sanctum token in secure storage
**Token Refresh**: Manual re-login (Sanctum doesn't use refresh tokens)
**Auto-logout**: On 401 Unauthorized response

### 3.3 API Response Handling

```dart
// Standard Response Format
{
  "success": true,
  "message": "Operation successful",
  "data": { /* response data */ },
  "meta": {
    "timestamp": "2025-12-22T12:00:00Z",
    "version": "v1"
  }
}

// Paginated Response
{
  "success": true,
  "data": [...],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 20,
    "total": 100,
    "from": 1,
    "to": 20
  }
}

// Error Response
{
  "success": false,
  "message": "Error message",
  "errors": {
    "field": ["Validation error"]
  }
}
```

---

## 4. Screen Specifications

### 4.1 Splash Screen
**Purpose**: App initialization, check authentication status
- Display app logo and branding
- Check token validity
- Navigate to appropriate screen (Onboarding/Login/Home)

**API Calls**: None (local storage check)

---

### 4.2 Onboarding Screens
**Purpose**: First-time user introduction (3-4 screens)
- Feature highlights
- Benefits showcase
- Skip option available
- Get Started button

**API Calls**: None

---

### 4.3 Authentication Screens

#### 4.3.1 Login Screen
**API Endpoint**: `POST /api/v1/auth/login`
**Fields**:
- Email (email validation)
- Password (min 8 characters)
- Remember Me (checkbox)
- Device Name (auto-detected)

**Actions**:
- Login button
- Forgot Password link
- Register link
- Social login (optional: Google, Apple)

**Success**: Save token → Navigate to Home
**Error Handling**: Display validation errors, network errors

---

#### 4.3.2 Register Screen
**API Endpoint**: `POST /api/v1/auth/register`
**Fields**:
- Full Name (required)
- Email (email validation)
- Password (min 8 characters, strength indicator)
- Confirm Password (match validation)
- Terms & Conditions (checkbox)

**Actions**:
- Register button
- Login link

**Success**: Save token → Navigate to Home
**Error Handling**: Display validation errors per field

---

#### 4.3.3 Forgot Password Screen
**API Endpoints**: 
- `POST /api/v1/auth/password/forgot`
- `POST /api/v1/auth/password/reset`

**Step 1 - Request Reset**:
- Email field
- Send Reset Link button

**Step 2 - Reset Password**:
- New Password
- Confirm Password
- Reset button

---

### 4.4 Home Screen

**Layout**: Bottom Navigation (Home, Categories, Cart, Profile)

**Sections**:
1. **Search Bar**: Navigate to search screen
2. **Banner Slider**: Promotional banners (3-5 images, auto-scroll)
3. **Categories Row**: Horizontal scrollable category chips
4. **Featured Products**: `GET /api/v1/products/featured?limit=10`
5. **On Sale Products**: `GET /api/v1/products/on-sale?limit=10`
6. **New Arrivals**: `GET /api/v1/products/new-arrivals?limit=10`

**Features**:
- Pull-to-refresh
- Lazy loading
- Badge on cart icon (item count)
- Quick add to cart from product cards
- Wishlist heart icon

**API Calls**:
- Featured products
- On-sale products
- New arrivals
- Cart count: `GET /api/v1/cart/count`

---

### 4.5 Product Screens

#### 4.5.1 Product List Screen
**API Endpoint**: `GET /api/v1/products`

**Query Parameters**:
- `page` (pagination)
- `per_page` (20 default)
- `sort` (name, price, created_at)
- `order` (asc, desc)
- `category_id` (filter)
- `min_price`, `max_price` (range filter)
- `in_stock` (availability filter)

**Layout Options**:
- Grid View (2 columns)
- List View

**Features**:
- Filter bottom sheet (category, price, availability)
- Sort bottom sheet (popularity, price, newest)
- Infinite scroll / Load more
- Product card with: image, name, price, rating, wishlist icon
- Quick view option

**Filters UI**:
- Category chips
- Price range slider
- In Stock toggle
- Apply/Clear buttons

---

#### 4.5.2 Product Detail Screen
**API Endpoint**: `GET /api/v1/products/{id}`

**Sections**:
1. **Image Gallery**: Swipeable image carousel with indicators
2. **Product Info**:
   - Name
   - Price (regular & sale price)
   - Rating + Review count
   - Stock status
   - SKU
   - Short description

3. **Quantity Selector**: +/- buttons, quantity input

4. **Action Buttons**:
   - Add to Cart (primary button)
   - Add to Wishlist (icon button)
   - Share (icon button)

5. **Product Details**: Expandable sections
   - Full Description
   - Specifications (key-value pairs)
   - Shipping Info

6. **Reviews Section**: 
   - Average rating
   - Rating breakdown (5★ to 1★)
   - Review list: `GET /api/v1/products/{id}/reviews`
   - Write Review button (if purchased)

7. **Related Products**: 
   - `GET /api/v1/products/{id}/related?limit=5`
   - Horizontal scrollable

**Features**:
- Image zoom on tap
- Share product link
- Add to cart animation
- Stock alerts
- Favorite animation

---

#### 4.5.3 Search Screen
**API Endpoints**:
- Search: `GET /api/v1/search?q={query}`
- Suggestions: `GET /api/v1/search/suggestions?q={partial}`

**Features**:
- Real-time search suggestions (debounced)
- Recent searches (local storage)
- Search filters (same as product list)
- Voice search (optional)
- Barcode scanner (optional)

**UI**:
- Search bar with clear button
- Suggestions list (as you type)
- Search results (product grid/list)
- No results state

---

### 4.6 Category Screen

**API Endpoints**:
- Tree: `GET /api/v1/categories/tree`
- Products: `GET /api/v1/categories/{id}/products`

**Layout Options**:
1. **Grid View**: Category cards with images
2. **Tree View**: Expandable hierarchical list

**Features**:
- Navigate through category hierarchy
- Show product count per category
- Filter products by sub-categories
- Breadcrumb navigation

---

### 4.7 Cart Screen

**API Endpoints**:
- View: `GET /api/v1/cart`
- Add: `POST /api/v1/cart/add`
- Update: `PUT /api/v1/cart/items/{id}`
- Remove: `DELETE /api/v1/cart/items/{id}`
- Clear: `DELETE /api/v1/cart/clear`
- Apply Coupon: `POST /api/v1/cart/apply-coupon`
- Remove Coupon: `DELETE /api/v1/cart/remove-coupon`

**Cart Item Card**:
- Product image
- Name
- Selected attributes (size, color)
- Price (unit & total)
- Quantity selector (+/-)
- Remove button (swipe-to-delete)

**Cart Summary**:
- Subtotal
- Discount (if coupon applied)
- Shipping (calculated at checkout)
- Tax
- **Grand Total**

**Features**:
- Coupon code input field
- Apply/Remove coupon
- Save for later (move to wishlist)
- Empty cart state
- Proceed to Checkout button
- Continue Shopping link

**Validations**:
- Check stock availability
- Minimum order amount
- Coupon validity

---

### 4.8 Checkout Screens

#### 4.8.1 Checkout Flow
**Multi-step Process**:
1. Address Selection
2. Shipping Method
3. Payment Method
4. Order Review & Confirmation

---

#### 4.8.2 Address Selection Screen
**API Endpoints**:
- List: `GET /api/v1/customer/addresses`
- Add: `POST /api/v1/customer/addresses`
- Update: `PUT /api/v1/customer/addresses/{id}`
- Delete: `DELETE /api/v1/customer/addresses/{id}`
- Set Default: `POST /api/v1/customer/addresses/{id}/set-default`

**Features**:
- Select shipping address
- Select billing address (or same as shipping)
- Add new address form:
  - Address Line 1, 2
  - City, State, Postal Code
  - Country (dropdown)
  - Phone
  - Save as default checkbox
  - Address type (Home/Work/Other)
- Edit existing addresses
- Delete addresses
- Set default address

**Continue**: Navigate to Shipping Method

---

#### 4.8.3 Shipping Method Screen
**API Endpoint**: `GET /api/v1/checkout/shipping-methods`

**Display**:
- List of available shipping methods
- Method name
- Delivery time estimate
- Shipping cost
- Radio button selection

**API Call**: `POST /api/v1/checkout/shipping-method`
**Continue**: Navigate to Payment Method

---

#### 4.8.4 Payment Method Screen
**API Endpoint**: `GET /api/v1/checkout/payment-methods`

**Payment Options**:
1. **Razorpay** (default)
2. **Stripe**
3. **Cash on Delivery** (if enabled)
4. **Net Banking** (if available)
5. **UPI** (if available)
6. **Wallet** (if available)

**Features**:
- Radio button selection
- Payment method icons
- Security badges
- Terms & Conditions link

**API Call**: `POST /api/v1/checkout/payment-method`
**Continue**: Navigate to Order Review

---

#### 4.8.5 Order Review Screen
**API Endpoint**: `GET /api/v1/checkout/summary`

**Display Sections**:
1. **Cart Items**: Readonly list
2. **Shipping Address**: With edit button
3. **Billing Address**: With edit button
4. **Shipping Method**: With edit button
5. **Payment Method**: With edit button
6. **Order Summary**:
   - Subtotal
   - Shipping
   - Discount
   - Tax
   - **Total Amount**
7. **Order Notes**: Optional text field

**Place Order Button**: Primary CTA

**API Call**: `POST /api/v1/checkout/place-order`

**Success**:
- Show order confirmation screen
- Display order number
- Clear cart
- Navigate to Order Detail screen

**Error Handling**:
- Payment failures
- Inventory issues
- Network errors

---

### 4.9 Order Screens

#### 4.9.1 Order List Screen
**API Endpoint**: `GET /api/v1/customer/orders`

**Tabs**:
- All Orders
- Pending
- Processing
- Completed
- Cancelled

**Order Card**:
- Order number
- Date
- Status badge
- Total amount
- Product thumbnail (first item)
- Item count
- View Details button

**Features**:
- Pull-to-refresh
- Infinite scroll
- Filter by status
- Search orders

---

#### 4.9.2 Order Detail Screen
**API Endpoint**: `GET /api/v1/customer/orders/{id}`

**Sections**:
1. **Order Info**:
   - Order number
   - Date
   - Status with timeline
   - Payment status
   - Payment method

2. **Order Items**: List with images, names, quantities, prices

3. **Shipping Address**: Display only

4. **Billing Address**: Display only

5. **Order Summary**: Subtotal, shipping, tax, total

6. **Actions**:
   - Track Order: `GET /api/v1/customer/orders/{id}/track`
   - Download Invoice: `GET /api/v1/customer/orders/{id}/invoice`
   - Cancel Order: `POST /api/v1/customer/orders/{id}/cancel` (if eligible)
   - Reorder (add all items to cart)
   - Contact Support

**Order Status Timeline**:
- Order Placed
- Payment Confirmed
- Processing
- Shipped
- Out for Delivery
- Delivered

---

#### 4.9.3 Order Tracking Screen
**API Endpoint**: `GET /api/v1/customer/orders/{id}/track`

**Display**:
- Order status timeline (vertical stepper)
- Current location (if available)
- Estimated delivery date
- Tracking number
- Courier name
- Contact courier button

---

### 4.10 Profile Screens

#### 4.10.1 Profile Screen
**API Endpoint**: `GET /api/v1/auth/me`

**Layout**:
1. **Profile Header**:
   - Avatar image (tap to change)
   - Name
   - Email
   - Edit Profile button

2. **Menu Options**:
   - My Orders
   - Addresses
   - Wishlist
   - Payment Methods (future)
   - Notifications Settings
   - Language
   - Dark Mode Toggle
   - Help & Support
   - About Us
   - Terms & Conditions
   - Privacy Policy
   - Logout

**Features**:
- Profile picture upload: `POST /api/v1/auth/avatar`
- Edit profile navigation
- Logout with confirmation dialog

---

#### 4.10.2 Edit Profile Screen
**API Endpoint**: `PUT /api/v1/auth/profile`

**Fields**:
- Full Name
- Email (readonly or verification required)
- Phone
- Date of Birth (date picker)
- Gender (dropdown)

**Actions**:
- Save button
- Cancel button

**Additional**:
- Change Password: `POST /api/v1/auth/password/change`
  - Current Password
  - New Password
  - Confirm Password

---

#### 4.10.3 Address Management Screen
**API Endpoints**: Same as checkout address management

**Display**:
- List of saved addresses
- Default address badge
- Add Address button
- Edit/Delete actions per address

---

### 4.11 Wishlist Screen

**API Endpoints**:
- List: `GET /api/v1/customer/wishlist`
- Add: `POST /api/v1/customer/wishlist/add`
- Remove: `DELETE /api/v1/customer/wishlist/{id}`
- Move to Cart: `POST /api/v1/customer/wishlist/{id}/move-to-cart`

**Layout**:
- Grid/List view toggle
- Product cards with:
  - Image
  - Name
  - Price
  - Stock status
  - Add to Cart button
  - Remove button

**Features**:
- Empty state
- Bulk move to cart
- Share wishlist (future)
- Stock alerts

---

### 4.12 Review Screens

#### 4.12.1 Write Review Screen
**API Endpoint**: `POST /api/v1/reviews`

**Fields**:
- Product info (readonly)
- Star rating (1-5, tap or drag)
- Review title
- Review text (multiline)
- Upload photos (optional, 3-5 images)

**Validations**:
- Must have purchased product
- One review per product

**Actions**:
- Submit button
- Cancel button

---

#### 4.12.2 Edit Review Screen
**API Endpoint**: `PUT /api/v1/reviews/{id}`

**Same fields as write review**

---

## 5. UI/UX Design Guidelines

### 5.1 Design System

**Color Palette**:
```dart
// Primary Colors
primaryColor: #FF6B6B (coral/red)
primaryDark: #E84545
primaryLight: #FF9999

// Secondary Colors
secondaryColor: #4ECDC4 (teal)
secondaryDark: #45B7AF
secondaryLight: #6FD8D1

// Neutral Colors
backgroundColor: #F7F7F7
surfaceColor: #FFFFFF
cardColor: #FFFFFF
dividerColor: #E0E0E0

// Text Colors
textPrimary: #212121
textSecondary: #757575
textHint: #9E9E9E
textInverse: #FFFFFF

// Status Colors
success: #4CAF50
error: #F44336
warning: #FF9800
info: #2196F3

// Ratings
starColor: #FFC107
```

**Typography**:
```dart
// Font Family: Inter / Roboto / SF Pro
headline1: 28sp, Bold
headline2: 24sp, Bold
headline3: 20sp, SemiBold
headline4: 18sp, SemiBold
body1: 16sp, Regular
body2: 14sp, Regular
caption: 12sp, Regular
button: 16sp, SemiBold
```

**Spacing Scale**:
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- xxl: 48px

**Border Radius**:
- Small: 4px (chips, badges)
- Medium: 8px (cards, buttons)
- Large: 16px (bottom sheets, dialogs)
- Round: 50% (avatars, icon buttons)

**Elevation/Shadows**:
- Level 1: 2dp (cards)
- Level 2: 4dp (buttons)
- Level 3: 8dp (app bar)
- Level 4: 16dp (bottom nav, FAB)

---

### 5.2 Component Specifications

#### Buttons
1. **Primary Button**:
   - Background: primaryColor
   - Text: white
   - Height: 48px
   - Border Radius: 8px
   - Full width or fixed

2. **Secondary Button**:
   - Outlined with primaryColor
   - Text: primaryColor
   - Height: 48px

3. **Text Button**:
   - No background
   - Text: primaryColor
   - Height: auto

#### Input Fields
- Height: 56px
- Border: 1px solid dividerColor
- Border Radius: 8px
- Focus: primaryColor border
- Error: errorColor border with helper text
- Prefix/Suffix icons support

#### Product Card
- Aspect Ratio: 3:4 (image)
- Wishlist icon: top-right
- Badge: top-left (sale, new, featured)
- Padding: 8px
- Card elevation: 2dp
- Tap effect: scale animation

#### Bottom Navigation
- Height: 60px
- Icons: 24px
- Active: primaryColor
- Inactive: textSecondary
- Badge support (cart count)

#### App Bar
- Height: 56px
- Elevation: 3dp
- Back button: left
- Title: center
- Actions: right (search, cart, menu)

---

### 5.3 Animations & Transitions

**Page Transitions**:
- Push: Slide from right
- Pop: Slide to right
- Fade: Opacity transition (modals)

**Micro-interactions**:
- Add to Cart: Scale + bounce animation
- Wishlist: Heart fill animation
- Button press: Ripple effect
- Image loading: Shimmer skeleton
- Pull-to-refresh: Custom indicator

**Duration**:
- Fast: 150ms (button press)
- Medium: 300ms (page transition)
- Slow: 500ms (complex animations)

---

### 5.4 Loading States

1. **Skeleton Screens**: For initial page load
2. **Shimmer Effect**: For content placeholders
3. **Progress Indicators**:
   - Circular: Center of screen
   - Linear: Top of screen
4. **Pull-to-Refresh**: Custom indicator with logo

---

### 5.5 Error States

1. **Network Error**:
   - Icon + message
   - Retry button
   - Offline mode indicator

2. **Empty States**:
   - Illustration
   - Message
   - Call-to-action button

3. **Validation Errors**:
   - Inline below field
   - Red color
   - Icon prefix

4. **Snackbar/Toast**:
   - Bottom of screen
   - Auto-dismiss (3-5s)
   - Action button (optional)

---

## 6. State Management

### 6.1 Provider Structure (Riverpod)

```dart
// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

// Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.read(cartRepositoryProvider));
});

// Product Provider
final productListProvider = FutureProvider.autoDispose
    .family<List<Product>, ProductFilters>((ref, filters) {
  return ref.read(productRepositoryProvider).getProducts(filters);
});
```

### 6.2 State Classes

```dart
// Auth State
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

// Cart State
@freezed
class CartState with _$CartState {
  const factory CartState({
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double total,
    String? couponCode,
    @Default(false) bool isLoading,
    String? error,
  }) = _CartState;
}
```

---

## 7. Data Models

### 7.1 User Model

```dart
@freezed
class User with _$User {
  const factory User({
    required int id,
    required String name,
    required String email,
    String? phone,
    String? avatar,
    DateTime? dateOfBirth,
    String? gender,
    DateTime? emailVerifiedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### 7.2 Product Model

```dart
@freezed
class Product with _$Product {
  const factory Product({
    required int id,
    required String name,
    required String slug,
    String? description,
    required double price,
    double? comparePrice,
    String? sku,
    required int stockQuantity,
    required bool inStock,
    required bool isFeatured,
    required bool isOnSale,
    required List<String> images,
    required List<Category> categories,
    required ProductMeta meta,
    double? averageRating,
    int? reviewCount,
    required DateTime createdAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => 
      _$ProductFromJson(json);
}

@freezed
class ProductMeta with _$ProductMeta {
  const factory ProductMeta({
    String? brand,
    String? weight,
    Map<String, dynamic>? attributes,
    Map<String, dynamic>? specifications,
  }) = _ProductMeta;

  factory ProductMeta.fromJson(Map<String, dynamic> json) => 
      _$ProductMetaFromJson(json);
}
```

### 7.3 Cart Model

```dart
@freezed
class Cart with _$Cart {
  const factory Cart({
    required List<CartItem> items,
    required int itemCount,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    String? couponCode,
    double? couponDiscount,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
}

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required int id,
    required Product product,
    required int quantity,
    required double price,
    required double total,
    Map<String, dynamic>? options,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) => 
      _$CartItemFromJson(json);
}
```

### 7.4 Order Model

```dart
@freezed
class Order with _$Order {
  const factory Order({
    required int id,
    required String orderNumber,
    required OrderStatus status,
    required PaymentStatus paymentStatus,
    required List<OrderItem> items,
    required Address shippingAddress,
    required Address billingAddress,
    required String shippingMethod,
    required String paymentMethod,
    required double subtotal,
    required double shippingCost,
    required double tax,
    required double discount,
    required double total,
    String? notes,
    String? trackingNumber,
    required DateTime createdAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}
```

### 7.5 Address Model

```dart
@freezed
class Address with _$Address {
  const factory Address({
    required int id,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String phone,
    required bool isDefault,
    String? label, // Home, Work, Other
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => 
      _$AddressFromJson(json);
}
```

---

## 8. Network Layer

### 8.1 Dio Configuration

```dart
class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    _dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout = ApiConstants.connectTimeout
      ..options.receiveTimeout = ApiConstants.receiveTimeout
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
      ..interceptors.addAll([
        AuthInterceptor(),
        LoggingInterceptor(),
        ErrorInterceptor(),
      ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters});
  Future<Response> post(String path, {dynamic data});
  Future<Response> put(String path, {dynamic data});
  Future<Response> delete(String path);
}
```

### 8.2 Auth Interceptor

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getStoredToken(); // From secure storage
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired, logout user
      logoutUser();
    }
    super.onError(err, handler);
  }
}
```

### 8.3 Error Handling

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectionTimeout:
      case DioErrorType.receiveTimeout:
        return ApiException(message: 'Connection timeout');
      case DioErrorType.badResponse:
        return ApiException(
          message: error.response?.data['message'] ?? 'Unknown error',
          statusCode: error.response?.statusCode,
          errors: error.response?.data['errors'],
        );
      default:
        return ApiException(message: 'Network error');
    }
  }
}
```

---

## 9. Local Storage

### 9.1 Secure Storage (Token)

```dart
// flutter_secure_storage for auth token
class SecureStorageService {
  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}
```

### 9.2 Shared Preferences (Settings)

```dart
// Settings, preferences, cache
class PreferencesService {
  Future<void> setThemeMode(ThemeMode mode);
  ThemeMode? getThemeMode();
  
  Future<void> setLanguage(String languageCode);
  String? getLanguage();
  
  Future<void> cacheCategories(List<Category> categories);
  List<Category>? getCachedCategories();
}
```

### 9.3 Hive/Drift (Offline Cart, Wishlist)

```dart
// For complex objects and offline support
@HiveType(typeId: 0)
class CartItemEntity extends HiveObject {
  @HiveField(0)
  int productId;
  
  @HiveField(1)
  int quantity;
  
  @HiveField(2)
  Map<String, dynamic>? options;
}
```

---

## 10. Features & Functionality

### 10.1 Core Features (MVP)
✅ User authentication (login, register, logout)
✅ Product browsing (list, grid, search, filter)
✅ Product details with images and reviews
✅ Shopping cart (add, update, remove, coupon)
✅ Checkout flow (address, shipping, payment)
✅ Order management (list, details, tracking)
✅ User profile management
✅ Wishlist
✅ Product reviews

### 10.2 Enhanced Features (Phase 2)
- Push notifications (order updates, promotions)
- Social login (Google, Apple, Facebook)
- Biometric authentication
- Multiple languages (i18n)
- Dark mode
- Image zoom and gallery
- Product sharing
- Order tracking with map
- Live chat support
- Product recommendations (AI)
- Augmented Reality (AR) product preview

### 10.3 Advanced Features (Phase 3)
- Wallet/Credit system
- Loyalty points & rewards
- Subscription products
- Gift cards
- Referral program
- Advanced filters (multi-select)
- Barcode scanner for search
- Voice search
- Offline mode (view cached products)
- Analytics & crash reporting

---

## 11. Payment Integration

### 11.1 Razorpay Integration

```dart
class RazorpayService {
  final Razorpay _razorpay;

  void openCheckout({
    required double amount,
    required String orderId,
    required String description,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
  }) {
    var options = {
      'key': 'YOUR_KEY_ID',
      'amount': amount * 100, // Convert to paise
      'name': 'Vortex Store',
      'order_id': orderId,
      'description': description,
      'prefill': {
        'contact': user.phone,
        'email': user.email,
      },
      'theme': {
        'color': '#FF6B6B'
      }
    };
    _razorpay.open(options);
  }
}
```

### 11.2 Stripe Integration

```dart
class StripeService {
  Future<void> makePayment({
    required double amount,
    required String currency,
  }) async {
    try {
      // 1. Create payment intent on backend
      final paymentIntent = await createPaymentIntent(amount, currency);
      
      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Vortex Store',
        ),
      );
      
      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      // Payment successful
    } catch (e) {
      // Handle error
    }
  }
}
```

---

## 12. Performance Optimization

### 12.1 Image Optimization
- Use `cached_network_image` for all remote images
- Implement progressive image loading
- Compress images on upload
- Use appropriate image sizes (thumbnail, medium, full)
- Lazy load images in lists

### 12.2 List Optimization
- Use `ListView.builder` for large lists
- Implement pagination (load more on scroll)
- Cache list items locally
- Use `AutomaticKeepAliveClientMixin` for tabs

### 12.3 API Optimization
- Debounce search queries (300-500ms)
- Cache API responses (TTL: 5-10 minutes)
- Implement request cancellation
- Batch API calls where possible
- Use pagination for all lists

### 12.4 Memory Management
- Dispose controllers and streams
- Clear image cache on memory warning
- Use `const` constructors
- Avoid memory leaks in state management

---

## 13. Testing Strategy

### 13.1 Unit Tests
- Repository methods
- Use case logic
- Data model serialization
- Validators and formatters
- Coverage target: 80%+

### 13.2 Widget Tests
- Individual widgets
- Screen layouts
- User interactions
- Form validations

### 13.3 Integration Tests
- Authentication flow
- Product purchase flow
- Cart operations
- Checkout process
- API integration

### 13.4 Test Structure
```
test/
├── unit/
│   ├── models/
│   ├── repositories/
│   └── utils/
├── widget/
│   ├── screens/
│   └── widgets/
└── integration/
    ├── auth_test.dart
    ├── cart_test.dart
    └── checkout_test.dart
```

---

## 14. Security Considerations

### 14.1 Authentication Security
- Store tokens in secure storage (Keychain/Keystore)
- Never log sensitive data
- Implement token expiration handling
- Use HTTPS for all API calls
- Implement certificate pinning (production)

### 14.2 Data Security
- Encrypt local storage data
- Validate all user inputs
- Sanitize data before display
- Implement rate limiting
- Use obfuscation in release builds

### 14.3 Payment Security
- Never store card details locally
- Use official payment SDK integrations
- Follow PCI compliance guidelines
- Implement 3D Secure authentication
- Log payment attempts for auditing

---

## 15. Analytics & Monitoring

### 15.1 Analytics Events
- Screen views
- Product views
- Add to cart
- Purchase completed
- Search queries
- Filter usage
- Button clicks
- Time spent per screen

### 15.2 Crash Reporting
- Firebase Crashlytics
- Sentry (alternative)
- Custom error logging
- Network error tracking

### 15.3 Performance Monitoring
- App startup time
- Screen load time
- API response time
- Frame rendering time
- Network requests monitoring

---

## 16. Deployment

### 16.1 Environment Configuration

```dart
enum Environment { dev, staging, production }

class Config {
  static const Environment environment = Environment.production;
  
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://localhost:8000';
      case Environment.staging:
        return 'https://staging.vortex.com';
      case Environment.production:
        return 'https://api.vortex.com';
    }
  }
}
```

### 16.2 Build Flavors

```yaml
# Dev
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter build appbundle --flavor production -t lib/main_production.dart
```

### 16.3 Release Checklist
- [ ] Update version number and build number
- [ ] Run all tests (unit, widget, integration)
- [ ] Test on multiple devices and OS versions
- [ ] Verify all API endpoints
- [ ] Test payment integrations
- [ ] Check push notifications
- [ ] Verify deep links
- [ ] Update app icons and splash screens
- [ ] Generate signed builds
- [ ] Test release builds on devices
- [ ] Update App Store/Play Store metadata
- [ ] Prepare release notes
- [ ] Submit for review

---

## 17. App Store Requirements

### 17.1 iOS App Store
- **Screenshots**: 6.5", 5.5" (required)
- **App Icon**: 1024x1024px
- **Privacy Policy**: Required URL
- **Support URL**: Required
- **Age Rating**: Appropriate selection
- **Categories**: Shopping, Lifestyle
- **Keywords**: Optimized for search
- **Description**: Engaging copy with features

### 17.2 Google Play Store
- **Screenshots**: Phone, 7" tablet, 10" tablet
- **Feature Graphic**: 1024x500px
- **App Icon**: 512x512px
- **Privacy Policy**: Required URL
- **Content Rating**: Appropriate selection
- **Categories**: Shopping
- **Keywords/Tags**: Optimized for search
- **Description**: Feature-rich copy

---

## 18. Future Roadmap

### Phase 1 (MVP) - 3 months
- Core authentication
- Product browsing and search
- Cart and checkout
- Order management
- Basic profile

### Phase 2 (Enhanced) - 2 months
- Push notifications
- Social login
- Enhanced UI/UX
- Dark mode
- Multiple languages

### Phase 3 (Advanced) - 3 months
- Wallet system
- Loyalty program
- AR product preview
- Advanced analytics
- Performance optimization

### Phase 4 (Scale) - Ongoing
- Multi-vendor support
- Live streaming shopping
- AI recommendations
- Voice commerce
- Cross-platform (Web, Desktop)

---

## 19. Dependencies (pubspec.yaml)

```yaml
name: vortex_app
description: Vortex eCommerce Mobile Application
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Network
  dio: ^5.4.0
  connectivity_plus: ^5.0.0

  # Local Storage
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # JSON Serialization
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0

  # UI Components
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.0
  shimmer: ^3.0.0
  carousel_slider: ^4.2.0
  smooth_page_indicator: ^1.1.0
  image_picker: ^1.0.0
  photo_view: ^0.14.0

  # Navigation
  go_router: ^13.0.0

  # Forms & Validation
  flutter_form_builder: ^9.1.0
  form_builder_validators: ^9.1.0

  # Payment
  razorpay_flutter: ^1.3.0
  flutter_stripe: ^10.0.0

  # Authentication
  google_sign_in: ^6.1.0
  sign_in_with_apple: ^5.0.0

  # Utilities
  intl: ^0.18.0
  url_launcher: ^6.2.0
  share_plus: ^7.2.0
  package_info_plus: ^5.0.0
  device_info_plus: ^9.1.0

  # Analytics & Monitoring
  firebase_core: ^2.24.0
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.0
  firebase_messaging: ^14.7.0

  # Permissions
  permission_handler: ^11.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # Code Generation
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
  hive_generator: ^2.0.0

  # Testing
  mockito: ^5.4.0
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
  
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

---

## 20. Summary & Next Steps

This specification provides a complete blueprint for developing the Vortex eCommerce mobile application with Flutter. The app is designed to integrate seamlessly with your Vortex Laravel API.

### Key Highlights:
✅ Complete screen-by-screen specifications
✅ API endpoint mappings for every feature
✅ Clean architecture with proper separation of concerns
✅ Comprehensive UI/UX guidelines
✅ Security and performance best practices
✅ Payment gateway integration details
✅ Testing and deployment strategies
✅ Scalable architecture for future features

### Recommended Development Approach:
1. **Setup Phase**: Project structure, dependencies, theme
2. **Core Phase**: Authentication, API integration, state management
3. **Feature Phase**: Products, cart, checkout, orders
4. **Polish Phase**: UI/UX refinement, animations, error handling
5. **Testing Phase**: Unit, widget, integration tests
6. **Release Phase**: Build optimization, store submission

### For Google Stitch Integration:
This specification provides all necessary details including:
- Complete API documentation references
- Data models and structures
- Screen layouts and user flows
- Technical requirements
- Design system specifications

You can share this document directly with your development team or Google Stitch for implementation.

---

**Document Version**: 1.0  
**Last Updated**: December 22, 2025  
**Contact**: Your Team  
**License**: Open Source (MIT)
