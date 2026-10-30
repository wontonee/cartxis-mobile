import 'package:flutter/material.dart';
import 'package:cartxis_app/core/constants/app_colors.dart';
import 'package:cartxis_app/core/constants/app_sizes.dart';

/// Cartxis auth logo that picks a light- or dark-friendly asset by [Brightness].
///
/// Local fallbacks:
/// - Light: `assets/transparent_logo.png` (dark ink + brand blue)
/// - Dark: `assets/transparent_logo_dark.png` (white ink + brand blue)
///
/// When [networkUrl] is set (from app settings), it is shown as-is. In dark mode
/// a light pad sits behind it so dark admin-uploaded logos stay visible.
class AuthLogo extends StatelessWidget {
  const AuthLogo({
    super.key,
    this.networkUrl,
    this.width = 200,
    this.height = 80,
  });

  final String? networkUrl;
  final double width;
  final double height;

  static const String lightAsset = 'assets/transparent_logo.png';
  static const String darkAsset = 'assets/transparent_logo_dark.png';

  String _assetFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkAsset : lightAsset;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final asset = _assetFor(brightness);

    Widget logo;
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      logo = Image.network(
        networkUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.asset(asset, fit: BoxFit.contain),
      );
    } else {
      logo = Image.asset(asset, fit: BoxFit.contain);
    }

    // Remote logos are often dark-on-transparent; keep them readable on dark UI.
    final needsLightPad = isDark && networkUrl != null && networkUrl!.isNotEmpty;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: needsLightPad
                ? AppColors.surfaceLight.withOpacity(0.92)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          child: Padding(
            padding: needsLightPad
                ? const EdgeInsets.all(AppSizes.sm)
                : EdgeInsets.zero,
            child: logo,
          ),
        ),
      ),
    );
  }
}
