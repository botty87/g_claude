# Controlli modello (thinking, effort, contesto 1M): da riallineare ai modelli attuali

Emerso dal prompt audit del 2026-09-23 (PR `docs(claude)`). Il progetto è in stallo: i task restano parcheggiati qui finché non riparte.

## Contesto verificato
- Gli alias della CLI dell'utente (`~/.local/bin/claude` 2.1.280) risolvono così: `opus` → `claude-opus-5-5`, `sonnet` → `claude-sonnet-5`, `haiku` → `claude-haiku-4-5-20251001`.
- **Opus 5.5**: il thinking non si può disattivare. `thinking: {type: 'disabled'}` viene assorbito dalla CLI e il modello pensa comunque (la probe restituisce un blocco `thinking` firmato). L'unica leva è l'effort.
- **Haiku 4.5**: l'API rifiuta `effort`, la CLI lo scarta senza segnalarlo, quindi il selettore non ha effetto.
- **Contesto 1M**: è nativo su Sonnet 5 e Opus. La beta `context-1m-2025-08-07` serviva per Sonnet 4/4.5.

## Task
- [ ] **Thinking Off su Opus → effort `low`**: in `backend/src/session.ts:122-125` il ramo `thinking === false` oggi manda `disabled`. Se il modello è `opus`, deve lasciare adaptive e impostare effort `low`. Va aggiornato anche il testo o il tooltip del toggle, perché oggi promette "Off".
- [ ] **Effort su Haiku**: disabilitare il selettore di effort quando il modello è `haiku` (`claude_effort.dart` e UI dei controlli).
- [ ] **Rimuovere la beta 1M** (`oneMillionBetas` e il suo call site in `session.ts:57-65,126-127`), poi correggere il commento di `ClaudeModelContext.contextLimit` in `claude_model.dart:31-32`. La patch è già pronta in `tasks/claude-controls-remove-1m-beta.patch` (si applica con `git apply`): `tsc --noEmit` non dà errori nuovi e `node --test` passa 18/18. **Prima di mergiare**, provare una sessione reale con Sonnet e con Opus e controllare che la finestra resti a 1M.
- [ ] **Verifica**: una sessione per modello con thinking On/Off ed effort ai due estremi, controllando nell'NDJSON cosa arriva al sidecar e cosa torna (blocchi `thinking`, `usage`).

## Fuori da questo piano (segnalati dall'audit)
- `dontAsk` esiste nel protocollo ma non nella UI (`protocol.ts:4`, `permissions.ts:20`).
- `shelf` / `shelf_router` restano nel pubspec ma non sono più usati.
- Commenti stale nel sidecar: `_readOnlyTools` in `permissions.ts:3,11` e il riferimento a SEA in `sidecar.ts:13`.
- `.bare/config`: `core.bare=true` senza `config.worktree` rompe `git status` in `main` e nelle worktree.
