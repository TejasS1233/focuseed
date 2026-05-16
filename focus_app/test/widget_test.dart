import 'package:flutter_test/flutter_test.dart';
import 'package:focus_app/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const FocusGardenApp());
    expect(find.text('Focus Garden'), findsOneWidget);
  });
}
