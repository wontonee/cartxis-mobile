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
