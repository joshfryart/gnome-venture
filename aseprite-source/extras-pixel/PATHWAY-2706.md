# Aseprite pathway for the 2.7.06 icon set (Josh, 2026-11-17: "Sonnet writes, Opus executes")

Rule: Sonnet writes the brief, scaffold and Lua; Opus does the drawing pass that makes the final pixels. Contact sheet for review at the end.

| step | who | what | where |
|---|---|---|---|
| 1. brief + scaffold | Sonnet | One brief per icon (what it shows, 96x96, same family as `stage-*` and `roadkinds/*`), and a first Lua script in the gvlib "icon mode" | `aseprite-source/extras-pixel/scripts/build-verbs-a.lua`, `build-verbs-b.lua`, `roadkinds-2706.lua` |
| 2. first render | Sonnet | Run with the Aseprite CLI, look at it, up to 3 rounds | `art-2706/<name>.png`, `.aseprite` in `aseprite-source/extras-pixel/aseprite/` |
| 3. art pass | Opus | Redraws and polishes in the scripts (style guide v3: hard pixels, ink `#2b1c26` outline, no pure black or white, one quirk, reads at 20 px); originals kept in `art-2706/before/` | same scripts |
| 4. check + sheet | script | 96x96, no semi-transparent pixels, no #000000 / #ffffff; contact sheets `art-2706/contact.png` (first pass), `art-2706/contact-polish.png` (before | after) | `art-2706/` |
| 5. install | - | PNGs to `game/assets/img/steps/stage-<verb>.png` and `game/assets/img/roadkinds/<kind>.png`; art zip `upload-zips/gnome-venture-images-v3-2.7.06.zip` | |

Run: `/tmp/aseq/squashfs-root/AppRun -b --script-param root=<repo> --script-param out=<repo>/aseprite-source/extras-pixel/aseprite --script-param pngdir=<repo>/art-2706 --script <script> --script-param only=<name>`.
Known gap: gvlib `finish()` adds a pure-black 1 px border; the 2.7.06 scripts turn it into ink in `save()` / `inkfix()`. The older live icons still have it.
