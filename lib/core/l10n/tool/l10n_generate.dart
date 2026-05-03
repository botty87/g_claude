// ignore_for_file: avoid_print, no_hardcoded_strings

import 'dart:io';

/// Unified script to generate all localization files
///
/// This script performs two steps:
/// 1. Generates LocaleKeys from JSON translation files using easy_localization
/// 2. Generates Locales wrapper class from LocaleKeys
///
/// Usage:
///   dart run lib/core/l10n/tool/l10n_generate.dart
void main() async {
  print('🚀 Starting localization generation...\n');

  // Run from project root (where pubspec.yaml lives).
  if (!File('pubspec.yaml').existsSync()) {
    print('❌ Error: must be run from project root (pubspec.yaml not found in CWD).');
    exit(1);
  }

  // Step 1: Generate LocaleKeys from translations

  print('📝 Step 1/2: Generating LocaleKeys from JSON translations...');
  final easyLocResult = await Process.run('dart', [
    'run',
    'easy_localization:generate',
    '-S',
    'assets/translations',
    '-o',
    'locale_keys.g.dart',
    '-O',
    'lib/core/l10n',
    '-f',
    'keys',
  ]);

  if (easyLocResult.exitCode != 0) {
    print('❌ Error generating LocaleKeys:');
    print(easyLocResult.stderr);
    exit(1);
  }

  print('✅ LocaleKeys generated successfully');

  print('');

  // Step 2: Generate Locales wrapper

  print('📝 Step 2/2: Generating Locales wrapper class...');
  final localesResult = await Process.run('dart', ['run', 'lib/core/l10n/tool/generate_locales.dart']);

  if (localesResult.exitCode != 0) {
    print('❌ Error generating Locales:');
    print(localesResult.stderr);
    exit(1);
  }

  // Print output from generate_locales.dart
  print(localesResult.stdout);

  print('\n🎉 All localization files generated successfully!');
  print('\n📦 Generated files:');
  print('   - lib/core/l10n/locale_keys.g.dart');
  print('   - lib/core/l10n/locales.g.dart');
  print('\n💡 You can now use: Locales.keyName in your code');
}
