// Placeholder test
import 'package:flutter_test/flutter_test.dart';
import 'package:spamshield/main.dart';

void main() {
  testWidgets('SpamShield app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SpamShieldApp());
  });
}
