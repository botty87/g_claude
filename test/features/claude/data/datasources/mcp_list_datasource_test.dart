import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/data/datasources/mcp_list_datasource.dart';
import 'package:g_claude/features/claude/domain/entities/mcp_server.dart';

const _sampleOutput = '''
Checking MCP server health…

claude.ai ClickUp: https://mcp.clickup.com/mcp - ✓ Connected
claude.ai n8n: https://jarvis.imagonist.com/mcp-server/http - ✗ Failed to connect
claude.ai Microsoft 365: https://microsoft365.mcp.claude.com/mcp - ! Needs authentication
claude.ai Fireflies: https://api.fireflies.ai/mcp - ✓ Connected
plugin:firebase:firebase: npx -y firebase-tools mcp --dir . - ✓ Connected
context7: npx -y @upstash/context7-mcp - ✓ Connected
figma: npx -y figma-developer-mcp --figma-api-key=KEY --stdio - ✓ Connected
stitch: https://stitch.googleapis.com/mcp (HTTP) - ✓ Connected
maestro: maestro mcp - ✓ Connected
dart: dart mcp-server - ✓ Connected
marionette: marionette_mcp  - ✓ Connected
''';

void main() {
  group('McpListDataSource.parseOutput', () {
    test('happy path — parses full sample output and returns 11 servers', () {
      final servers = McpListDataSource.parseOutput(_sampleOutput);
      expect(servers, hasLength(11));
    });

    test('plugin prefix is stripped from displayName, name is preserved', () {
      const input = 'plugin:firebase:firebase: npx -y firebase-tools mcp --dir . - ✓ Connected\n';
      final servers = McpListDataSource.parseOutput(input);
      expect(servers, hasLength(1));
      expect(servers.first.name, equals('plugin:firebase:firebase'));
      expect(servers.first.displayName, equals('firebase'));
    });

    test('claude.ai prefix is stripped from displayName', () {
      const input = 'claude.ai ClickUp: https://mcp.clickup.com/mcp - ✓ Connected\n';
      final servers = McpListDataSource.parseOutput(input);
      expect(servers, hasLength(1));
      expect(servers.first.name, equals('claude.ai ClickUp'));
      expect(servers.first.displayName, equals('ClickUp'));
    });

    test('status markers map to correct McpServerStatus values', () {
      const input = '''
claude.ai ClickUp: https://mcp.clickup.com/mcp - ✓ Connected
claude.ai n8n: https://jarvis.imagonist.com/mcp-server/http - ✗ Failed to connect
claude.ai Microsoft 365: https://microsoft365.mcp.claude.com/mcp - ! Needs authentication
unknown-server: some-cmd - some-unknown-marker
''';
      final servers = McpListDataSource.parseOutput(input);
      expect(servers, hasLength(4));
      expect(servers[0].status, equals(McpServerStatus.connected));
      expect(servers[1].status, equals(McpServerStatus.failed));
      expect(servers[2].status, equals(McpServerStatus.needsAuth));
      expect(servers[3].status, equals(McpServerStatus.unknown));
    });

    test('noisy lines are ignored — header, empty lines, non-matching lines', () {
      const input = '''
Checking MCP server health…

context7: npx -y @upstash/context7-mcp - ✓ Connected

this line has no separator

''';
      final servers = McpListDataSource.parseOutput(input);
      expect(servers, hasLength(1));
      expect(servers.first.name, equals('context7'));
    });

    test('trailing whitespace in commandOrUrl is trimmed', () {
      const input = 'marionette: marionette_mcp  - ✓ Connected\n';
      final servers = McpListDataSource.parseOutput(input);
      expect(servers, hasLength(1));
      expect(servers.first.commandOrUrl, equals('marionette_mcp'));
    });
  });
}
