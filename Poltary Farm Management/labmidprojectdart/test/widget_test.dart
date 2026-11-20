import 'package:flutter_test/flutter_test.dart';
import 'package:labmidprojectdart/main.dart';

void main() {
  testWidgets('PoultryApp launches LoginScreen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PoultryApp());

    // Verify login screen elements
    expect(find.text('Poultry Farm Records'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
