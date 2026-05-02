import 'package:freezed_annotation/freezed_annotation.dart';

part 'mcp_server.freezed.dart';

enum McpServerStatus {
  connected,
  failed,
  needsAuth,
  unknown,
}

@freezed
abstract class McpServer with _$McpServer {
  const factory McpServer({
    required String name,
    required String displayName,
    required String commandOrUrl,
    required McpServerStatus status,
  }) = _McpServer;
}
