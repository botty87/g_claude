// Smoke test for the test infrastructure itself.
//
// Verifies that `pumpAppWidget` resolves translations via `Locales.X.y`,
// proving the EasyLocalization wrapper is correctly wired before any
// downstream widget test relies on it.

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

  testWidgets(
      'sanity: rendering Locales.App.title does NOT show the literal key string — '
      'proves the success above is not the wrapper silently returning the key',
      (tester) async {
    await pumpAppWidget(
      tester,
      Builder(builder: (context) => Text(Locales.App.title)),
    );

    // If the wrapper failed to load translations, easy_localization returns
    // the raw key (`"app.title"`) on `tr()`. The positive test would still
    // pass `find.text("Claude Code GUI")` only when translations resolve. To
    // pin that path, assert here that the rendered widget is NOT the literal
    // key — which would be the symptom of a broken wrapper.
    expect(find.text('app.title'), findsNothing,
        reason: 'A rendered literal key would mean translations did not load.');
  });
}
