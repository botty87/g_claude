import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/presentation/utils/attachment_token.dart';

void main() {
  group('formatAttachmentToken', () {
    test('empty path returns empty string', () {
      expect(formatAttachmentToken(''), '');
    });

    test('simple path without special chars returns @<path>', () {
      expect(
        formatAttachmentToken('/Users/foo/bar.md'),
        '@/Users/foo/bar.md',
      );
    });

    test('path with single space is wrapped in double quotes', () {
      expect(
        formatAttachmentToken('/Users/foo bar/baz.md'),
        '@"/Users/foo bar/baz.md"',
      );
    });

    test('path with tab is wrapped in double quotes', () {
      expect(
        formatAttachmentToken('/Users/foo\tbar/baz.md'),
        '@"/Users/foo\tbar/baz.md"',
      );
    });

    test('path with internal double quote is escaped', () {
      expect(
        formatAttachmentToken('/Users/foo/with"quote.md'),
        r'@"/Users/foo/with\"quote.md"',
      );
    });

    test('path with backslash is escaped', () {
      expect(
        formatAttachmentToken(r'/Users/foo/back\slash.md'),
        r'@"/Users/foo/back\\slash.md"',
      );
    });

    test('path with dollar sign is wrapped in double quotes', () {
      expect(
        formatAttachmentToken(r'/Users/foo/$var/baz.md'),
        r'@"/Users/foo/$var/baz.md"',
      );
    });

    test("path with single quote is wrapped in double quotes", () {
      expect(
        formatAttachmentToken("/Users/foo/it's/baz.md"),
        '@"/Users/foo/it\'s/baz.md"',
      );
    });

    test('path with backtick is wrapped in double quotes', () {
      expect(
        formatAttachmentToken('/Users/foo/`cmd`/baz.md'),
        '@"/Users/foo/`cmd`/baz.md"',
      );
    });

    test('path that is itself wrapped in double quotes re-wraps and escapes', () {
      expect(
        formatAttachmentToken('"foo"'),
        r'@"\"foo\""',
      );
    });
  });
}
