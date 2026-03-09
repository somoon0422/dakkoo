import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dakkoo/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DakkooApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('오늘의 페이지 열기'), findsOneWidget);
  });
}
