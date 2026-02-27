# Razorpay ProGuard Rules
# Required for Razorpay SDK to work properly with minification enabled

-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# Stripe Push Provisioning (optional feature not used — suppress missing class errors)
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.reactnativestripesdk.pushprovisioning.**
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }

# Stripe general
-dontwarn com.stripe.**
-keep class com.stripe.** { *; }

# Flutter & Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Core (split install / deferred components — not used but referenced by Flutter engine)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
