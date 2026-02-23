import 'package:flutter_test/flutter_test.dart';

import 'package:jayganga_books/app.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    // Verify the splash screen renders with app branding.
    expect(find.text('JAYGANGA'), findsOneWidget);
    expect(find.text('Books'), findsOneWidget);
  });
}
