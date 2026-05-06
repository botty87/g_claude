import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/l10n/l10n.dart';

import 'pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'pumpAppWidget loads translations so Locales.X.y.tr() resolves to the JSON value',
      (tester) async {
    await pumpAppWidget(
      tester,
      Builder(builder: (context) => Text(Locales.App.title)),
    );

    // Value comes from assets/translations/en.json: app.title == "Claude Code GUI".
    // If the wrapper does not load EasyLocalization translations, tr() returns
    // the literal key "app.title" and this expect fails — proving the helper.
    expect(find.text('Claude Code GUI'), findsOneWidget);
  });
}
