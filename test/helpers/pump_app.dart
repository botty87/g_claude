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
Future<void> pumpAppWidget(WidgetTester tester, Widget child, {Locale? locale, ThemeData? theme}) async {
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
      child: _LocalizedHost(theme: theme, child: child),
    ),
  );

  // EasyLocalization loads translations asynchronously: settle so the first
  // resolved frame replaces the loading placeholder.
  await tester.pumpAndSettle();
}

class _LocalizedHost extends StatelessWidget {
  const _LocalizedHost({required this.child, this.theme});

  final Widget child;
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: Scaffold(body: child),
    );
  }
}

/// Loads translations via `rootBundle` so tests see the same JSON the app ships.
class RootBundleAssetLoader extends AssetLoader {
  const RootBundleAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final raw = await rootBundle.loadString('$path/${locale.languageCode}.json');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}
