import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/main.dart';

void main() {
  testWidgets('Campus Dashboard & Digital ID UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudentCampusApp());

    // Verify AppBar Title & Campus Dashboard header
    expect(find.text('Campus Dashboard'), findsOneWidget);
    expect(find.text('Digital Student ID Portal'), findsOneWidget);

    // Verify Student ID Card details
    expect(find.text('Syed Muhammad Ali'), findsOneWidget);
    expect(find.text('CS-2022-089'), findsWidgets);
    expect(find.text('Computer Science'), findsOneWidget);

    // Verify Enrolled Courses Header
    expect(find.text('Enrolled Courses'), findsOneWidget);

    // Verify Quick Notes section & button
    expect(find.text('Campus Quick Notes & Tasks'), findsOneWidget);
    expect(find.text('Add Quick Note'), findsOneWidget);
  });
}
