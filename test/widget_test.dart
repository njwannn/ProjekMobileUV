import 'package:flutter_test/flutter_test.dart';
import 'package:uv_monitor_app/main.dart';

void main() {
  testWidgets('UV Monitor App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UvMonitorApp());
    expect(find.text('UV Monitor'), findsOneWidget);
  });
}
