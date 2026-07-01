# Clyde — Restyle & Riorganizzazione Workspace · Brief di implementazione

> Documento per l'istanza di Claude che implementerà il redesign nel codebase Flutter `g_claude`.
> Il mockup di riferimento è `Clyde Restyle.dc.html` (turn 3 = design definitivo, turn 1 = layout base negli stati Home/Attivo).
> **Non cambia lo stack né l'architettura**: si tocca solo il layer `presentation` (widget) di alcune feature. Vale tutto quanto in `CLAUDE.md` (Cubit + hooks, no StatefulWidget, `Locales.X.y`, single source of truth, ecc.).

---

## 1. Obiettivo

Modernizzare la UI mantenendo il tema **Glass Graphite** e riorganizzare la navigazione:

1. **Sidebar workspace a sinistra** (ibrida: cartelle semplici + repo con worktree), **collassabile a icone**, che sostituisce l'attuale selettore workspace in alto a destra + activity bar.
2. **File/Explorer spostati a destra** in un pannello a tab **Files / Diff** (browser di sola lettura/navigazione — **niente editor incastrato qui**).
3. **Editor al centro**, insieme a chat e terminale, con modello **"sbircia ↔ contesto pieno"**.
4. **Sessioni chat multiple** per workspace come **tab in alto**, con **indicatore di worktree/branch** sempre visibile.

Nessuna funzionalità esistente va rimossa: si ridistribuiscono i contenuti già presenti (explorer, editor, chat, terminale, sessioni, logs, MCP/model/effort picker).

---

## 2. Gerarchia mentale (importante)

```
Repo o Cartella          ← sidebar sinistra
  └─ Worktree / branch    ← sidebar sinistra (solo per i repo git)
       └─ Sessione chat    ← tab in alto (il "+" ne apre una nuova)
            └─ Vista: Chat · Codice · Terminale   ← segmented control al centro
```

- Un **repo** git può avere più **worktree** (branch). Una **cartella semplice** (es. `~/`, home utente) non ha worktree: ci si chatta direttamente.
- Ogni worktree/cartella ha una o più **sessioni** di Claude in parallelo (tab in alto).
- Il chip worktree nella tab bar rende esplicito *su quale worktree* stanno lavorando le sessioni visibili.

---

## 3. Layout a 3 zone (+ tab bar)

```
┌───────────────────────────────────────────────────────────────┐
│ Titlebar (traffic lights · CLYDE · contesto workspace)         │
├──────────┬──────────────────────────────────────┬─────────────┤
│          │ Tab bar: [chip worktree ▾] │ sessioni chat │ [＋]   │
│ Sidebar  ├──────────────────────────────────────┤  Pannello   │
│ workspace│ Segmented: [Chat] [Codice n] [Terminale]│  destro    │
│ (sx,     │                                      │  a tab:     │
│ collass.)│      Centro: Chat / Editor / Term.   │  Files/Diff │
│          │      (+ overlay "sbircia")           │             │
└──────────┴──────────────────────────────────────┴─────────────┘
```

### 3.1 Sidebar sinistra (feature `workspace` + `shell`)
- **Larghezza** ~262px espansa; **collassata** ~52px (solo icone/avatar). Toggle in testa (persistere lo stato in `ShellCubit`, come l'attuale `workspaceOpen`, es. `sidebarCollapsed`).
- **Contenuto (albero unificato)**:
  - Sezione repo: ogni repo = header espandibile (avatar iniziale colorato + nome + conteggio worktree). Espanso mostra i **worktree** annidati.
  - Ogni riga worktree mostra: **nome**, **branch** (mono, piccolo), **dot stato agente** (verde pulsante = running / grigio = idle), badge **PR/task** (`#91`) se presente. Riga attiva = accento indigo a sinistra + bg indigo tenue.
  - Sezione **Cartelle**: voci flat (es. `Home ~/`), senza worktree.
- **Azioni**: `+ Nuovo workspace` (apre picker cartella / aggiungi repo), `+ Nuovo worktree` per repo, ricerca, collapse.
- **Collassata**: rail di **avatar** (iniziale repo colorata + icona home per le cartelle); dot verde di stato sul repo con agente attivo; `+` per nuovo. Click avatar = seleziona workspace.
- **Activity mini-rail in fondo** (o integrata): Chat · Cronologia sessioni · Terminale · Logs · Impostazioni. Sostituisce l'attuale `ActivityBar` verticale.

> Mapping codice: `WorkspacesCubit` (già gestisce multi-cartella + persistenza `workspaces.v1`) va esteso col concetto di **repo → worktree**. Introdurre entità `Worktree` (branch, path, prCount, agentStatus) legata a un `Workspace` di tipo repo; le cartelle semplici restano `Workspace` senza worktree. La `ActivityBar` e la `WorkspaceDropdown` attuali confluiscono qui.

### 3.2 Tab bar in alto (feature `claude` — sessioni)
- A sinistra: **chip worktree** = `[avatar] branch ▾` (dropdown per cambiare worktree senza andare a sinistra). Divisore verticale.
- Poi le **tab delle sessioni** chat (titolo sessione + dot "running" se l'agente sta girando). Tab attiva evidenziata.
- `＋` = nuova sessione sullo stesso worktree.
- Le sessioni sono già modellate (`ClaudeSessionsCubit`, cronologia JSONL). Serve solo l'UI a tab + la nozione "N sessioni per workspace".

### 3.3 Centro (feature `claude` + `editor` + `terminal`)
Segmented control persistente: **Chat · Codice (n) · Terminale**.
- **Chat**: la conversazione attuale (`ClaudeTerminalPane`), invariata nei contenuti (messaggi, tool card, diff inline, card agente in background, input bar con model/effort/permission/MCP picker).
- **Codice**: editor a **tutta larghezza** con **tab dei file aperti** (`FileTabsBar` + `FileViewer`/`re_editor`). Il badge `n` = numero file aperti. È qui che vive il **contesto pieno**.
- **Terminale**: `TerminalPane`.
- Il segmento **Codice** è disabilitato/nascosto finché non c'è almeno un file aperto.

### 3.4 Pannello destro (feature `explorer` + diff)
- Tab **Files** (tree dell'explorer attuale `ExplorerView`) e **Diff** (lista file modificati con badge M/A/D e conteggi +/−; opzionale in questa fase se il diff non è ancora implementato — in tal caso lasciare solo Files).
- **Sola navigazione**: click su un file NON apre l'editor qui, ma **al centro** (vedi §4).
- Larghezza ~290–340px; comprimibile.

---

## 4. Modello editor: "Sbircia ↔ Contesto pieno" (il cuore del redesign)

Un file si apre in due modalità complementari, sullo **stesso set di file aperti**:

1. **Sbircia (peek)** — *click singolo* su un file (dal pannello Files, o da un riferimento nella chat):
   - Sale un **pannello a scorrimento** dal basso, **sopra la chat** (~56–60% altezza), con handle di trascinamento, tab dei file, `×` per chiudere.
   - La chat resta visibile sopra → "dai un'occhiata al volo senza perdere il filo".
   - Bottone **"Apri a schermo intero"** → promuove a contesto pieno.
2. **Contesto pieno (full)** — l'editor occupa il centro (segmento **Codice**), tab file a tutta altezza, gestione di N file come in un editor normale.
   - Bottone **"Riduci a sbircia"** → ricaccia l'editor nell'overlay e riporta la vista Chat.

**Regole di stato** (in un cubit dedicato, es. `EditorViewCubit`, o esteso su `ShellCubit`/`FileTabsCubit`):
- I **file aperti sono un unico set** condiviso tra sbircia e pieno (chiudere una tab vale in entrambe).
- Modalità corrente: `chat | code | terminal` (segmented) + flag `peekOpen` (overlay sopra la chat).
- Passaggi: `Files→click` = `peekOpen=true`; `"Apri a schermo intero"` = `mode=code, peekOpen=false`; `"Riduci a sbircia"` = `mode=chat, peekOpen=true`; segmented = set esplicito.
- Persistere file aperti e modalità (coerente con `tabs.v1` già esistente per l'editor).

> Questo sostituisce l'attuale pane editor nello split centrale (`_MainArea` in `app_shell.dart`): non più `Area(preview)` fisso a sinistra della chat, ma editor **dentro** l'area centrale come vista alternativa/overlay.

---

## 5. Design tokens (Glass Graphite — invariati, da `core/theme/`)

Usare **esclusivamente** i token esistenti (`AppColors`, `AppTypography`, `AppSpacing`, `AppRadii`). Riferimenti chiave usati nel mockup:

| Ruolo | Token / valore |
|---|---|
| Accento brand | `brandIndigo` `#5C5AE7` · primary chiaro `#C2C1FF` |
| Sfondo finestra/chat | `surface` `#13131B` |
| Activity/rail | `surfaceContainerLowest` `#0E0D15` |
| Sidebar | `surfaceContainerLow` `#1B1B23` |
| Pannello destro | `surfaceContainer` `#1F1F27` |
| Testo | `onSurface` `#E4E1ED` · muted `onSurfaceVariant` `#C7C4D7` · dim `outline` `#918FA0` |
| Bordi/divisori | `outlineVariant` `#464554` (o `glassBorder` bianco 10%) |
| Sky / Peach (accenti sec.) | `secondary` `#87CEFF` · `tertiary` `#FFB688` |
| Stato running | `#27C93F` (verde traffic) con pulse |
| Font UI | **Inter** (14/20 base, 12/16 tab, 11 uppercase label) |
| Font codice/terminale | **JetBrains Mono** (13/1.6) |
| Raggi | 6–8px controlli, 12–14px card/finestra |

Colori diff (semantici, non di brand): add `#3FB950`, del `#F85149` — già convenzione git-like nel mockup.

---

## 6. Mapping alle feature del codebase

- **`shell`** (`app_shell.dart`, `activity_bar.dart`, `side_panel.dart`): riscrittura del layout. `_MainArea`/`MultiSplitView` diventa: sidebar sx (collassabile) · centro (segmented Chat/Code/Term + overlay peek) · pannello dx (Files/Diff). `ActivityBar` verticale rimossa/integrata nella sidebar.
- **`workspace`**: estendere modello con **repo/worktree** (nuova entità `Worktree`). Sidebar tree + collapse in `ShellCubit`. La `WorkspaceDropdown` in alto sparisce (contesto ora a sinistra + chip in tab bar).
- **`claude`**: **sessioni multiple come tab** in alto + chip worktree. Riuso di `ClaudeSessionsCubit`, `ClaudeTerminalPane`, input bar e picker (model/effort/permission/MCP) invariati.
- **`explorer`**: `ExplorerView` va nel **pannello destro** (tab Files). Il click file emette "apri in sbircia" invece di aprire il preview a sinistra.
- **`editor`**: `FileTabsBar` + `FileViewer` diventano la vista **Codice** al centro e il contenuto dell'**overlay sbircia** (stesso set di tab). Nuovo `EditorViewCubit` per modalità/peek.
- **`terminal`**: `TerminalPane` come terzo segmento centrale.
- **`app_logs`**: entry "Logs" nella activity mini-rail della sidebar (invariato).

---

## 7. Fuori scope / da NON toccare

- Stack, DI, routing, persistenza, parsing NDJSON, PermissionServer, l10n: invariati.
- Nessun nuovo colore/font fuori da Glass Graphite.
- Il **diff panel** può essere una fase 2 se il backend diff non è pronto: in tal caso il pannello destro parte con la sola tab **Files**.
- Le animazioni (pulse stato running, spinner agente, scorrimento sbircia) sono rifiniture: prima il layout e gli stati, poi il moto.

---

## 8. Ordine di implementazione suggerito

1. Layout a 3 zone in `shell` con sidebar collassabile (senza worktree: solo cartelle, come oggi ma riorganizzate) + pannello destro Files.
2. Segmented Chat/Codice/Terminale al centro; sposta editor da destra al centro (vista Codice).
3. Overlay **sbircia** + transizioni sbircia↔pieno (`EditorViewCubit`).
4. Sessioni multiple come **tab** + `＋` (feature `claude`).
5. Modello **repo/worktree** nella sidebar + **chip worktree** in tab bar.
6. Diff panel (fase 2) + rifiniture di moto.

---

*Riferimento visivo completo: `Clyde Restyle.dc.html` — turn 3 (definitivo: sbircia/pieno, chip worktree) e turn 1 (Unified Tree, stati Home e Conversazione attiva).*
