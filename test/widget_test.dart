import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnicalc/main.dart';

void main() {
  testWidgets('OmniCalc smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OmniCalcApp());
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
