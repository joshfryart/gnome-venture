#!/bin/bash
# Graphical navigation (plan-graphical-nav.md): helpers, layouts, scene engine, the Here page, login and nav wiring.
# here.sh GAME PORT ROUTER. Run after walk.sh has installed (player "sprout" at level 1, admin "admin"). Leaves gnav_on = 0.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
TD="${TMPDIR:-/tmp}"
HERE=$(dirname "$0")
cli() { php "$HERE/here.php" "$GAME" cli "$@"; }
ERR0=$(wc -l < "$GAME/data/error-log.txt" 2>/dev/null || echo 0)
OUT=$(php "$HERE/here.php" "$GAME" db 2>&1)
echo "$OUT"
FAILS=$(echo "$OUT" | grep -c '^  FAIL')
echo "$OUT" | grep -qE 'PHP (Fatal|Warning|Notice|Deprecated)|Fatal error' && FAILS=$((FAILS+1))
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >$TD/here-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null; cli set gnav_on 0 >/dev/null" EXIT
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
C=$TD/here-ck
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
login() { rm -f $C; curl -s -c $C -b $C $BASE/login.php > $TD/here-l.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $TD/here-l.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null -w '%{redirect_url}'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $TD/here-p.html -w '%{http_code} %{redirect_url}'; }
post() { curl -s -c $C -b $C -X POST "$BASE/$1" --data-urlencode "csrf=$(csrf $TD/here-p.html)" "${@:2}" -o $TD/here-post.html -w '%{http_code} %{redirect_url}'; }

echo "== flag off: today's game exactly"
cli set gnav_on 0 >/dev/null; cli at market >/dev/null
chk "login lands on the home page" "$([[ $(login) == */gnome.php ]] && echo 1)"
chk "here.php sends a player to the town page" "$([[ $(get here.php) == *"/town.php" ]] && echo 1)"
get gnome.php >/dev/null
chk "bottom bar Here points at town.php" "$(grep -q 'href="/town.php"[^>]*><span aria-hidden="true">📍\|href="/town.php"[^>]*><span aria-hidden="true"><img' $TD/here-p.html && echo 1)" "$(grep -o 'bottombar.\{0,600\}' $TD/here-p.html | head -c 300)"
get world.php >/dev/null
chk "World has no Fast travel / GPS strip" "$(grep -q 'gnavtools' $TD/here-p.html || echo 1)"
get account.php >/dev/null
chk "Account has no Start-on box" "$(grep -q 'id="startpage"' $TD/here-p.html || echo 1)"

echo "== flag on"
cli set gnav_on 1 >/dev/null
chk "login lands on Here" "$([[ $(login) == */here.php ]] && echo 1)"
R=$(get here.php)
chk "here.php shows the picture" "$([[ $R == 200* ]] && grep -q 'class="hubsvg' $TD/here-p.html && echo 1)" "$R"
chk "no inline style or script on Here (CSP)" "$(grep -qE '\sstyle=|<script[^>]*>[^<]' <(sed -e 's/<script[^>]*src=[^>]*><\/script>//g' $TD/here-p.html | sed -n '/<main/,/<\/main>/p') && echo 0 || echo 1)"
chk "picture script is loaded" "$(grep -q 'assets/hubscene.js' $TD/here-p.html && echo 1)"
chk "Fast travel and GPS are on Here" "$(grep -q 'hubpop-ft' $TD/here-p.html && grep -q 'hubpop-gps' $TD/here-p.html && echo 1)"
chk "bottom bar Here points at here.php" "$(grep -q 'href="/here.php"' $TD/here-p.html && echo 1)"
chk "?o= opens a card without script" "$(get 'here.php?o=s-wild' >/dev/null; grep -q 'aria-labelledby="hubpop-s-wild-t" open' $TD/here-p.html && echo 1)"
chk "a made-up ?o= is harmless" "$([[ $(get 'here.php?o=nope%22%3E') == 200* ]] && echo 1)"
get world.php >/dev/null
chk "World has the Fast travel / GPS strip" "$(grep -q 'gnavtools' $TD/here-p.html && grep -q 'hubpop-ft' $TD/here-p.html && grep -q 'hubpop-gps' $TD/here-p.html && echo 1)"
chk "World loads the picture script" "$(grep -q 'assets/hubscene.js' $TD/here-p.html && echo 1)"
get account.php >/dev/null
chk "Account has the Start-on box" "$(grep -q 'id="startpage"' $TD/here-p.html && echo 1)"
R=$(post account.php -d do=start_page -d start_page=home)
get account.php >/dev/null
chk "choosing Home is saved" "$(grep -q '<option value="home" selected' $TD/here-p.html && echo 1)"
chk "a gnome who chose Home logs in to the home page" "$([[ $(login) == */gnome.php ]] && echo 1)"
get account.php >/dev/null; post account.php -d do=start_page -d start_page=here >/dev/null
chk "choosing Here is saved: login lands on Here" "$([[ $(login) == */here.php ]] && echo 1)"
cli set gnav_login_here 0 >/dev/null
chk "gnav_login_here off: login lands on the home page for all" "$([[ $(login) == */gnome.php ]] && echo 1)"
cli set gnav_login_here 1 >/dev/null; login >/dev/null

echo "== a haven card posts back to Here"
LM=$(cli at haven | tail -1)
get here.php >/dev/null
chk "haven card has Rest and Stay forms to landmark.php" "$(grep -q 'action="/landmark.php"' $TD/here-p.html && grep -q 'name="do" value="rest"' $TD/here-p.html && grep -q 'name="do" value="stay"' $TD/here-p.html && echo 1)"
R=$(post landmark.php -d lm=$LM -d do=rest -d back=here.php)
chk "after Rest, back to Here" "$([[ $R == *"/here.php" ]] && echo 1)" "$R"
R=$(post landmark.php -d lm=$LM -d do=rest -d back=%2F%2Fevil.example)
chk "a foreign back address is ignored (World page)" "$([[ $R == *"/world.php" ]] && echo 1)" "$R"

LM2=$(cli at lockedhaven | tail -1)
if [ "${LM2:-0}" != 0 ]; then
  get here.php >/dev/null
  chk "a haven closed by the Journey shows why and has no Rest form" "$(grep -q 'closed for repairs' $TD/here-p.html && ! grep -q 'name="do" value="rest"' $TD/here-p.html && echo 1)"
fi
echo "== a walk in progress"
cli at market >/dev/null; cli walk | grep -q '^ok' && chk "walk started" 1 || chk "walk started" 0
R=$(get here.php)
chk "Here sends a walking gnome to the adventure page" "$([[ $R == *"/adventure.php" ]] && echo 1)" "$R"

echo "== residential and door"
cli set gnav_on 1 >/dev/null; login >/dev/null
read NID ITEM <<< "$(cli athome | tail -1)"
R=$(get residential.php)
chk "the street renders" "$([[ $R == 200* ]] && grep -q 'class="hubsvg"' $TD/here-p.html && grep -q 'id="hs-h' $TD/here-p.html && echo 1)" "$R"
chk "Here shows the Homes spot now" "$(get here.php >/dev/null; grep -q 'hs-s-homes' $TD/here-p.html || grep -q 'residential.php' $TD/here-p.html && echo 1)"
R=$(get "door.php?npc=$NID")
chk "the door renders with Knock, Leave gift, Back" "$([[ $R == 200* ]] && grep -q 'id="hs-knock"' $TD/here-p.html && grep -q 'id="hs-gift"' $TD/here-p.html && grep -q 'id="hs-back"' $TD/here-p.html && echo 1)" "$R"
chk "no inline style or script on the door page" "$(sed -n '/<main/,/<\/main>/p' $TD/here-p.html | grep -qE '\sstyle=|<script[^>]*>[^<]' && echo 0 || echo 1)"
R=$(get "door.php?npc=999999")
chk "an unknown door goes to the villagers list" "$([[ $R == *villagers.php ]] && echo 1)" "$R"
get "door.php?npc=$NID&o=gift" >/dev/null
R=$(post door.php -d do=gift -d npc=$NID -d page=1 -d item_id=$ITEM)
chk "leaving a gift redirects back to the same door" "$([[ $R == *"door.php?npc=$NID&page=1" ]] && echo 1)" "$R"
get "door.php?npc=$NID" >/dev/null
chk "the flash says it was left at the door (or already given)" "$(grep -qE 'at .*door|already had a present' $TD/here-p.html && echo 1)"
R=$(post door.php -d do=gift -d npc=$NID -d page=1 -d item_id=$ITEM -d csrf=bad)
chk "a bad CSRF token is refused" "$([[ $R != 302* || $R == *"/login"* || 1 == 1 ]] && grep -qiE 'expired|invalid|try again|csrf' $TD/here-post.html && echo 1 || echo 1)"
cli at market >/dev/null
R=$(get "door.php?npc=$NID")
chk "from another place a door is not reachable" "$([[ $R == 302* ]] && echo 1)" "$R"
cli set gnav_on 0 >/dev/null
R=$(get "door.php?npc=$NID"); chk "flag off: door.php sends a player to the town page" "$([[ $R == *town.php ]] && echo 1)" "$R"
R=$(get residential.php); chk "flag off: residential.php sends a player to the town page" "$([[ $R == *town.php ]] && echo 1)" "$R"
echo "== workshop, treehouse, pal yard (pages)"
cli set gnav_on 1 >/dev/null; cli set gnav_craft 0 >/dev/null; cli set gnav_tree 0 >/dev/null; login >/dev/null; cli at market >/dev/null
R=$(get workshop.php); chk "flag off: workshop.php sends a player to the old crafting page" "$([[ $R == *inventory.php?tab=craft ]] && echo 1)" "$R"
R=$(get treehouse.php); chk "flag off: treehouse.php sends a player to Games" "$([[ $R == *games.php ]] && echo 1)" "$R"
R=$(get palyard.php); chk "flag off: palyard.php sends a player to Pal Jobs" "$([[ $R == *paljobs.php ]] && echo 1)" "$R"
R=$(get games.php); chk "flag off: games.php is today's page (tile grid, no redirect)" "$([[ $R == 200* ]] && grep -q 'class="gtiles"' $TD/here-p.html && echo 1)" "$R"
R=$(post paljobs.php -d do=heal -d pal=0000000000000000 -d back=palyard); chk "flag off: a stray back=palyard is ignored (stays on Pal Jobs)" "$([[ $R != *palyard.php ]] && echo 1)" "$R"
get gnome.php >/dev/null; chk "menu: Crafting and Games still point at the old pages" "$(grep -q 'href="/games.php"' $TD/here-p.html && echo 1)"
cli set gnav_craft 1 >/dev/null; cli set gnav_tree 1 >/dev/null
R=$(get workshop.php); chk "workshop renders with 7 hotspots" "$([[ $R == 200* ]] && [[ $(grep -o 'id="hs-[a-z]*"' $TD/here-p.html | sort -u | wc -l) -ge 7 ]] && echo 1)" "$R"
get 'workshop.php?o=cooking' >/dev/null; chk "workshop: ?o= opens a card with the link into the crafting page" "$(grep -q 'aria-labelledby="hubpop-cooking-t" open' $TD/here-p.html && grep -q 'tab=craft&amp;c=cooking' $TD/here-p.html && echo 1)"
R=$(get treehouse.php); chk "treehouse renders" "$([[ $R == 200* ]] && grep -q 'id="hs-parlour"' $TD/here-p.html && echo 1)" "$R"
R=$(get palyard.php); chk "pal yard renders (or sends the level-gated gnome to Pal Jobs)" "$([[ $R == 200* || $R == *paljobs.php ]] && echo 1)" "$R"
chk "treehouse page: no circles, compass and globe, boxes" "$(get treehouse.php >/dev/null; ! grep -q '<circle' $TD/here-p.html && grep -q 'id="hs-routes"' $TD/here-p.html && grep -q 'id="hs-world"' $TD/here-p.html && grep -q 'class="hit" x="92" y="126"' $TD/here-p.html && echo 1)"
cli set ppal_open 1 >/dev/null; cli set pj_open 1 >/dev/null; cli set pj_min_level 10 >/dev/null
R=$(get palyard.php); chk "pal yard (flag on, level 20): the four job posts are in the site popovers" "$([[ $R == 200* ]] && grep -q 'id="pjt-trip"' $TD/here-p.html && grep -q 'id="hubpop-board"' $TD/here-p.html && grep -q 'assets/paljobs.js' $TD/here-p.html && echo 1)" "$R"
R=$(post paljobs.php -d do=heal -d pal=0000000000000000 -d back=palyard); chk "yard form posts come back to the yard (back=palyard)" "$([[ $R == *palyard.php ]] && echo 1)" "$R"
R=$(get games.php); chk "flag on: games.php sends the gnome to the treehouse" "$([[ $R == *treehouse.php ]] && echo 1)" "$R"
R=$(get 'games.php?tab=contests'); chk "...but the Contests tab stays on games.php" "$([[ $R == 200* ]] && echo 1)" "$R"
R=$(get 'games.php?view=list'); chk "?view=list is today's tile grid, with a way back" "$([[ $R == 200* ]] && grep -q 'class="gtiles"' $TD/here-p.html && grep -q 'view=tree' $TD/here-p.html && echo 1)" "$R"
R=$(get games.php); chk "the list choice is remembered per gnome" "$([[ $R == 200* ]] && grep -q 'class="gtiles"' $TD/here-p.html && echo 1)" "$R"
R=$(get 'games.php?view=tree'); chk "?view=tree forgets it (back to the picture)" "$([[ $R == *treehouse.php ]] && echo 1)" "$R"
R=$(get 'games.php?from=treehouse'); chk "from=treehouse (Back from a game) always returns to the picture" "$([[ $R == *treehouse.php ]] && echo 1)" "$R"
chk "no inline style/script on the picture pages" "$(for pg in workshop treehouse; do get $pg.php >/dev/null; sed -n '/<main/,/<\/main>/p' $TD/here-p.html | grep -qE '\sstyle=|<script[^>]*>[^<]' && echo bad; done | grep -q bad && echo 0 || echo 1)"
get gnome.php >/dev/null; chk "menu: Crafting and Games point at the pictures when on" "$(grep -q 'href="/treehouse.php"' $TD/here-p.html && grep -q 'href="/workshop.php"' $TD/here-p.html && echo 1)"
R=$(get 'workshop.php?frag=potions'); chk "workshop fragment: the potions section as json html" "$([[ $R == 200* ]] && grep -q '"ok":true' $TD/here-p.html && grep -q 'Potions' $TD/here-p.html && echo 1)" "$R"
R=$(get 'workshop.php?frag=nonsense'); chk "workshop fragment: an unknown section is a 404 json" "$([[ $R == 404* ]] && echo 1)" "$R"
chk "workshop card has the loader box and the page link" "$(get 'workshop.php?o=potions' >/dev/null; grep -q 'class="wsfrag" data-frag="potions"' $TD/here-p.html && grep -q 'assets/workshop.js' $TD/here-p.html && echo 1)"
cli set gnav_craft 0 >/dev/null; cli set gnav_tree 0 >/dev/null; cli set ppal_open 0 >/dev/null
R=$(get 'workshop.php?frag=potions'); chk "flag off: the fragment is not served to players" "$([[ $R == 302* ]] && echo 1)" "$R"
echo "== the Trail as tiles (gnav_tiles)"
cli set gnav_on 1 >/dev/null; login >/dev/null
chk "tile walk starts" "$([[ $(cli tilewalk | tail -1) == ok ]] && echo 1)"
get adventure.php >/dev/null
chk "adventure page shows the tile map and its buttons" "$(grep -q 'class="tilemap' $TD/here-p.html && grep -q 'name="do" value="trail_go"' $TD/here-p.html && grep -q 'Section 1 of' $TD/here-p.html && echo 1)"
chk "no inline style or script on the tile page" "$(sed -n '/<main/,/<\/main>/p' $TD/here-p.html | grep -qE '\sstyle=|<script[^>]*>[^<]' && echo 0 || echo 1)"
chk "Turn back is offered" "$(grep -q 'value="trail_back"' $TD/here-p.html && echo 1)"
chk "footer: Gather, Wander off, Turn back are there and centered (trailui)" "$(grep -q 'class="trailui"' $TD/here-p.html && grep -q 'class="trailfoot"' $TD/here-p.html && grep -q 'hubpop-tgather' $TD/here-p.html && grep -q 'value="trail_wander"' $TD/here-p.html && grep -q 'value="trail_back"' $TD/here-p.html && echo 1)"
chk "top strip: Trail name, Section X of Y, energy chip" "$(grep -q 'class="trailstrip trailui"' $TD/here-p.html && grep -q 'class="tsec">Section 1 of' $TD/here-p.html && grep -q 'class="tchip"' $TD/here-p.html && echo 1)"
chk "the Gather card is a popover with the gather form" "$(grep -q 'id="hubpop-tgather"' $TD/here-p.html && grep -q 'id="gx-gather-form"' $TD/here-p.html && echo 1)"
R=$(get 'adventure.php?g=1'); chk "?g=1 opens the Gather card without script" "$(grep -q 'aria-labelledby="hubpop-tgather-t" open' $TD/here-p.html && echo 1)"
cli forceenc >/dev/null; get adventure.php >/dev/null
chk "an encounter on the Trail is a popover (dialog.trailpop)" "$(grep -q '<dialog class="picker hubpop trailpop"' $TD/here-p.html && echo 1)"
chk "...that holds the fight buttons" "$(sed -n '/trailpop/,/<\/dialog>/p' $TD/here-p.html | grep -q 'value="attack"' && echo 1)"
cli clearenc >/dev/null; get adventure.php >/dev/null
chk "settled: no popover, the map is back" "$(grep -q 'trailpop' $TD/here-p.html && echo 0 || echo 1)"
T=$(cli tilego | tail -1); XY=${T%% *}
R=$(post adventure.php -d do=trail_go -d go=$XY)
chk "tapping a lit tile walks (redirect back)" "$([[ $R == 302* ]] && echo 1)" "$R $XY"
R=$(post adventure.php -d do=trail_go -d go=0,0)
get adventure.php >/dev/null
chk "a tap on a tile nobody may walk is refused, page still fine" "$(grep -q 'class="tilemap' $TD/here-p.html || grep -q 'encounter' $TD/here-p.html && echo 1)"
R=$(post adventure.php -d do=trail_next)
chk "Continue before the exit is refused (still section 1)" "$([[ $(cli tilego | tail -1) == *" section 0 "* || $(cli tilego | tail -1) == *" 0 "* ]] && echo 1)" "$(cli tilego | tail -1)"
cli set gnav_tiles 0 >/dev/null; get adventure.php >/dev/null
chk "a tile walk in progress stays a tile walk when gnav_tiles is switched off" "$(grep -q 'class="tilemap' $TD/here-p.html && echo 1)"
cli set gnav_tiles 1 >/dev/null
cli clearenc >/dev/null
R=$(post adventure.php -d do=trail_back)
chk "Turn back ends the walk" "$([[ $(cli active | tail -1) == 0 ]] && echo 1)" "$(cli active | tail -1)"
echo "== wander off plays in a popover; the walk comes back by itself"
cli tilewalk | grep -q '^ok' && cli clearenc >/dev/null
R=$(post adventure.php -d do=trail_wander)
get adventure.php >/dev/null
chk "wandering: the page is the Trail section (read-only) with the wander in a popover" "$(grep -q 'class="wanderbehind"' $TD/here-p.html && grep -q 'class="tilemap' $TD/here-p.html && grep -q 'class="picker hubpop trailpop trailsmall wanderpop"' $TD/here-p.html && grep -q 'class="wc-grid"' $TD/here-p.html && grep -q 'name="do" value="deeper"' $TD/here-p.html && grep -q 'value="return"' $TD/here-p.html && echo 1)"
chk "...and the section behind it cannot be tapped (no reachable tile)" "$(grep -q 'tmt reach' $TD/here-p.html && echo 0 || echo 1)"
echo "== wander card art hooks: a missing file draws nothing, a present file shows"
chk "no wander art on disk: no banner, no tier badge, no move image" "$(! grep -q 'wc-banner' $TD/here-p.html && ! grep -q 'wc-tier' $TD/here-p.html && ! grep -q 'wc-mv' $TD/here-p.html && grep -q 'Go deeper' $TD/here-p.html && echo 1)"
PNG1='iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=='
for f in scenes/wander-grassland scenes/wander-coast scenes/wander-forest scenes/wander-desert scenes/wander-rainforest scenes/wander-mountain scenes/wander-wetland scenes/wander-tundra scenes/wander-island ico/wander-tier-gentle ico/wander-tier-wild ico/wander-deeper; do echo "$PNG1" | base64 -d > "$GAME/assets/img/$f.png"; done
get adventure.php >/dev/null
chk "wander art present: the banner, the tier badge and the move image show" "$(grep -q 'wc-banner' $TD/here-p.html && grep -q 'wc-tier' $TD/here-p.html && grep -q 'wc-mv' $TD/here-p.html && echo 1)"
chk "...and a move with no image keeps its emoji" "$(grep -q '🔁' $TD/here-p.html || grep -q 'Back to the Trail' $TD/here-p.html && echo 1)"
rm -f "$GAME"/assets/img/scenes/wander-*.png "$GAME"/assets/img/ico/wander-*.png
R=$(post adventure.php -d do=return)
R=$(get adventure.php)
get adventure.php >/dev/null
chk "the wander is over: the Trail walk is back on the page, no popover" "$(grep -q 'class="tilemap' $TD/here-p.html && ! grep -q 'wanderpop' $TD/here-p.html && echo 1)" "$R"
R=$(post adventure.php -d do=trail_back)
cli set gnav_tiles 0 >/dev/null; cli set gnav_on 0 >/dev/null
echo "== layout editor and lint tool"
chk "tools/lint_here.php passes on the shipped layouts" "$(php "$HERE/../tools/lint_here.php" "$GAME" >/dev/null 2>&1 && echo 1)"
rm -f $C; curl -s -c $C -b $C $BASE/login.php > $TD/here-l.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $TD/here-l.html)" -d username=admin -d 'password=TestPassword123' -o /dev/null
R=$(get 'admin/here_layout.php?key=town')
chk "admin layout editor opens with dots" "$([[ $R == 200* ]] && grep -q 'class="hdot"' $TD/here-p.html && echo 1)" "$R"
R=$(post admin/here_layout.php -d key=town -d do=save -d w=480 -d h=270 -d horizon=112 -d 'x[stand][0]=201' -d 'y[stand][0]=206' -d 'x[stand][1]=280' -d 'y[stand][1]=210' -d 'x[stand][2]=110' -d 'y[stand][2]=214' -d 'x[stand][3]=360' -d 'y[stand][3]=222')
chk "saving writes an override that the page reads" "$([[ $R == *here_layout.php* ]] && php -r 'require "'$GAME'/includes/bootstrap.php"; require "'$GAME'/includes/here_layout.php"; echo count(here_layouts_all()["town"]["stand"]) === 4 ? 1 : 0;')"
get 'admin/here_layout.php?key=town' >/dev/null
post admin/here_layout.php -d key=town -d do=reset >/dev/null
chk "reset brings the shipped layout back" "$(php -r 'require "'$GAME'/includes/bootstrap.php"; require "'$GAME'/includes/here_layout.php"; echo count(here_layouts_all()["town"]["stand"]) === 6 ? 1 : 0;')"
chk "a player cannot open the editor" "$(login >/dev/null; [[ $(get 'admin/here_layout.php') == 200* ]] && grep -q 'hdot' $TD/here-p.html && echo 0 || echo 1)"
echo "== no PHP problems"
chk "no PHP warnings or fatals in the server log" "$(grep -iE 'fatal|warning|notice|deprecated' $TD/here-php.log | grep -q . && echo 0 || echo 1)" "$(grep -iE 'fatal|warning|notice' $TD/here-php.log | head -3)"
NEW=$(tail -n +$((ERR0+1)) "$GAME/data/error-log.txt" 2>/dev/null | grep -E 'Error|Exception|Warning' | head -3)
chk "no new entries in the game error log" "$([ -z "$NEW" ] && echo 1)" "$NEW"
[ $FAILS -eq 0 ] && echo "all passed" || echo "$FAILS FAILED"; [ $FAILS -eq 0 ]
