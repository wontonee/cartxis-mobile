import 'package:cartxis_app/core/utils/crashlytics_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isBenignImageLoadError', () {
    test('matches Crashlytics NetworkImage avatar 404 message', () {
      const msg =
          'HTTP request failed, statusCode: 404, https://demo.cartxis.com/avatars/VrohCIQC7suimluLrjnKr0agAdQqJnHwrBOnNEf1.jpg?t=1793363345593';
      expect(isBenignImageLoadError(Exception(msg)), isTrue);
    });

    test('matches NetworkImageLoadException style message', () {
      expect(
        isBenignImageLoadError(
          Exception('NetworkImageLoadException: statusCode: 404'),
        ),
        isTrue,
      );
    });

    test('matches 403 image failures', () {
      expect(
        isBenignImageLoadError(
          Exception('HTTP request failed, statusCode: 403, https://x/a.jpg'),
        ),
        isTrue,
      );
    });

    test('does not treat unrelated errors as benign', () {
      expect(isBenignImageLoadError(Exception('Null check operator')), isFalse);
      expect(isBenignImageLoadError(StateError('bad state')), isFalse);
      expect(
        isBenignImageLoadError(Exception('HTTP request failed, statusCode: 500')),
        isFalse,
      );
    });
  });
}
