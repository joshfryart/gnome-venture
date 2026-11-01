# Plan: villager brains (tiny LLM per NPC)

Status: planning only. Nothing built. Decision gate after Phase 0.

## Goal
Every villager feels alive: has moods, remembers you, gossips, changes over days. As small and cheap as possible while still reading as real.

## The hard truth
"One tiny LLM running forever per villager" cannot work here:
- Host is CanSpace shared cPanel: PHP + MySQL, no GPU, no daemons, no cron (existing rule: "computed on view").
- 146 villages + the `npcs` table. Even a 135M model at 4-bit is ~80MB resident; 100 copies is absurd.
- No monetization, so no inference budget.

**Reframe: a brain is a tiny saved state record, not a process.** One shared small model (weights shared) is only *borrowed* to voice a villager at the moment a player is looking. "Perpetual" is faked by lazy catch-up when someone views them (same trick as weather and hollow time).

## Architecture: tiered cognition (each tier works without the one above)
| Tier | What | Cost | Runs |
|---|---|---|---|
| L0 Body | needs (hunger/social/rest/mood) + `npc_schedules` -> activity + place | integer math | lazy catch-up on view, server |
| L1 Mind | traits, ring-buffer memory, per-player affinity, gossip swap | integer math + SQL | server |
| L2 Voice | template grammar from `stop_chat.txt`-style lines, filled from state | ~0 | server (always-on fallback) |
| L3 Voice+ | tiny LLM rewrites/produces 1 short line from state | ~250 tok in, ~25 out | **in the player's browser, opt-in** |

LLM never decides game outcomes. Sim decides *what happens*; LLM only decides *how it is said*.

## Brain record (~600 bytes JSON/row, table `npc_brain`)
- `traits`: warm, curious, grumpy, chatty (0-9 each); seeded from `personality`.
- `needs`: social, rest, hunger, purpose (0-100) + `last_tick` (for catch-up).
- `now`: activity, location_id (from schedule, nudged by needs).
- `mem`: <=8 facts x ~60 chars, each with salience + day; decay, evict lowest. Facts are structured (`gift:player:item`, `saw:weather:storm`, `heard:npcB:fact`) and rendered to text only for the prompt.
- `diary`: <=200 chars rolling summary, rewritten rarely.
- Per-player (`npc_bond`): affinity int, 3 tags (liked gift, asked about X, first met day), last-seen day.
Hard caps on everything: storage is bounded per NPC.

## Lazy catch-up (replaces "perpetually running")
On view: `ticks = min(elapsed / tick_len, CAP)`; replay needs decay, schedule moves, mood drift. Co-located NPCs during replay roll a deterministic (seeded by npc ids + day) "meeting": swap one memory with probability from chatty/warm. Rumours spread with zero inference. Cap replay (e.g. 48 ticks) so a view is O(1) work.

## Prompt budget for the tiny model (~250 tokens)
persona + traits (40) | state: place, time, weather, mood (30) | 2-3 retrieved memories by salience/relevance (60) | 2 few-shot house-style lines (50) | last exchange (60). Output: one line, <=25 tokens, stop at newline. Small models cannot hold more, so we do not ask them to.

## Problems, pitfalls, solutions
1. **Compute/scale.** Shared model, state in DB, on-view only, in-browser inference (zero server cost). Candidates to measure: SmolLM2-135M/360M-Instruct, Qwen2.5-0.5B-Instruct (transformers.js / WebLLM, WASM or WebGPU).
2. **Phones.** 100-300MB download, slow, hot. Opt-in toggle, wifi hint, cache in IndexedDB, one-time load, timeout (3s) then fall back to L2 template line. Never block UI.
3. **Hallucination wrecks lore/economy** (invents prices, items, quests). Model has no tools and no write access. Facts injected, not recalled. Post-filter: reject lines naming unknown items/places/numbers; fall back to template. Never lets the model grant Petals/items (repo rule: repeatable Petal source needs a cap).
4. **Safety/moderation** (cosy game, maybe young players, prompt injection). Player input = tap chips (greet, gift, ask about X, gossip) by default; optional short free text is keyword-intent-parsed, never pasted raw into a prompt, never shown to other players. Output: length cap, blocklist, charset check. Villager lines are private to the viewer.
5. **Tiny models are dumb and samey.** Per-NPC voice via few-shot from curated lines (the existing 57 `stop_chat.txt` lines + more); low temperature + grammar/stop constraints; the *state* provides the variety. Optional later: LoRA/distill from lines generated offline by a big model.
6. **Memory loss/consistency.** Memory is DB facts, not model context. Model is stateless per call.
7. **Global vs per-player state.** Global: needs, location, gossip pool (race-safe conditional UPDATEs per README conventions). Per-player: bond + what that player did. Players can't grief a villager's mood beyond a small clamp per day.
8. **Cron-less world.** Lazy catch-up above; no daemon.
9. **Testing.** Suites run SQLite with no model. Stub "voice" returning a seeded template; sim is pure and seeded, so tests are deterministic. Golden-file the prompt builder.
10. **Upgrades.** Version the brain schema and prompt (`brain_v`); `boot_step` migrations; old memories stay valid because they are structured facts.
11. **Storage growth.** Fixed caps, prune stale bonds (guests purged with their gardens), no logs of generated text.
12. **Privacy/CSP.** Model files self-hosted (no third-party fetch), tight `connect-src`; CSP needs `wasm-unsafe-eval` for WASM; nothing about the player leaves the browser.
13. **Uncanny/boring risk.** Mostly solved by L0/L1 (they remember, they move, they gossip). The LLM is garnish; if it never ships the game still gains most of the value.

## Phases
0. **Spike (1 day):** offline benchmark of 135M/360M/0.5B on a mid phone + laptop: load time, tok/s, and 25-token quality from the real prompt. Gate: p50 < 3s on a mid phone, or ship L0-L2 only / desktop-only L3.
1. **Body+Mind, no LLM:** `npc_brain`, `npc_bond`, lazy tick, memory, gossip, template voice (L2). Ships standalone value. Admin view of a villager's brain.
2. **Voice+ (L3):** in-browser opt-in, prompt builder, output filter, fallback.
3. **Depth:** gift/ask intents, rumours surfacing in dialogue, diary, per-region dialect lines.
4. **Optional:** distilled/LoRA'd model on our own corpus; smaller download.

## Open questions
1. Scope: only rest-stop folk first (`stopfolk.php`), or all `npcs`/146 villages?
2. Inference location: browser-only opt-in (recommended) vs a small self-hosted llama.cpp box vs API with a hard budget?
3. Memory per-player (private bonds, recommended) or shared world memory players can influence?
4. Free-text input at all, or chips only?
5. Should guests get brains, or only registered gnomes?
