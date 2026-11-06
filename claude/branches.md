# Git branches (2026-11-05, after 2.5.48; first line below is the 2026-10-28 note)

`main` is the only branch. It holds everything up to 2.0.81 and the docs. Work branches are named `ccr-<id>` (one per Claude session); delete them once merged.

**Cleanup 2026-10-28:** all old branches were assessed file by file against main (a branch counted as holding unique work only if it changed a file that main never changed). 38 held nothing main lacks (old session branches, release candidates `release/*`, `wip-*`, `emoji-*`, `pixel-art-*`, `trek-*`, `security-audit-fixes`, `art-hearthlight-2.0.21`, `feature/2.0.48-*`) and are SAFE TO DELETE. They were NOT deleted yet: the cloud session's permission system refused `git push origin --delete`, so Joshua deletes them (GitHub > Branches, or `git push origin --delete <names>`). Two held unique files, which were copied onto main first:
- `ccr-bed09876-oxhxre`: `claude/spec-puzzle-picks.md` (puzzle spec decisions).
- `ccr-6c5c40cf-o6btu9`: five puzzle pictures (Blinking Guy, Elmo Fire, Fry Squint, Homer Hedge, Stall Girl: GIF, still, Aseprite source, Lua script), a skeleton re-export. These files are in `game/assets/img/puzzles/` and `aseprite-source/extras-pixel/` but not in a release zip yet (next version).

**Rules:** one working branch per session; Joshua says when to push main (`git push origin HEAD:main`, fast-forward only); no tags are used (versions live in `CHANGELOG.md`, zips in `releases/`).

**2026-11-05:** `main` = `ccr-dedeb4af-hjr0wy` = 2.5.48 (`c72ee23d` before the doc update). That branch merged the old remote `ccr-dedeb4af-hjr0wy` with `-s ours` (no force push needed). No tags.
