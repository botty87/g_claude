import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/l10n/l10n.dart';

import 'pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pumpAppWidget loads translations so Locales.X.y.tr() resolves to the JSON value', (tester) async {
    await pumpAppWidget(tester, Builder(builder: (context) => Text(Locales.App.title)));

    // Value comes from assets/translations/en.json: app.title == "Claude Code GUI".
    // If the wrapper does not load EasyLocalization translations, tr() returns
    // the literal key "app.title" and this expect fails — proving the helper.
    expect(find.text('Claude Code GUI'), findsOneWidget);
  });

  testWidgets('sanity: rendering Locales.App.title does NOT show the literal key string — '
      'pins the symmetric failure mode of a partially-loaded translation file', (tester) async {
    await pumpAppWidget(tester, Builder(builder: (context) => Text(Locales.App.title)));

    // If the wrapper failed to load translations, easy_localization returns
    // the raw key (`"app.title"`) on `tr()`. The positive test above only
    // catches the case where the key resolves correctly. This negative
    // assertion catches the case where a different locale loaded but the
    // key is missing — easy_localization would then render the literal key.
    expect(
      find.text('app.title'),
      findsNothing,
      reason: 'A rendered literal key would mean translations did not load.',
    );
  });
}
