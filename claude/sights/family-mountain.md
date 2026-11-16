# Family: mountain (2.7.01)
Built
- UI: `includes/trail_fam_mountain.php` + CSS "Mountain family" block (tfmountain, tfm-). "Echo Chain" strip for any section with a `mountain-` mark: altitude tint (levels by Sight count; mist at dawn/fog/snow/storm/frost, said in words), echo rings SVG (rings round the echo wall, one dot per other Sight, delay beats = ceil(tiles/3)), moon name, Echo Cheeks tally, 2 villager chips. No JS.
- Game: echo wall `check` now `pick:3:` rhythms (short/long); `tally=echo-cheeks` kept; extra pebble at new or full moon (`?mo=full` and `?mo=new` as two tokens: a token condition cannot list values, comma splits tokens).
- Quest `goat-ledge-census` (`trail_sight_quests_fam_mountain.txt`, giver Hazel Dewdrop): goat ledge, echo wall, eagle's rest, pine shelf (npc Hazel, dawn), goat ledge (npc Hazel, dawn). Folk rows `trail_sight_folk_fam_mountain.txt`: Hazel at goat ledge and pine shelf, dp=dawn, 100.
- Test: `tests/trail_fam_mountain.php/.sh`.
Open
- Delay is only drawn, not played: no engine token for "reply at the delay of a second Sight" (echo wall is a single pick row).
- Only echo wall is a pick Sight; scree-slope already had one. Other echo-style rows not added (no more mountain echo Sights).
- Hazel's old goat-ledge row (se=spring) stays; her dawn rows are separate.
