// Contracts for parseFrontmatter (lib/core/utils/frontmatter.dart).
//
// Used by the slash-commands datasource to read metadata from `.md` command
// files. A regression here misclassifies all user/project commands.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/utils/frontmatter.dart';

void main() {
  group('parseFrontmatter — delimiters', () {
    test('content without leading "---\\n" returns an empty map', () {
      expect(parseFrontmatter('description: foo\n'), isEmpty);
    });

    test('content with leading "---\\n" but no closing "\\n---\\n" returns empty', () {
      expect(parseFrontmatter('---\ndescription: foo\n'), isEmpty);
    });

    test('an empty frontmatter block returns an empty map', () {
      expect(parseFrontmatter('---\n\n---\nbody'), isEmpty);
    });

    test('CRLF line endings are NOT supported by the current parser', () {
      // The parser hardcodes \n as separator. Documenting this so future
      // changes that touch the regex are aware. macOS-only app today, but
      // any cross-platform fixture would need normalization upstream.
      const crlf = '---\r\ndescription: foo\r\n---\r\nbody';
      expect(parseFrontmatter(crlf), isEmpty, reason: 'CRLF input is not supported — confirms current contract.');
    });
  });

  group('parseFrontmatter — key/value extraction', () {
    test('simple key: value pairs are extracted', () {
      const input = '---\ndescription: my command\nargument-hint: <path>\n---\nbody';
      expect(parseFrontmatter(input), {'description': 'my command', 'argument-hint': '<path>'});
    });

    test('values surrounded by double quotes have quotes stripped', () {
      const input = '---\ndescription: "my command"\n---\nbody';
      expect(parseFrontmatter(input), {'description': 'my command'});
    });

    test('values surrounded by single quotes have quotes stripped', () {
      const input = "---\ndescription: 'my command'\n---\nbody";
      expect(parseFrontmatter(input), {'description': 'my command'});
    });

    test('mismatched quotes are kept verbatim', () {
      // Quote stripping requires both ends to match. Otherwise the value is
      // taken as-is — important so a stray quote in user content does not
      // silently swallow neighboring characters.
      const input = '---\ndescription: "broken\n---\nbody';
      expect(parseFrontmatter(input), {'description': '"broken'});
    });

    test('values are trimmed of surrounding whitespace', () {
      const input = '---\ndescription:   spaced out   \n---\nbody';
      expect(parseFrontmatter(input), {'description': 'spaced out'});
    });

    test('lines without a colon are skipped', () {
      const input = '---\ndescription: foo\nthis line has no colon\nallowed-tools: read,write\n---\nbody';
      expect(parseFrontmatter(input), {'description': 'foo', 'allowed-tools': 'read,write'});
    });

    test('empty key (line starting with colon) is dropped', () {
      const input = '---\n: orphan\ndescription: foo\n---\nbody';
      expect(parseFrontmatter(input), {'description': 'foo'});
    });

    test('value containing a colon keeps everything after the first colon', () {
      const input = '---\nurl: https://example.com:8080/path\n---\nbody';
      expect(parseFrontmatter(input), {'url': 'https://example.com:8080/path'});
    });

    test('duplicate keys: last value wins (LinkedHashMap default)', () {
      const input = '---\ndescription: first\ndescription: second\n---\nbody';
      expect(parseFrontmatter(input), {'description': 'second'});
    });
  });
}
