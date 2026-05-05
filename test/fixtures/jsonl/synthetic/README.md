# Synthetic JSONL fixtures

These fixtures emulate the shape of files written by `claude` to
`~/.claude/projects/{cwd-encoded}/{sessionid}.jsonl`. They are synthetic
because the harness sandbox prevents direct copy from the user's real
history directory (sensitive-file guard).

## Provenance

Shapes verified against real production JSONL on 2026-05-05 using `jq`
inspection on `~/.claude/projects/` files (without copying). Concretely:

- **Top-level keys observed**: `type, isSidechain, isMeta, message,
  timestamp, uuid, parentUuid, sessionId, summary, snapshot, isSnapshotUpdate,
  permissionMode, gitBranch, version, entrypoint, userType, messageId, cwd`.
- **Top-level `type` values observed**: `user, assistant, summary, system,
  queue-operation, permission-mode, file-history-snapshot`.
- **`message.content` variants observed**: `String` (plain text), or `Array`
  of blocks where each block is `{type: text, text: ...}` or
  `{type: tool_use, id, name, input}` or `{type: tool_result, tool_use_id,
  content, is_error?}`.

If you discover a previously unseen shape in production, **add a fixture for
it here and a contract test for it** — do not patch existing fixtures.

## Index

| File                         | What it pins                                                      |
|------------------------------|-------------------------------------------------------------------|
| `text_only_session.jsonl`    | user/assistant text turns, scanWorkspace title from first user.   |
| `tool_flow.jsonl`            | Full tool lifecycle: tool_use then matching tool_result.          |
| `orphan_tool.jsonl`          | Tool without matching tool_result → emitted as error at end.      |
| `string_content_user.jsonl`  | `message.content` as raw String (legacy shape, still in the wild).|
| `summary_fallback.jsonl`     | No user message produces a title → fallback to `summary` entry.   |
| `slash_command_title.jsonl`  | Title extraction strips `/cmd` prefix and keeps args only.        |
| `sidechain_meta_filter.jsonl`| isSidechain / isMeta entries filtered from message stream.        |
| `noise_filter.jsonl`         | system / queue-operation / permission-mode / snapshot entries     |
|                              | are ignored without crashing.                                     |
| `mixed_tool_result.jsonl`    | tool_result with content as List → JSON-encoded into output.      |
