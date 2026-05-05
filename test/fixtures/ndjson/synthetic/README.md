# Synthetic NDJSON fixtures

Fixtures here are **constructed by hand** because the corresponding event
cannot be triggered deterministically against a real `claude -p` run.

For these fixtures:

- The shape mirrors what production code actually emits. Each fixture
  documents the source of its shape (commit / observed run / spec).
- Tests that consume them must declare in their description that the
  fixture is synthetic, so a future reader knows which contract is being
  asserted (parser robustness vs. real-world contract).
- If a real capture later becomes available, **prefer it**: replace the
  synthetic file and remove the corresponding entry here.

| File                       | Why synthetic                                                                         | Source of shape                                                  |
|----------------------------|---------------------------------------------------------------------------------------|------------------------------------------------------------------|
| `with_rate_limit.ndjson`   | `rate_limit_event` only fires when the API rate-limits the user — not deterministic. | `claude_process_datasource.dart` lines 526–531 (parser contract). |
