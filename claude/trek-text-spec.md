# Treks: story text system (decided 2026-10-17)

Joshua writes all story text. Claude builds placeholders that describe what each piece must cover, in point form.

## How it works
- Table `trek_texts`: id, trek_key, chapter, text_key (unique, e.g. `ch1.zone.wormway.desc`), kind (speech | place | narration | item | boss | choice), speaker (NPC slug or empty), brief (Claude's point-form notes, read-only), body (Joshua's text, empty = unwritten), status (todo | draft | done), updated_at.
- Seed file `includes/data/trek_texts.txt` adds missing keys only. It never overwrites `body`, so admin edits are safe across updates.
- Code calls `trek_text('ch1.zone.wormway.desc', ['gnome' => $name])`. Tokens like {gnome}, {calling}, {trailmate} are swapped in.
- If body is empty, players see a neutral fallback ("…"); admins see the brief in a dashed box marked ✏️ TO WRITE.
- Treks stay admin-only (setting `trek_open` = off) until Chapter I text is done. Players never see placeholders.

## Admin page: admin/trek_text.php
- Filter by chapter, kind, status; "only unwritten" toggle; count of done/total per chapter.
- Each row: key, where it shows, speaker, brief (bullets), textarea for body, status, a preview of how it looks in game.
- Length hint per kind (e.g. speech ≤ 300 chars so it fits a phone card).
- One-click "Show me in game" link to the spot (admin teleports there).

## Brief format (what Claude writes)
- Where/when it shows.
- Who speaks + mood.
- Must cover: bullet facts the plot needs (names, clues, what to do next).
- Must not: spoilers, or anything that contradicts later chapters.
- Length hint.

Example
- key `ch1.recruit.burdock.freed` (speech, Burdock)
- Shows: after the gnome lifts the stone off Burdock in the Wormway.
- Mood: winded, grateful, a bit embarrassed.
- Must cover: thanks; he came down sniffing sour soil; the smell is like rot "but wrong"; he will come along; hint he knows something lives deeper.
- Must not: name Gloomtooth yet.
- Length: 2-3 short lines.
