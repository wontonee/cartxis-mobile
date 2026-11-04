/// Returns true for image HTTP 404/403 failures that should not count as
/// fatal crashes in Crashlytics.
///
/// Profile used to load avatars via [NetworkImage] without an error path; a
/// 404 became a Crashlytics "crash". Prefer [Image.network] + `errorBuilder`,
/// and keep this filter as a safety net.
bool isBenignImageLoadError(Object error) {
  final message = error.toString();
  final looksLikeImageHttp = message.contains('HTTP request failed') ||
      message.contains('NetworkImageLoadException') ||
      message.contains('NetworkImage') ||
      message.contains('statusCode:');
  if (!looksLikeImageHttp) return false;
  return message.contains('404') || message.contains('403');
}

/// Layout / framework asserts that paint a yellow/black stripe in debug but
/// must not be recorded as fatal Crashlytics crashes in release.
///
/// `FlutterError.onError` still receives [RenderFlex] overflows and similar
/// material assertions; treating them as fatal inflated crash-free rates
/// (e.g. "A RenderFlex overflowed by N pixels on the bottom").
bool isBenignFlutterFrameworkError(Object error) {
  final message = error.toString();
  if (message.contains('A RenderFlex overflowed') ||
      message.contains('RenderFlex overflowed') ||
      message.contains('A RenderBox overflowed') ||
      message.contains('overflowed by') ||
      message.contains('OVERFLOWING') ||
      message.contains('Incorrect use of ParentDataWidget') ||
      message.contains('Looking up a deactivated widget')) {
    return true;
  }
  // ListTile / Material ink decoration asserts (seen on 1.0.1).
  if (message.contains('DecoratedBox') &&
      message.contains('is not a subtype of type \'RenderBox\'')) {
    return true;
  }
  return false;
}

/// True when the error should be non-fatal in Crashlytics.
bool isNonFatalFlutterError(Object error) {
  return isBenignImageLoadError(error) || isBenignFlutterFrameworkError(error);
}
