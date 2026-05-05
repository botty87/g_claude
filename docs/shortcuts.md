# Keyboard Shortcuts

Tabella completa delle shortcut globali dell'app `g_claude`. Tutte le shortcut sono attive a livello di shell (root `Focus`) e funzionano sul workspace attivo. Quando una shortcut richiede un workspace e non ce n'è uno attivo, viene mostrato uno snackbar di avviso.

## Workspace & layout

| Shortcut | Azione | File |
|---|---|---|
| `Cmd+B` | Toggle pannello workspace (side panel collapse/expand) | [app_shell.dart](../lib/features/shell/presentation/widgets/app_shell.dart) |
| `Cmd+W` | Chiudi tab editor attiva | [app_shell.dart](../lib/features/shell/presentation/widgets/app_shell.dart) |
| `Cmd+Opt+K` | Allega file/selezione editor attivo all'input chat | [app_shell.dart](../lib/features/shell/presentation/widgets/app_shell.dart) |

## Chat / Claude session

| Shortcut | Azione | File |
|---|---|---|
| `Cmd+.` | Stop run corrente | [claude_input_bar.dart](../lib/features/claude/presentation/widgets/claude_input_bar.dart) |
| `Esc Esc` (doppio tap entro 3s) | Stop run corrente | [claude_input_bar.dart](../lib/features/claude/presentation/widgets/claude_input_bar.dart) |
| `Enter` | Invia prompt (queue se run attivo) | [claude_input_bar.dart](../lib/features/claude/presentation/widgets/claude_input_bar.dart) |
| `Up` / `Down` | Naviga suggerimenti slash command | [claude_input_bar.dart](../lib/features/claude/presentation/widgets/claude_input_bar.dart) |

## Sforzo / Pensiero / Permission Mode

Tre dimensioni indipendenti controllabili da tastiera. Ogni cambio:

- aggiorna `ClaudeSessionsCubit` per il workspace attivo
- persiste in `SharedPreferences` (chiavi `claude.effort.<wsId>`, `claude.thinking.<wsId>`, `claude.permission.<wsId>`)
- viene applicato al **prossimo** prompt (run in corso non interrotto)
- mostra snackbar floating con il nuovo valore (1.5s)

### Cycle (forward, wrap-around)

| Shortcut | Dimensione | Sequenza |
|---|---|---|
| `Cmd+Shift+E` | Sforzo (Effort) | low → medium → high → xhigh → max → low |
| `Cmd+Shift+T` | Pensiero (Thinking) | off → think → thinkHard → ultrathink → off |
| `Cmd+Shift+M` | Permission Mode | default → plan → acceptEdits → bypassPermissions → default |

### Set diretto — Sforzo

| Shortcut | Valore |
|---|---|
| `Cmd+Opt+1` | Low |
| `Cmd+Opt+2` | Medium |
| `Cmd+Opt+3` | High *(default)* |
| `Cmd+Opt+4` | Extra High |
| `Cmd+Opt+5` | Max |

### Set diretto — Pensiero

| Shortcut | Valore |
|---|---|
| `Cmd+Shift+1` | Off *(default)* |
| `Cmd+Shift+2` | Think |
| `Cmd+Shift+3` | Think hard |
| `Cmd+Shift+4` | Ultrathink |

### Set diretto — Permission Mode

| Shortcut | Valore |
|---|---|
| `Cmd+Ctrl+1` | Default |
| `Cmd+Ctrl+2` | Plan (read-only) |
| `Cmd+Ctrl+3` | Accept Edits *(default app)* |
| `Cmd+Ctrl+4` | Bypass (yolo) |

> **Nota Bypass.** `bypassPermissions` (yolo) auto-approva ogni tool call. Cyclando su `Cmd+Shift+M` ci si finisce dentro senza conferma esplicita. Verifica sempre lo snackbar dopo il cycle.

## Glossario valori

### Sforzo (`ClaudeEffort`)

Livello di reasoning effort passato alla CLI. Più alto = più budget, più latenza, più costo.

- **low / medium / high / xhigh / max** → mappati su `--effort` della CLI Claude.

### Pensiero (`ClaudeThinkingMode`)

Keyword di pensiero estesa. Prepended al prompt utente.

- **off** → nessuna keyword
- **think** → `think`
- **thinkHard** → `think hard`
- **ultrathink** → `ultrathink`

### Permission Mode (`ClaudePermissionMode`)

Modalità di autorizzazione per i tool call.

- **default** → richiede hook server (non disponibile, fallback timeout)
- **plan** → read-only; tool di scrittura/Bash bloccati. Usa `ExitPlanMode` per uscire.
- **acceptEdits** → auto-approva edit/Bash
- **bypassPermissions (yolo)** → auto-approva tutto

## Note tecniche

- Tutte le shortcut sono dispatched da `AppShellPage._onKey` ([app_shell.dart](../lib/features/shell/presentation/widgets/app_shell.dart)).
- Pattern: `KeyDownEvent` + `HardwareKeyboard.instance.is{Meta,Shift,Alt,Control}Pressed`.
- Gli enum espongono getter `next` per il cycle (wrap-around tramite `values[(index+1) % length]`).
- I label localizzati per snackbar arrivano da `<enum>.labelKey.tr()` (chiavi sotto `claude.{effort,thinking,permission}.*`).
