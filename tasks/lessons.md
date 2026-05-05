# Lessons

## Eliminare un useState mirror: migrare anche i callers

**Pattern**: quando si rimuove un `useState<T>` che mirroreggiava un campo del cubit, sostituire con `context.select` non basta. Tutti i callers che leggevano la variabile locale dentro callback long-lived (`onPressed`, `onDragDone`, listener registrati in `useEffect`) vanno migrati a leggere live dal cubit (`cubit.state.sessions[id]?.field`).

**Perché**: la variabile da `context.select` cattura uno snapshot al momento del build. Tra build e firing del callback il cubit può aver emesso nuovo state (es. drag-drop pane modifica attachments mentre input bar non ha ancora rebuiltato). Il callback ricostruisce `next` da snapshot stale → sovrascrittura silente del state cubit.

**Sintomo tipico**: race in cui un'azione utente "annulla" una modifica appena avvenuta (drag-drop riappare dopo remove, chip riappare dopo backspace, ecc).

**Riferimento**: fix iterativi su `claude_input_bar.dart` (`2654c13` rimosse `attachmentList` useState; `188d3e9` patchò solo `persistDraft` ma non i callers; `fix/input-bar-stale-state` chiuse il loop migrando anche `selectedChips` e leggendo live in tutti i callbacks).

## Test infra: SharedPreferences sotto flutter_test va sempre mockato

**Pattern**: `EasyLocalization.ensureInitialized()` (e qualunque altro consumer di `SharedPreferences.getInstance()`) richiede `SharedPreferences.setMockInitialValues({})` prima dell'init nei widget test. Senza questo:
- `MissingPluginException` viene swallowed dentro il FutureBuilder dell'easy_localization → il widget resta sul fallback `SizedBox.shrink()`,
- `pumpAndSettle()` non termina mai → timeout 10 minuti → test sembra "hanging" senza errore visibile.

**Sintomo**: widget test con `EasyLocalization` che timeoutano a 10 min con un errore `TimeoutException`, niente stack trace dal codice di produzione.

**Soluzione**: in `test/helpers/pump_app.dart` chiamare `SharedPreferences.setMockInitialValues({})` prima di `EasyLocalization.ensureInitialized()`.

**Riferimento**: B0 — primo widget test smoke su `Locales.App.title.tr()` che timeoutava sistematicamente.

## Test infra: drift non preserva il flag UTC sui DateTime

**Pattern**: drift serializza `DateTime` come int microsecondi epoch. Al read ricostruisce sempre in **locale time**. Stesso istante, ma `.isUtc == false`. `DateTime.utc(2026, 1, 1) == row.startedAt` è **falso** anche se i due rappresentano lo stesso istante.

**Sintomo**: test "round-trip insert + select" falliscono con `Expected: 2026-01-01 00:00:00.000Z, Actual: 2026-01-01 01:00:00.000` (a seconda del timezone locale del runner).

**Soluzione**: assert su `isAtSameMomentAs(...)`, non su `==`. Vale per tutti i test downstream che leggono timestamp da drift.

**Riferimento**: B0 — `test/helpers/drift_in_memory_test.dart`.
