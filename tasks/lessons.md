# Lessons

## Eliminare un useState mirror: migrare anche i callers

**Pattern**: quando si rimuove un `useState<T>` che mirroreggiava un campo del cubit, sostituire con `context.select` non basta. Tutti i callers che leggevano la variabile locale dentro callback long-lived (`onPressed`, `onDragDone`, listener registrati in `useEffect`) vanno migrati a leggere live dal cubit (`cubit.state.sessions[id]?.field`).

**Perché**: la variabile da `context.select` cattura uno snapshot al momento del build. Tra build e firing del callback il cubit può aver emesso nuovo state (es. drag-drop pane modifica attachments mentre input bar non ha ancora rebuiltato). Il callback ricostruisce `next` da snapshot stale → sovrascrittura silente del state cubit.

**Sintomo tipico**: race in cui un'azione utente "annulla" una modifica appena avvenuta (drag-drop riappare dopo remove, chip riappare dopo backspace, ecc).

**Riferimento**: fix iterativi su `claude_input_bar.dart` (`2654c13` rimosse `attachmentList` useState; `188d3e9` patchò solo `persistDraft` ma non i callers; `fix/input-bar-stale-state` chiuse il loop migrando anche `selectedChips` e leggendo live in tutti i callbacks).
