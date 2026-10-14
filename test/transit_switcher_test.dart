import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transit_kit/transit_kit.dart';

void main() {
  testWidgets('TransitSwitcher builds cleanly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransitSwitcher(
            type: TransitType.fadeThrough,
            duration: const Duration(milliseconds: 200),
            child: Container(key: const ValueKey(1), color: Colors.red),
          ),
        ),
      ),
    );
    expect(find.byType(TransitSwitcher), findsOneWidget);
  });
}
