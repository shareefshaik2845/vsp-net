// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vsp_resorts_portal/main.dart';

void main() {
  testWidgets('App loads and shows VSP Nest Portal', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: VspNestApp()));

    // Verify that the title or brand text is shown.
    expect(find.textContaining('VSP Nest'), findsAtLeastNWidgets(1));

    // Advance virtual clock to clear the splash transition timer
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump();
  });
}
