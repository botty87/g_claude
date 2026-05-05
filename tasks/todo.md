# Shortcut cycle + set diretti per Sforzo / Pensiero / Permission

## Scelta

Opzione **B** dalla proposta. **No reverse cycle**. **Snackbar di conferma attiva**.

## Shortcut da implementare

### Cycle (forward only)

| Shortcut | Azione | Loop |
|---|---|---|
| `Cmd+Shift+E` | cycle Sforzo | low → medium → high → xhigh → max → low |
| `Cmd+Shift+T` | cycle Pensiero | off → think → thinkHard → ultrathink → off |
| `Cmd+Shift+M` | cycle Permission | default → plan → acceptEdits → bypassPermissions → default |

### Set diretti

| Shortcut | Effort |
|---|---|
| `Cmd+Alt+1` | low |
| `Cmd+Alt+2` | medium |
| `Cmd+Alt+3` | high |
| `Cmd+Alt+4` | xhigh |
| `Cmd+Alt+5` | max |

| Shortcut | Thinking |
|---|---|
| `Cmd+Shift+1` | off |
| `Cmd+Shift+2` | think |
| `Cmd+Shift+3` | thinkHard |
| `Cmd+Shift+4` | ultrathink |

| Shortcut | Permission |
|---|---|
| `Cmd+Ctrl+1` | default |
| `Cmd+Ctrl+2` | plan |
| `Cmd+Ctrl+3` | acceptEdits |
| `Cmd+Ctrl+4` | bypassPermissions |

Totale: 17 binding.

## Steps

- [ ] **1. Helper next-cycle** in `lib/features/claude/domain/entities/`:
  - aggiungi getter `ClaudeEffort get next` (wrap-around via `values[(index+1) % values.length]`)
  - idem per `ClaudeThinkingMode` e `ClaudePermissionMode`
- [ ] **2. Aggiungi chiavi i18n** in `assets/translations/{en,it}.json` sotto `shell.shortcuts`:
  - `effortChanged` → `"Effort: {value}"` / `"Sforzo: {value}"`
  - `thinkingChanged` → `"Thinking: {value}"` / `"Pensiero: {value}"`
  - `permissionChanged` → `"Mode: {value}"` / `"Modalità: {value}"`
  - `noActiveWorkspace` → `"No active workspace"` / `"Nessun workspace attivo"` (per snackbar quando shortcut premuta senza workspace)
- [ ] **3. Rigenera l10n**: `dart run lib/core/l10n/tool/l10n_generate.dart`
- [ ] **4. Estendi `onKey` in [app_shell.dart:132](lib/features/shell/presentation/widgets/app_shell.dart#L132)**:
  - aggiungi 3 funzioni: `cycleEffort()`, `cycleThinking()`, `cyclePermission()`
  - aggiungi 3 funzioni set parametriche: `setEffortDirect(ClaudeEffort)`, etc.
  - tutte leggono `activeIdOrNull` live; se null → snackbar `noActiveWorkspace`, return false
  - dopo set: snackbar floating 1.5s con label tradotta dell'enum (`Locales.X.tr(args: {value: ...})`)
  - mappa key event:
    - `Cmd+Shift` + KeyE/T/M → cycle relativi
    - `Cmd+Alt` + Digit1..5 → setEffort
    - `Cmd+Shift` + Digit1..4 → setThinking (occhio: differenziare da KeyE/T/M già su Cmd+Shift, distinti per `logicalKey`)
    - `Cmd+Ctrl` (= `isControlPressed`) + Digit1..4 → setPermission
- [ ] **5. Test manuale**:
  - cycle ciascuna dimensione, verifica wrap-around al primo valore
  - set diretti tutti
  - snackbar mostra valore localizzato
  - stato persiste dopo restart (già garantito dai setter cubit)
  - shortcut con workspace nullo → snackbar `noActiveWorkspace`, niente crash
- [ ] **6. Doc**: scrivi `docs/shortcuts.md` con tabella completa di tutte le shortcut app.
- [ ] **7. Analyze**: `dart analyze`. Zero warning nuovi.

## Note implementazione

- **Conflitto digit Cmd+Shift**: `Cmd+Shift+E/T/M` (lettere) e `Cmd+Shift+1..4` (cifre) condividono modifier ma `logicalKey` distingue. Switch su `event.logicalKey` chiaro.
- **Helpers i18n enum**: già esistono `Locales.Claude.Effort.low.tr()` etc. via `labelKey` enum. Per snackbar estrarre testo da `effort.labelKey.tr()` (consentito perché chiave dinamica da enum field, vedi CLAUDE.md eccezione).
- **Bypass cycle**: utente ha confermato di non voler guardia. Bypass entra nel cycle normalmente.
- **Single source of truth**: setter cubit emit + persist. Header pickers riceveranno update via `context.select` esistente. Zero modifiche UI esistenti.
- **Scope shortcut**: stesso `Focus` di app_shell.dart (root). Non interferisce con TextField input bar (focus prende priorità su quello).

## Files toccati

- `lib/features/claude/domain/entities/claude_effort.dart` (+ getter)
- `lib/features/claude/domain/entities/claude_thinking_mode.dart` (+ getter)
- `lib/features/claude/domain/entities/claude_permission_mode.dart` (+ getter)
- `lib/features/shell/presentation/widgets/app_shell.dart` (estensione `onKey`)
- `assets/translations/en.json` + `assets/translations/it.json` (chiavi snackbar)
- `lib/core/l10n/locales.g.dart` + `lib/core/l10n/locale_keys.g.dart` (rigenerati)
- `docs/shortcuts.md` (nuovo)

## Review

_(da compilare a fine implementazione)_
