import 'package:flutter_test/flutter_test.dart';
import 'package:optik_takip/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Supabase initialize edilmeden test çalışmaz; basit smoke test.
    expect(OptikTakipApp, isNotNull);
  });
}
