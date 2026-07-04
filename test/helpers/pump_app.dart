import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps [child] with the `EasyLocalization` tree used by the production app
/// so widget tests that call `Locales.X.y.tr()` resolve translations via the
/// real JSON shipped under `assets/translations/`.
///
/// Without this wrapper, `tr()` lookups fail because the easy_localization
/// `Localization` instance is missing from the context.
///
/// [appBuilder] plugs into `MaterialApp.builder`, i.e. it wraps the
/// `Navigator` itself rather than just the home route's content. Use it to
/// provide ambient state (e.g. a `BlocProvider`) that must also reach widgets
/// pushed via `showDialog`/`Navigator.push` — those routes are siblings of
/// the home route inside the Overlay, so a provider placed only around
/// [child] would not be visible to them.
Future<void> pumpAppWidget(
  WidgetTester tester,
  Widget child, {
  Locale? locale,
  ThemeData? theme,
  TransitionBuilder? appBuilder,
}) async {
  // EasyLocalization persists the active locale via SharedPreferences. Under
  // `flutter_test` the platform plugin is not registered, so the call hangs
  // inside a FutureBuilder and `pumpAndSettle` never returns. Mocking the
  // backing store is enough to unstick it.
  SharedPreferences.setMockInitialValues(<String, Object>{});

  await EasyLocalization.ensureInitialized();

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: Locales.supportedLocales,
      path: 'assets/translations',
      fallbackLocale: Locales.fallbackLocale,
      startLocale: locale ?? Locales.fallbackLocale,
      useOnlyLangCode: true,
      assetLoader: const RootBundleAssetLoader(),
      child: _LocalizedHost(theme: theme, appBuilder: appBuilder, child: child),
    ),
  );

  // EasyLocalization loads translations asynchronously: settle so the first
  // resolved frame replaces the loading placeholder.
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

class _LocalizedHost extends StatelessWidget {
  const _LocalizedHost({required this.child, this.theme, this.appBuilder});

  final Widget child;
  final ThemeData? theme;
  final TransitionBuilder? appBuilder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: appBuilder,
      home: Scaffold(body: child),
    );
  }
}

/// Loads translations via `rootBundle` so tests see the same JSON the app ships.
///
/// Caches the decoded JSON per `path/locale` in a process-wide static map.
/// Without this, a *second* `pumpAppWidget` call in the same test file hangs
/// forever: `TestWidgetsFlutterBinding` tears down the `flutter/assets`
/// channel's mock handler between tests, so a repeat `rootBundle.loadString`
/// call never receives a reply and `EasyLocalization`'s loading Future never
/// resolves — the widget tree gets stuck showing its `SizedBox.shrink()`
/// "not loaded yet" placeholder. Every existing multi-`testWidgets` file only
/// ever asserted *absence* (`findsNothing`) in its 2nd+ test, which is also
/// vacuously true against a stuck-empty tree, so this went unnoticed.
class RootBundleAssetLoader extends AssetLoader {
  const RootBundleAssetLoader();

  static final Map<String, Map<String, dynamic>> _cache = {};

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final key = '$path/${locale.languageCode}.json';
    final cached = _cache[key];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(key);
    final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    _cache[key] = decoded;
    return decoded;
  }
}
