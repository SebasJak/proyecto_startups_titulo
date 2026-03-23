import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto_startups_titulo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PegasusApp()));

    // Verify that the Feed is the default screen.
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
