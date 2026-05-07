// ignore_for_file: avoid_print,depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Parameter type enum for translation parameters
enum ParamType { string, date, time, plural }

/// Represents a translation parameter
class TranslationParam {
  final String name;
  final ParamType type;

  TranslationParam({required this.name, required this.type});
}

/// Represents plural information for a translation
class PluralInfo {
  final bool isPlural;
  final String countParamName;
  final bool usesNamedPlaceholders;
  final List<String> namedParams;

  PluralInfo({
    required this.isPlural,
    this.countParamName = 'count',
    this.usesNamedPlaceholders = false,
    this.namedParams = const [],
  });
}

/// Generates a Locales class from LocaleKeys.g.dart
///
/// This script reads the generated LocaleKeys file and creates a clean wrapper
/// class that encapsulates the .tr() calls, providing a cleaner API.
///
/// It also auto-detects supported locales from the translation files and
/// generates locale constants.
///
/// Note: This script is usually called by l10n_generate.dart
/// You can also run it directly:
///   dart run lib/core/l10n/tool/generate_locales.dart
void main() {
  print('🚀 Generating Locales class from LocaleKeys...\n');

  // Paths
  final localeKeysPath = 'lib/core/l10n/locale_keys.g.dart';
  final translationsDir = 'assets/translations';
  final outputPath = 'lib/core/l10n/locales.g.dart';

  // Read LocaleKeys file
  final localeKeysFile = File(localeKeysPath);
  if (!localeKeysFile.existsSync()) {
    print('❌ Error: Could not find $localeKeysPath');
    print('   Make sure to run easy_localization:generate first');
    exit(1);
  }

  final content = localeKeysFile.readAsStringSync();
  final keys = _extractKeys(content);

  print('📋 Found ${keys.length} translation keys');

  // Auto-detect supported locales
  final supportedLocales = _detectSupportedLocales(translationsDir);
  print('🌍 Detected locales: ${supportedLocales.join(', ')}');

  // Extract parameter information and plural info
  final paramsAndPlurals = _extractParameters(translationsDir);
  final parameters = paramsAndPlurals['parameters'] as Map<String, List<TranslationParam>>;
  final pluralInfo = paramsAndPlurals['plurals'] as Map<String, PluralInfo>;

  // Generate Locales class
  final generatedContent = _generateLocalesClass(keys, supportedLocales, parameters, pluralInfo);

  // Write to output file
  final outputFile = File(outputPath);
  outputFile.writeAsStringSync(generatedContent);

  print('✅ Generated $outputPath');
  print('   Contains ${keys.length} getter methods');
  print('   Supported locales: ${supportedLocales.join(', ')}');
  print('   Fallback locale: en');
  print('\n🎉 Done! You can now use Locales.keyName instead of LocaleKeys.keyName.tr()');
}

/// Analyzes a plural structure to detect named placeholders
///
/// Scans all plural forms (zero/one/two/few/many/other) and extracts
/// named placeholders like {count}, {name}, etc.
///
/// Returns PluralInfo with:
/// - usesNamedPlaceholders: true if any named placeholders found
/// - namedParams: list of unique parameter names found (excluding 'count')
PluralInfo _analyzePluralStructure(Map<String, dynamic> pluralMap) {
  // Extract all string values from plural keys
  final pluralKeys = ['zero', 'one', 'two', 'few', 'many', 'other'];
  final allValues = <String>[];

  for (final key in pluralKeys) {
    if (pluralMap[key] is String) {
      allValues.add(pluralMap[key] as String);
    }
  }

  // Find all named placeholders: {paramName}
  // Match {word} but not {} (empty braces)
  final namedParamRegex = RegExp(r'\{(\w+)\}');
  final namedParams = <String>{};

  for (final value in allValues) {
    for (final match in namedParamRegex.allMatches(value)) {
      final paramName = match.group(1);
      if (paramName != null && paramName.isNotEmpty) {
        namedParams.add(paramName);
      }
    }
  }

  // Always include 'count' in namedParams for named placeholders
  final hasNamedPlaceholders = namedParams.isNotEmpty;
  if (hasNamedPlaceholders) {
    namedParams.add('count');
  }

  return PluralInfo(
    isPlural: true,
    countParamName: 'count',
    usesNamedPlaceholders: hasNamedPlaceholders,
    namedParams: namedParams.toList()..sort(), // Sort for consistency
  );
}

/// Extracts parameter information and plural information from JSON translation files
/// Returns a map with 'parameters' and 'plurals' entries
Map<String, dynamic> _extractParameters(String translationsDir) {
  final paramsMap = <String, List<TranslationParam>>{};
  final pluralsMap = <String, PluralInfo>{};

  // Read the first locale file (en.json) to extract parameter info
  final enFile = File('$translationsDir/en.json');
  if (!enFile.existsSync()) {
    print('⚠️  Warning: en.json not found, no parameters detected');
    return {'parameters': paramsMap, 'plurals': pluralsMap};
  }

  final jsonContent = enFile.readAsStringSync();
  final Map<String, dynamic> translations = json.decode(jsonContent);

  // Regex to find {paramName} patterns
  final paramRegex = RegExp(r'\{(\w+)\}');

  // Recursively extract parameters from nested structures
  void extractFromMap(Map<String, dynamic> map, String prefix) {
    for (final entry in map.entries) {
      final key = prefix.isEmpty ? entry.key : '${prefix}_${entry.key}';
      final value = entry.value;

      if (value is String) {
        final matches = paramRegex.allMatches(value);
        if (matches.isNotEmpty) {
          final params = <TranslationParam>[];
          for (final match in matches) {
            final paramName = match.group(1)!;
            final paramType = _inferParameterType(paramName);
            params.add(TranslationParam(name: paramName, type: paramType));
          }
          paramsMap[key] = params;
        }
      } else if (value is Map<String, dynamic>) {
        // Check if this is a plural structure
        if (value.containsKey('one') && value.containsKey('other')) {
          // Analyze the plural structure to detect placeholder types
          pluralsMap[key] = _analyzePluralStructure(value);

          // Extract parameters from the 'one' and 'other' strings
          final oneStr = value['one'] as String?;
          final otherStr = value['other'] as String?;
          final params = <TranslationParam>{};

          if (oneStr != null) {
            final matches = paramRegex.allMatches(oneStr);
            for (final match in matches) {
              final paramName = match.group(1)!;
              if (paramName != 'count') {
                final paramType = _inferParameterType(paramName);
                params.add(TranslationParam(name: paramName, type: paramType));
              }
            }
          }

          if (otherStr != null) {
            final matches = paramRegex.allMatches(otherStr);
            for (final match in matches) {
              final paramName = match.group(1)!;
              if (paramName != 'count') {
                final paramType = _inferParameterType(paramName);
                params.add(TranslationParam(name: paramName, type: paramType));
              }
            }
          }

          // Store parameters if any exist (other than 'count')
          if (params.isNotEmpty) {
            paramsMap[key] = params.toList();
          }
        } else {
          // Recursively process nested maps
          extractFromMap(value, key);
        }
      }
    }
  }

  extractFromMap(translations, '');

  print('📊 Found ${paramsMap.length} keys with parameters');
  print('📊 Found ${pluralsMap.length} keys with plurals');
  return {'parameters': paramsMap, 'plurals': pluralsMap};
}

/// Infers the parameter type based on naming conventions
ParamType _inferParameterType(String paramName) {
  // DateTime detection
  if (paramName.toLowerCase().contains('date')) return ParamType.date;
  if (paramName.toLowerCase().contains('time')) return ParamType.time;

  // Numeric detection
  if (paramName.toLowerCase().contains('count')) return ParamType.string;

  // Default to string
  return ParamType.string;
}

/// Auto-detects supported locales from translation files
List<String> _detectSupportedLocales(String translationsDir) {
  final dir = Directory(translationsDir);
  if (!dir.existsSync()) {
    print('⚠️  Warning: Translations directory not found: $translationsDir');
    print('   Using default locales: en, it');
    return ['en', 'it'];
  }

  final locales = <String>[];
  final files = dir.listSync().where((file) => file.path.endsWith('.json'));

  for (final file in files) {
    final filename = path.basename(file.path);
    final locale = filename.replaceAll('.json', '');
    locales.add(locale);
  }

  // Sort to ensure consistent ordering (en first)
  locales.sort((a, b) {
    if (a == 'en') return -1;
    if (b == 'en') return 1;
    return a.compareTo(b);
  });

  return locales;
}

/// Extracts all translation keys from LocaleKeys content
List<String> _extractKeys(String content) {
  final allKeys = <String, String>{}; // key -> value mapping
  final regex = RegExp(r"static const (\w+) = '([^']+)';");
  final matches = regex.allMatches(content);

  // First pass: collect all keys and their values
  for (final match in matches) {
    final key = match.group(1);
    final value = match.group(2);
    if (key != null && value != null) {
      allKeys[key] = value;
    }
  }

  // Second pass: filter out parent-only keys
  // A key is a "parent-only" key if it has children (keys with pattern "keyName_*")
  // Examples:
  // - "auth" with children "auth_email", "auth_password" → parent, skip it
  // - "news_newNews" with children "news_newNews_label", "news_newNews_title" → parent, skip it
  // - "pageNotFound" with no children → leaf, keep it
  final keys = <String>[];
  for (final entry in allKeys.entries) {
    final key = entry.key;

    // Check if this key has children (any key that starts with "thisKey_")
    final hasChildren = allKeys.keys.any((k) => k != key && k.startsWith('${key}_'));

    if (!hasChildren) {
      // This is a leaf node (no children) - include it
      keys.add(key);
    }
    // If hasChildren is true, skip it (it's a parent-only key)
  }

  return keys;
}

/// Generates the Locales class content with nested classes
String _generateLocalesClass(
  List<String> keys,
  List<String> supportedLocales,
  Map<String, List<TranslationParam>> parameters,
  Map<String, PluralInfo> pluralInfo,
) {
  final buffer = StringBuffer();

  // Header
  buffer.writeln('// AUTO-GENERATED FILE - DO NOT EDIT');
  buffer.writeln('// Generated by lib/core/l10n/tool/generate_locales.dart');
  buffer.writeln('//');
  buffer.writeln('// This file provides a clean API for accessing translations');
  buffer.writeln('// without needing to call .tr() explicitly.');
  buffer.writeln('//');
  buffer.writeln('// Usage: Locales.Auth.email instead of LocaleKeys.auth_email.tr()');
  buffer.writeln('//');
  buffer.writeln('// NOTE: LocaleKeys is intentionally NOT exported from l10n.dart.');
  buffer.writeln('// Always use Locales for type-safe translations!');
  buffer.writeln();
  buffer.writeln("// ignore_for_file: no_hardcoded_strings, constant_identifier_names, non_constant_identifier_names");
  buffer.writeln();
  buffer.writeln("import 'package:easy_localization/easy_localization.dart';");
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln();
  buffer.writeln("import 'locale_keys.g.dart';");
  buffer.writeln();

  // Organize keys into a tree structure (pass pluralInfo as well)
  final keyTree = _organizeKeysIntoTree(keys, parameters, pluralInfo);

  // Class doc
  buffer.writeln('/// Provides clean access to all translations without .tr() calls.');
  buffer.writeln('///');
  buffer.writeln('/// This class is auto-generated from LocaleKeys.g.dart.');
  buffer.writeln('/// To regenerate, run: dart run lib/core/l10n/tool/l10n_generate.dart');
  buffer.writeln('///');
  buffer.writeln('/// Supported locales: ${supportedLocales.join(', ')}');
  buffer.writeln('/// Fallback locale: en');
  buffer.writeln('///');
  buffer.writeln('/// Usage:');
  buffer.writeln('/// ```dart');
  buffer.writeln('/// Text(Locales.Auth.email)  // Nested access!');
  buffer.writeln('/// Text(Locales.pageNotFound)  // Root level access');
  buffer.writeln('///');
  buffer.writeln('/// // Access locale constants');
  buffer.writeln('/// supportedLocales: Locales.supportedLocales');
  buffer.writeln('/// fallbackLocale: Locales.fallbackLocale');
  buffer.writeln('/// ```');
  buffer.writeln('abstract class Locales {');
  buffer.writeln('  /// Supported locales auto-detected from translation files');
  buffer.write('  static const List<Locale> supportedLocales = [');
  buffer.write(supportedLocales.map((locale) => "Locale('$locale')").join(', '));
  buffer.writeln('];');
  buffer.writeln();
  buffer.writeln('  /// Fallback locale (default)');
  buffer.writeln("  static const Locale fallbackLocale = Locale('en');");
  buffer.writeln();

  // Generate root-level getters first
  final rootKeys = keyTree['_root'] as Map<String, dynamic>;
  if (rootKeys.isNotEmpty) {
    buffer.writeln('  // Root-level translations');
    _generateRootContent(buffer, rootKeys, '', pluralInfo);
    buffer.writeln();
  }

  // Generate nested class field declarations
  final nestedKeys = keyTree['_nested'] as Map<String, dynamic>;
  if (nestedKeys.isNotEmpty) {
    buffer.writeln('  // Nested translations');
    _generateNestedClassFields(buffer, nestedKeys);
  }

  buffer.writeln('}');
  buffer.writeln();

  // Generate nested class implementations outside the main class
  if (nestedKeys.isNotEmpty) {
    _generateNestedClassImplementations(buffer, nestedKeys, '', pluralInfo);
  }

  return buffer.toString();
}

/// Organizes flat keys into a tree structure, separating root and nested keys.
/// Stores either parameters (List of TranslationParam) or plural info (PluralInfo)
Map<String, dynamic> _organizeKeysIntoTree(
  List<String> keys,
  Map<String, List<TranslationParam>> parameters,
  Map<String, PluralInfo> pluralInfo,
) {
  final tree = <String, dynamic>{
    '_root': <String, dynamic>{}, // Special key for root-level keys
    '_nested': <String, dynamic>{}, // Nested keys
  };

  for (final key in keys) {
    final parts = key.split('_');

    // Determine what to store: plural info takes precedence over parameters
    final value = pluralInfo.containsKey(key)
        ? pluralInfo[key]
        : (parameters.containsKey(key) ? parameters[key] : null);

    if (parts.length == 1) {
      // Root level key - store in _root
      tree['_root'][key] = value;
    } else {
      // Nested key - build tree structure in _nested
      var current = tree['_nested'] as Map<String, dynamic>;
      for (var i = 0; i < parts.length - 1; i++) {
        final part = parts[i];
        current[part] ??= <String, dynamic>{};
        current = current[part] as Map<String, dynamic>;
      }
      final lastPart = parts.last;
      current[lastPart] = value;
    }
  }

  return tree;
}

/// Generates root-level content (static methods and nested class fields)
void _generateRootContent(
  StringBuffer buffer,
  Map<String, dynamic> tree,
  String prefix,
  Map<String, PluralInfo> pluralInfo,
) {
  final indent = '  ';
  final entries = tree.entries.toList()
    ..sort((a, b) {
      // Put nested classes (Maps) at the end
      if (a.value is Map && b.value is! Map) return 1;
      if (a.value is! Map && b.value is Map) return -1;
      return a.key.compareTo(b.key);
    });

  for (final entry in entries) {
    final key = entry.key;
    final value = entry.value;
    final fullKey = prefix.isEmpty ? key : '${prefix}_$key';

    if (value is PluralInfo) {
      // Generate plural method
      final params = <TranslationParam>[]; // Plurals don't have other params by default
      buffer.writeln(_generatePluralMethod(key, fullKey, params, 1, true, value));
    } else if (value is List<TranslationParam>) {
      // Generate parameterized method
      buffer.writeln(_generateParameterizedMethod(key, fullKey, value, 1, true));
    } else {
      // Generate simple getter
      buffer.writeln('${indent}static String get ${_safeIdentifier(key)} => LocaleKeys.$fullKey.tr();');
    }
  }
}

/// Generates nested class field declarations (static const instances)
void _generateNestedClassFields(StringBuffer buffer, Map<String, dynamic> tree) {
  final indent = '  ';
  final entries = tree.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

  for (final entry in entries) {
    final key = entry.key;
    final className = _capitalize(key);
    buffer.writeln('$indent/// Translations for $key');
    buffer.writeln('${indent}static const $className = _$className._();');
    buffer.writeln();
  }
}

/// Generates nested class implementations outside the main Locales class
void _generateNestedClassImplementations(
  StringBuffer buffer,
  Map<String, dynamic> tree,
  String prefix,
  Map<String, PluralInfo> pluralInfo,
) {
  final entries = tree.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

  for (final entry in entries) {
    final key = entry.key;
    final value = entry.value as Map<String, dynamic>;
    final className = _capitalize(key);
    final fullKey = prefix.isEmpty ? key : '${prefix}_$key';

    buffer.writeln('/// Nested class for $key translations');
    buffer.writeln('class _$className {');
    buffer.writeln('  const _$className._();');
    buffer.writeln();

    // Generate methods for this class
    _generateNestedClassContent(buffer, value, fullKey, null, pluralInfo);

    buffer.writeln('}');
    buffer.writeln();

    // Recursively generate nested classes within this class
    _generateNestedClassImplementationsRecursive(buffer, value, fullKey, pluralInfo);
  }
}

/// Recursively generates nested class implementations for Maps found within nested classes
void _generateNestedClassImplementationsRecursive(
  StringBuffer buffer,
  Map<String, dynamic> tree,
  String prefix,
  Map<String, PluralInfo> pluralInfo,
) {
  final entries = tree.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

  for (final entry in entries) {
    final key = entry.key;
    final value = entry.value;

    if (value is Map<String, dynamic>) {
      // Generate unique class name by combining parent path with key
      // This prevents conflicts like mka.shared and booking.shared both becoming _Shared
      final className = _generateUniqueClassName(prefix, key);
      final fullKey = prefix.isEmpty ? key : '${prefix}_$key';

      buffer.writeln('/// Nested class for $key translations');
      buffer.writeln('class _$className {');
      buffer.writeln('  const _$className._();');
      buffer.writeln();

      // Generate methods for this nested class
      _generateNestedClassContent(buffer, value, fullKey, className, pluralInfo);

      buffer.writeln('}');
      buffer.writeln();

      // Continue recursion
      _generateNestedClassImplementationsRecursive(buffer, value, fullKey, pluralInfo);
    }
  }
}

/// Generates content for nested classes (instance methods for const instances)
void _generateNestedClassContent(
  StringBuffer buffer,
  Map<String, dynamic> tree,
  String prefix, [
  String? parentClassName,
  Map<String, PluralInfo>? pluralInfo,
]) {
  final indent = '  ';
  final entries = tree.entries.toList()
    ..sort((a, b) {
      // Put nested classes (Maps) at the end
      if (a.value is Map && b.value is! Map) return 1;
      if (a.value is! Map && b.value is Map) return -1;
      return a.key.compareTo(b.key);
    });

  for (final entry in entries) {
    final key = entry.key;
    final value = entry.value;
    final fullKey = prefix.isEmpty ? key : '${prefix}_$key';

    if (value is PluralInfo) {
      // Generate plural method (instance method for const instances)
      final params = <TranslationParam>[];
      buffer.writeln(_generatePluralMethod(key, fullKey, params, 1, false, value));
    } else if (value is List<TranslationParam>) {
      // Generate parameterized method (instance method for const instances)
      buffer.writeln(_generateParameterizedMethod(key, fullKey, value, 1, false));
    } else if (value is Map<String, dynamic>) {
      // Generate final field reference to nested class (accessible through instance)
      // Use unique class name to avoid conflicts
      final className = _generateUniqueClassName(prefix, key);
      buffer.writeln('$indent/// Translations for $key');
      buffer.writeln('${indent}final ${_capitalize(key)} = const _$className._();');
      buffer.writeln();
    } else {
      // Generate simple getter (instance method for const instances)
      buffer.writeln('${indent}String get ${_safeIdentifier(key)} => LocaleKeys.$fullKey.tr();');
    }
  }
}

/// Dart reserved words that cannot be used as identifiers.
/// When a JSON key collides with one, append a `$` suffix to make it valid.
const _dartReservedWords = <String>{
  'assert',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'default',
  'do',
  'else',
  'enum',
  'extends',
  'false',
  'final',
  'finally',
  'for',
  'if',
  'in',
  'is',
  'new',
  'null',
  'rethrow',
  'return',
  'super',
  'switch',
  'this',
  'throw',
  'true',
  'try',
  'var',
  'void',
  'while',
  'with',
};

/// Returns a safe Dart identifier for a JSON key. Reserved words get `$` suffix.
String _safeIdentifier(String key) => _dartReservedWords.contains(key) ? '$key\$' : key;

/// Capitalizes the first letter of a string
String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

/// Generates a unique class name by combining the prefix path with the key
/// This prevents naming conflicts when different features have nested sections with the same name
/// For example: mka_shared -> MkaShared, booking_shared -> BookingShared
String _generateUniqueClassName(String prefix, String key) {
  if (prefix.isEmpty) {
    return _capitalize(key);
  }

  // Convert prefix from snake_case to PascalCase and append the key
  final parts = prefix.split('_');
  final parentName = parts.map(_capitalize).join('');
  return '$parentName${_capitalize(key)}';
}

/// Generates a method for a parameterized translation
String _generateParameterizedMethod(
  String methodName,
  String localeKey,
  List<TranslationParam> params,
  int indentLevel,
  bool isRootLevel,
) {
  final buffer = StringBuffer();
  final indent = '  ' * indentLevel;
  final staticModifier = isRootLevel ? 'static ' : '';

  // Check if we have any date/time parameters
  final hasDateTimeParams = params.any((p) => p.type == ParamType.date || p.type == ParamType.time);

  // Build method signature
  buffer.write('$indent${staticModifier}String $methodName({');

  // Generate parameters
  final methodParams = <String>[];
  for (final param in params) {
    final dartType = _getDartType(param.type);
    methodParams.add('required $dartType ${param.name}');
  }

  // Add locale parameter if we have DateTime params
  if (hasDateTimeParams) {
    methodParams.add('required String locale');
  }

  buffer.write(methodParams.join(', '));
  buffer.writeln('}) {');

  // Build namedArgs map
  buffer.writeln('$indent  return LocaleKeys.$localeKey.tr(namedArgs: {');
  for (final param in params) {
    final formattedValue = _formatParameterValue(param);
    buffer.writeln("$indent    '${param.name}': $formattedValue,");
  }
  buffer.writeln('$indent  });');
  buffer.writeln('$indent}');

  return buffer.toString();
}

/// Generates a method for a plural translation
/// Plural translations use the `.plural(count)` syntax from easy_localization
String _generatePluralMethod(
  String methodName,
  String localeKey,
  List<TranslationParam> params,
  int indentLevel,
  bool isRootLevel, [
  PluralInfo? pluralInfo,
]) {
  final buffer = StringBuffer();
  final indent = '  ' * indentLevel;
  final staticModifier = isRootLevel ? 'static ' : '';

  // Build method signature
  buffer.write('$indent${staticModifier}String $methodName({required int count');

  // Add additional parameters if any
  for (final param in params) {
    final dartType = _getDartType(param.type);
    buffer.write(', required $dartType ${param.name}');
  }

  buffer.writeln('}) {');

  // Generate plural call with namedArgs if needed
  final hasNamedPlaceholders = pluralInfo?.usesNamedPlaceholders ?? false;

  if (params.isEmpty && !hasNamedPlaceholders) {
    // Simple plural with {} placeholder (current behavior)
    buffer.writeln('$indent  return LocaleKeys.$localeKey.plural(count);');
  } else if (hasNamedPlaceholders && params.isEmpty) {
    // Plural with named placeholders but no additional params
    // Generate with namedArgs for the named placeholders
    final namedArgsEntries = (pluralInfo?.namedParams ?? []).map((param) => "'$param': '\$$param'").join(', ');
    if (namedArgsEntries.isNotEmpty) {
      buffer.writeln('$indent  return LocaleKeys.$localeKey.plural(count, namedArgs: {$namedArgsEntries});');
    } else {
      buffer.writeln('$indent  return LocaleKeys.$localeKey.plural(count);');
    }
  } else {
    // Has additional parameters or named placeholders
    buffer.writeln('$indent  return LocaleKeys.$localeKey.plural(count, namedArgs: {');

    // Add named placeholder params first
    if (hasNamedPlaceholders) {
      for (final param in (pluralInfo?.namedParams ?? [])) {
        buffer.writeln("$indent    '$param': '\$$param',");
      }
    }

    // Add additional parameters
    for (final param in params) {
      final formattedValue = _formatParameterValue(param);
      buffer.writeln("$indent    '${param.name}': $formattedValue,");
    }
    buffer.writeln('$indent  });');
  }

  buffer.writeln('$indent}');

  return buffer.toString();
}

/// Gets the Dart type for a parameter type
String _getDartType(ParamType type) {
  return switch (type) {
    ParamType.date || ParamType.time => 'DateTime',
    ParamType.string => 'String',
    ParamType.plural => 'String', // Should not be used as param type
  };
}

/// Formats a parameter value for the namedArgs map
String _formatParameterValue(TranslationParam param) {
  return switch (param.type) {
    ParamType.date => "DateFormat.yMd(locale).format(${param.name})",
    ParamType.time => "DateFormat.Hm(locale).format(${param.name})",
    ParamType.string => param.name,
    ParamType.plural => param.name, // Should not be used
  };
}
