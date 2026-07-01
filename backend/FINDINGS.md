# FINDINGS — Spike Claude Agent SDK: round-trip Plan Mode + AskUserQuestion

Data: 2026-06-30 · Branch: `feature/claude-sdk` · Eseguito su macOS (Darwin 25.5.0), Node v26.0.0.

## TL;DR — GO

Tutti e tre i round-trip che avevano affossato l'esperimento Clyde (CLI headless `claude -p`)
funzionano **dal vivo** con l'Agent SDK via la callback `canUseTool`:

- ✅ **ExitPlanMode** intercettato, approva/rifiuta funziona, Claude prosegue o si ferma.
- ✅ **AskUserQuestion** intercettato, `answers` torna a Claude, la sessione prosegue con la scelta.
- ✅ Tutto con **auth abbonamento OAuth**, nessuna `ANTHROPIC_API_KEY`.

Il blocco storico ("la CLI non aspettava il `tool_result`") **non esiste** nell'SDK: la
callback `canUseTool` mette in pausa la sessione finché non ritorni una decisione. È
esattamente il primitivo su cui costruire il bridge `canUseTool` → WebSocket.

---

## Versioni reali (verificate, non a memoria)

| Componente | Versione |
|---|---|
| `@anthropic-ai/claude-agent-sdk` | **0.3.197** (`npm view ... version`, anche `dist-tags.latest`) |
| Claude Code CLI (`claude --version`) | **2.1.197 (Claude Code)** |
| Node.js | v26.0.0 |
| npm | 11.12.1 |

> Nota: l'SDK NON include la CLI; sotto il cofano lancia il binario `claude` di sistema
> e ne usa le credenziali. Versione SDK e versione CLI sono accoppiate (197 ↔ 197).

---

## Criteri go/no-go (sez. 5 del brief)

### ✅ [1] `canUseTool` riceve `ExitPlanMode`; round-trip approva/rifiuta funziona
- Avviata `query()` con `permissionMode: 'plan'` su task che richiede scrittura file.
- Claude esplora (read-only), poi chiama `ExitPlanMode`. La callback **scatta** con `toolName === 'ExitPlanMode'`.
- **Approva** (`{behavior:'allow', updatedInput:input}`) + `q.setPermissionMode('acceptEdits')` →
  Claude scrive `calc.js`, lo verifica con Bash, e termina con `subtype=success`. File presente nel sandbox.
- **Rifiuta graceful** (`{behavior:'deny', message, interrupt:false}`) → Claude risponde
  "Plan rejected. Waiting." e **non scrive nulla** (sandbox vuoto), `subtype=success`.
- **Rifiuta con `interrupt:true`** → la sessione viene **abortita**: `subtype=error_during_execution`,
  `is_error=true`, e l'iteratore `for await` **lancia un'eccezione**
  (`Error: Claude Code returned an error result ... stop_reason=tool_use`). Vedi "Sorprese".

### ✅ [2] `canUseTool` riceve `AskUserQuestion`; `answers` torna a Claude e la sessione prosegue
- Prompt che forza la scelta di linguaggio + database. Claude chiama `AskUserQuestion`
  con **2 domande in UNA sola chiamata** (array `questions` di 2 elementi).
- La callback ritorna `{behavior:'allow', updatedInput:{questions, answers}}`.
- Claude **prosegue usando le scelte**: output "Stack locked: **TypeScript (Node) + PostgreSQL**"
  (= label opzione 1 di entrambe le domande, scelte dall'auto-answer headless).

### ✅ [3] Funziona con auth abbonamento (nessuna API key)
- `env | grep ANTHROPIC` → **nessuna** `ANTHROPIC_API_KEY`.
- `~/.claude/settings.json` → **nessun** campo apiKey.
- Presenti: `~/.claude/.credentials.json` + entry keychain `"Claude Code-credentials"` (login OAuth della CLI).
- Le 4 run sono andate a buon fine senza alcun prompt/errore di auth. **L'SDK eredita l'OAuth abbonamento della CLI.**

### ✅ [4] Versioni + formati payload + sorprese
- Vedi sezioni "Versioni reali", "Formati payload osservati", "Sorprese".

---

## API corrente confermata (dai `.d.ts` dell'SDK 0.3.197)

```ts
type CanUseTool = (
  toolName: string,
  input: Record<string, unknown>,
  options: {
    signal: AbortSignal;
    suggestions?: PermissionUpdate[];   // regole "allow always" pronte da rimandare in updatedPermissions
    blockedPath?: string;
    decisionReason?: string;            // es. "This command requires approval"
    title?: string;                     // frase pronta es. "Claude wants to read foo.txt"
    displayName?: string;               // es. "Bash" / "ExitPlanMode"
    description?: string;
    toolUseID: string;                  // id univoco del tool call → CHIAVE per il bridge async
    agentID?: string;                   // valorizzato se la richiesta arriva da un sub-agent
  }
) => Promise<PermissionResult>;

type PermissionResult =
  | { behavior: 'allow'; updatedInput?: Record<string, unknown>; updatedPermissions?: PermissionUpdate[];
      toolUseID?: string; decisionClassification?: ... }
  | { behavior: 'deny';  message: string; interrupt?: boolean;
      toolUseID?: string; decisionClassification?: ... };

type PermissionMode = 'default' | 'acceptEdits' | 'bypassPermissions' | 'plan' | 'dontAsk' | 'auto';

// L'oggetto Query (ritorno di query()) espone, fra l'altro:
//   setPermissionMode(mode: PermissionMode): Promise<void>
//   interrupt(): Promise<void>
```

Punti chiave:
- **TypeScript NON richiede il workaround del dummy `PreToolUse` hook** (serve solo a Python per tenere
  aperto lo stream). In TS basta passare `canUseTool` con un prompt stringa semplice.
- La callback **mette in pausa la sessione finché non ritorni**, indefinitamente (il wait si annulla
  solo se la query viene cancellata). Esiste anche la `defer` hook decision per far uscire il processo
  e riprendere da sessione persistita — rilevante per il backend remoto con risposte lente (Telegram).
- In `plan` mode i tool di scrittura e `ExitPlanMode` vengono **forzati** alla callback anche se ci
  sarebbe una allow-rule che li approverebbe.

---

## Formati payload osservati a runtime (REALI, non ipotizzati)

### ExitPlanMode — INPUT ricevuto dalla callback
```jsonc
{
  "plan": "# Plan: create `calc.js`\n\n## Context\n...markdown completo del piano...",
  "planFilePath": "/Users/<me>/.claude/plans/create-a-new-file-pure-thacker.md"
}
```
- `input.plan` = markdown del piano (campo da mostrare all'utente).
- `input.planFilePath` = l'SDK **scrive anche il piano su disco** in `~/.claude/plans/<slug>.md`.
- `options` per ExitPlanMode è minimale: solo `{ displayName: "ExitPlanMode", toolUseID }`
  (niente `suggestions`/`decisionReason`, perché è la plan-mode a forzare la callback).

### ExitPlanMode — valori di RITORNO testati
```ts
// approva (e poi sblocca le scritture)
await q.setPermissionMode('acceptEdits');
return { behavior: 'allow', updatedInput: input };

// rifiuta graceful: Claude acknowledged e aspetta, sessione resta success
return { behavior: 'deny', message: 'User rejected the plan. Stop and wait...', interrupt: false };

// rifiuta hard: aborta la sessione (error_during_execution + eccezione nell'iteratore)
return { behavior: 'deny', message: '...', interrupt: true };
```

### AskUserQuestion — INPUT ricevuto dalla callback
```jsonc
{
  "questions": [
    {
      "question": "Which programming language for the new backend service?",
      "header": "Language",                       // <= 12 char
      "multiSelect": false,
      "options": [
        { "label": "TypeScript (Node)", "description": "Node.js runtime. ..." },
        { "label": "Go",                "description": "Compiled, fast, ..." },
        { "label": "Python",            "description": "..." },
        { "label": "Rust",              "description": "..." }
      ]
    },
    { "question": "Which database for the new backend service?", "header": "Database",
      "multiSelect": false, "options": [ /* 4 opzioni label+description */ ] }
  ]
}
```
- 1–4 domande per chiamata, 2–4 opzioni ciascuna (limite documentato e osservato: ne ha messe 2 in una sola call).
- Opzionale `options[].preview` (markdown o html) SOLO se imposti
  `toolConfig.askUserQuestion.previewFormat`. Non testato in questo spike.

### AskUserQuestion — valore di RITORNO testato
```ts
return {
  behavior: 'allow',
  updatedInput: {
    questions,                    // RI-PASSARE l'array originale (obbligatorio per il processing)
    answers: {                    // chiave = testo `question`, valore = `label` scelta
      "Which programming language for the new backend service?": "TypeScript (Node)",
      "Which database for the new backend service?": "PostgreSQL"
    }
  }
};
```
- Multi-select: valore = array di label, oppure stringa join `", "`.
- Free-text: metti il testo utente come valore (non la parola "Other").
- Opzionale `answers`-level `response`: reply libera che bypassa le risposte per-domanda
  ("The user responded: …").

### Stream di messaggi (`for await (const m of query(...))`)
- `m.type === 'system'`, `m.subtype === 'init'` → `model`, `permissionMode`, `cwd`, `tools`, `apiKeySource`.
- `m.type === 'assistant'` → `m.message.content[]` con blocchi `{type:'text', text}` e `{type:'tool_use', name, input}`.
- `m.type === 'result'` → `subtype` (`success` | `error_during_execution` | ...), `is_error`,
  `result` (testo finale), `usage` (token + cache).

---

## Sorprese / limiti osservati

1. **`interrupt:true` su deny = abort + eccezione.** Non è uno stop pulito: produce
   `subtype=error_during_execution`, `is_error=true` e fa **lanciare** il `for await`.
   → Per il backend: usare `deny` **senza** `interrupt` per i "no" recuperabili (Claude resta in
   sessione e aspetta); riservare `interrupt:true` (o `q.interrupt()`) al kill esplicito. Avvolgere
   comunque l'iterazione in try/catch.

2. **Approvare ExitPlanMode da solo NON basta a far scrivere Claude.** Resti in `plan` mode e ogni
   scrittura ri-bussa alla callback. Bisogna cambiare modalità: `q.setPermissionMode('acceptEdits')`
   (o `'default'`/`'bypassPermissions'`) al momento dell'allow. Confermato dal vivo.

3. **`acceptEdits` auto-approva file-ops ma NON i comandi Bash arbitrari.** Dopo l'approvazione del
   piano, `Write` è passato liscio ma 5 chiamate `Bash` (esplorazione + verifica `node`) hanno
   ri-bussato alla callback. Per il bridge significa: anche post-piano arriveranno permission request
   per i comandi shell → vanno instradate all'utente (o pre-approvate con allow-rules / `bypassPermissions`).

4. **`AskUserQuestion` raggruppa più domande in una sola chiamata** (array `questions`). Il bridge deve
   renderizzare N domande da un singolo evento, non assumere 1:1.

5. **`options.suggestions`** arriva pre-compilato con regole "allow always" pronte
   (`type:addRules`, `destination:localSettings`). Rimandandole in `updatedPermissions` si evita il
   re-prompt nelle sessioni successive — utile per un "ricorda questa scelta" lato client.

6. **`options.toolUseID`** è univoco per ogni tool call → è la **chiave naturale** per correlare
   request↔response attraverso il WebSocket (vedi raccomandazioni).

7. **Rate-limit**: nessun rate-limit incontrato in 4 run brevi. `usage` riporta forte uso di prompt
   cache (es. `cache_read_input_tokens: 372669`), quindi sessioni multi-turn lunghe restano economiche.
   Il rischio rate-limit abbonamento resta da validare sotto carico reale (multi-sessione concorrente),
   non emergente qui.

---

## Raccomandazioni per il backend definitivo

**1. Una `query()` per sessione, `canUseTool` come ponte verso il transport.**
La callback è il punto di pausa naturale. Pattern:
```ts
const pending = new Map<string, (r: PermissionResult) => void>();  // chiave = toolUseID

const canUseTool: CanUseTool = (toolName, input, opts) =>
  new Promise<PermissionResult>((resolve) => {
    pending.set(opts.toolUseID, resolve);
    ws.send({ kind: 'permission_request', toolUseID: opts.toolUseID, toolName, input,
              title: opts.title, suggestions: opts.suggestions });
    opts.signal.addEventListener('abort', () => { pending.delete(opts.toolUseID); /* reject/cleanup */ });
  });

// alla risposta dal client:
ws.on('decision', ({ toolUseID, result }) => pending.get(toolUseID)?.(result));
```
`toolUseID` correla 1:1 request↔response; più richieste pendenti convivono.

**2. Session manager multi-istanza.** Una `Query` per workspace/chat, keyed per sessionId. Conserva il
riferimento `q` per chiamare `setPermissionMode()` / `interrupt()` dal lato client. `agentID` distingue
le richieste provenienti da sub-agent.

**3. Flusso plan-mode esplicito nel protocollo.** Evento `plan_proposed{plan, planFilePath}` → risposta
`approve` (server fa `setPermissionMode('acceptEdits'|'default')` + allow) o `reject{message}`
(deny senza interrupt). `planFilePath` permette di mostrare/persistere il piano lato UI.

**4. AskUserQuestion → UI a scelta multipla nativa** (Flutter / inline keyboard Telegram). Mappare
`questions[]` → widget; rimandare SEMPRE `questions` + `answers`. Supportare multiSelect e free-text.
Valutare `toolConfig.askUserQuestion.previewFormat:'markdown'` per Telegram.

**5. Robustezza:** `try/catch` sul `for await`; gestire `error_during_execution`; trattare la callback
come potenzialmente lunghissima (utente Telegram lento) → considerare la `defer` hook decision +
ripresa da sessione persistita per non tenere il processo appeso.

**6. Auth:** in locale (Mac) e su VPS basta che la CLI `claude` sia loggata via OAuth abbonamento;
NON serve (e non si deve impostare) `ANTHROPIC_API_KEY`. Sul VPS va replicato il login OAuth
(`~/.claude/.credentials.json`). Resta valido il rischio ToS/zona-grigia già accettato dal brief.

---

## Come riprodurre

```bash
cd spike-agent-sdk
npm install
npm run question                 # AskUserQuestion round-trip (headless: auto-sceglie opzione 1)
npm run plan                     # Plan mode: approva (headless: auto 'y') → scrive calc.js nel sandbox
SPIKE_DENY=1 npm run plan        # rifiuto graceful: Claude si ferma, sandbox vuoto
SPIKE_DENY=1 SPIKE_INTERRUPT=1 npm run plan   # rifiuto hard: abort + error_during_execution
```
Con un TTY reale i prompt leggono da stdin (y/n, numero opzione). Headless (stdin non-TTY)
auto-risponde in modo deterministico. Ogni run scrive i payload grezzi in `last-run-<mode>.json`.
