# Git branches (2026-10-28, after 2.0.81)

`main` is the only branch that matters. It holds everything up to 2.0.81. Work branches are named `ccr-<id>` (one per Claude session) and go stale once merged.

**Merged into main, safe to delete** (history is on main): `ccr-145c0fb2-ynig5u`, `ccr-68e42fd5-szbn5x`, `ccr-7e2dadf5-mxypd7`, `ccr-825131e7-zk8c9y`, `claude/art-first-pass`, `claude/epic-ramanujan-krfzkn`.

**Not merged** (old session branches and release candidates, 2026-10-20 to 2026-10-28). Their histories diverge from main because main took reconciled copies, so "commits ahead" is large and does not mean unique work; nobody has diffed them one by one.
- Named older work: `art-hearthlight-2.0.21`, `emoji-icons`, `emoji-js-css`, `pixel-art-2.0.31`, `security-audit-fixes`, `trek-ch3b`, `trek-fight-touches`, `wip-2.0.8`, `wip-2.0.9`, `release/2.0.4`, `release/2.0.5`, `release/2.0.6`, `release/2.0.49-mobile-adventure-layout`, `feature/2.0.48-bulk-route-wait-time`, `claude/trek-combat-icons-pinch-8yzkc1`.
- About 20 session branches `ccr-*`: `git branch -r --no-merged origin/main` lists them.

**Rules:** one working branch per session; Joshua says when to push main (`git push origin HEAD:main`, fast-forward only); no tags are used (versions live in `CHANGELOG.md`, zips in `releases/`).
