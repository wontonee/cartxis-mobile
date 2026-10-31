import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors Profile avatar pattern: Image.network + errorBuilder → initial.
void main() {
  testWidgets('404 avatar shows fallback letter via errorBuilder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 112,
              height: 112,
              child: Image.network(
                'https://demo.cartxis.com/avatars/definitely-missing-404.jpg',
                fit: BoxFit.cover,
                width: 112,
                height: 112,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Colors.blue,
                  child: Center(
                    child: Text('S', key: Key('avatar-fallback')),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Allow network attempt + error path.
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.byKey(const Key('avatar-fallback')), findsOneWidget);
    expect(find.text('S'), findsOneWidget);
  });
}
