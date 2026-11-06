#!/usr/bin/env python3
"""Generate authored Trail maps (22 wide x 7 tall sections) for every route in claude/route-list.md that has no map yet.
Deterministic: the same route id always gives the same map. Writes one file per region group:
    claude/<region-slug>-trail-maps/<region-slug>_trail_maps.json   ({"routes": [...]}, the shape tools/bake_trail_art.py reads)
Skips the hand-made Maplewold routes (claude/maplewold-trail-maps/maplewold_trail_maps_22wide.json) unless --all. Then run:
    python3 -I tools/bake_trail_art.py --check claude/*-trail-maps     and, to bake the pictures,   python3 -I tools/bake_trail_art.py claude/*-trail-maps
Rules followed: claude/prompt-route-maps.md (S on x=0 of section 1, one 9 on x=21, floor on the previous exit row at x=0, 1 to 3 F off the line,
no E except the fixed miniboss/boss spot on the last section of a delve/lair route). Set pieces and captions are in the SETS tables below."""
import json, os, random, re, sys, zlib
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W, H = 22, 7

# (feature, caption) per land. Each route takes distinct ones per section; the last section may use an end-type piece instead.
SETS = {
 "grassland": [("the wind-combed meadow", "Grass lying down in one direction, as if told to. A kite string trails over the path."),
  ("the daisy ring", "A circle of daisies so even that someone must have measured. Nobody will own up."),
  ("the sleepy windmill", "A little windmill turning slowly, in no hurry at all."),
  ("the hay-cart ruts", "Two deep ruts from a cart that has long since gone home."),
  ("the picnic knoll", "A flat green knoll with a dent in it exactly the shape of a picnic."),
  ("the plank footbridge", "A plank bridge over a ditch. The ditch is not deep, but the bridge is proud."),
  ("the shepherd's wall", "A dry-stone wall running off into the grass, with a gate that is mostly decoration."),
  ("the dandelion drift", "A drift of dandelion fluff, ready to leave at the first sneeze."),
  ("the lonely scarecrow", "A scarecrow with a very small hat. The crows seem to like him."),
  ("the clover patch", "A clover patch. Someone has already checked every leaf for luck."),
  ("the old milestone", "A mossy milestone with the numbers worn off. It still points confidently."),
  ("the bramble gap", "A gap in the brambles, wide enough for one gnome and one opinion.")],
 "forest": [("the fallen-log bridge", "A great log laid across a gully. It wobbles, but only out of politeness."),
  ("the mushroom ring", "Toadstools in a tidy ring. The path goes round, because the path is sensible."),
  ("the hollow oak", "An oak so hollow it could host tea for six."),
  ("the fern tunnel", "Ferns arch overhead and drip softly on everyone's hat."),
  ("the owl-watch bough", "A low bough where an owl pretends not to see you."),
  ("the mossy stair", "Steps of root and moss, worn smooth by many small boots."),
  ("the acorn scatter", "Acorns everywhere, as though a squirrel had a very bad day."),
  ("the glow-moss grotto", "A damp hollow with moss that glows faintly, like a night-light."),
  ("the woodcutter's stump", "A giant stump, still carrying a very small axe."),
  ("the bluebell glade", "A glade of bluebells that seems to ring if you listen closely."),
  ("the root-tangle crossing", "Roots knot across the path like a puzzle with one answer: step high."),
  ("the lantern branch", "An old lantern hangs from a branch. Somebody trims its wick."),
  ("the spring and the pebbles", "A trickle of spring water over bright pebbles.")],
 "coast": [("the driftwood arch", "A bleached arch of driftwood, hung with shells that click in the wind."),
  ("the tide-pool steps", "Flat rocks full of small pools, each with a crab who has opinions."),
  ("the lighthouse shadow", "A far lighthouse throws a slow sweep of light over the sand."),
  ("the shell-heap", "A mound of shells, sorted by someone with strong feelings about spirals."),
  ("the rope-and-net rack", "Nets drying on a rack. A gull stands guard, badly."),
  ("the stranded rowboat", "A rowboat on the sand, waiting for the sea to come back and apologise."),
  ("the sea-stack gap", "A gap between two tall rocks where the spray tickles your ankles."),
  ("the sandbar causeway", "A narrow bar of sand with water either side, sparkling."),
  ("the kelp-line", "A line of kelp left by the tide, as neat as a ribbon."),
  ("the barnacle wall", "A rock wall crusted with barnacles. Please do not tickle them."),
  ("the bottle post", "A post with a bottle on top. There is a note inside. It says 'hello'."),
  ("the dune grass sweep", "Tall dune grass bows all one way, like an audience.")],
 "tundra": [("the star-chart stones", "Flat stones scratched with constellations by patient hands."),
  ("the ice-shelf steps", "Steps of pale ice that squeak under each boot."),
  ("the snow-fort", "A snow fort with a flag. It has seen better battles, and better snacks."),
  ("the frozen stream", "A frozen stream, bright as a window."),
  ("the cairn", "A neat cairn. Everyone adds a small stone for luck."),
  ("the aurora rise", "A low rise where the sky does green things at night."),
  ("the lone fir", "One fir tree wearing a good deal of snow.")],
 "desert": [("the waystone cluster", "Three weathered waystones leaning together like old friends."),
  ("the dry riverbed", "A river that left years ago and kept the bed made."),
  ("the cactus garden", "Cactus in a neat row. Somebody waters them. Somebody is brave."),
  ("the sun-bleached bones", "The bones of a very large, very friendly fish. Do not ask."),
  ("the shade awning", "A faded awning on two poles. Perfect for a very small nap."),
  ("the mirage pool", "A pool that is mostly shimmer, and a little bit not."),
  ("the red rock arch", "A rock arch that glows when the sun is low."),
  ("the well and its rope", "A well with a rope and a very patient bucket."),
  ("the sand-ripple lane", "Sand rippled like a washboard in neat lines."),
  ("the trader's tent poles", "Poles from a trader's tent, left up in case they return."),
  ("the salt flat", "A flat of white salt that crunches pleasantly.")],
 "mountain": [("the switchback bend", "A tight bend in the path, with a view of the way you just came."),
  ("the goat ledge", "A ledge with a goat. The goat is entirely unbothered."),
  ("the rope bridge", "A rope bridge, sturdy for its age and fond of swaying."),
  ("the scree slope", "A slope of loose small stones that tick and chatter underfoot."),
  ("the eagle's rest", "A flat boulder where an eagle likes to think."),
  ("the waterfall mist", "A waterfall mists the path with tiny rainbows."),
  ("the stone hut", "A little stone hut with a chimney and no one at home."),
  ("the cairn pass", "A pass marked with cairns, each taller than the last."),
  ("the echo wall", "A rock wall that gives your own voice back, only cheekier."),
  ("the pine shelf", "A shelf of pines clinging to a cliff for dear life."),
  ("the wind notch", "A notch in the ridge where the wind plays whatever it likes.")],
 "wetland": [("the reed causeway", "A narrow causeway through tall reeds, nodding hello."),
  ("the stilt-house", "A house on stilts, with a ladder that has gone for a walk."),
  ("the lily-pad ford", "Lily pads big enough to stand on. Almost."),
  ("the heron's post", "A post where a heron stands as if on a stage."),
  ("the boardwalk gap", "A boardwalk with one plank missing. A neat little hop."),
  ("the frog choir", "A bank of frogs rehearsing something important."),
  ("the peat bank", "A soft brown bank that smells of rain and old books."),
  ("the willow curtain", "Willow branches drape the path like a gentle curtain."),
  ("the mud-skipper flats", "Wet flats with small skippers who race for no reason."),
  ("the dragonfly bend", "A bend where dragonflies stitch the air with blue.")],
 "rainforest": [("the vine bridge", "A bridge of woven vines that hums when the wind comes through."),
  ("the giant fern glade", "Ferns taller than a gnome, nodding in the drip."),
  ("the orchid tree", "A tree dressed head to toe in orchids."),
  ("the stepping-roots", "Roots arching out of the mud like a row of green stairs."),
  ("the parrot perch", "A tall branch where parrots argue in three languages."),
  ("the mist-pool", "A still pool with mist curling over it like steam from soup."),
  ("the fallen giant", "A fallen tree, so big the path goes along its trunk."),
  ("the rain-drum leaf", "A huge leaf that drums when it rains. It is raining a little."),
  ("the canopy gap", "A gap in the canopy where the sun comes down in a column."),
  ("the lantern fruit", "Small glowing fruits hang low, just to be friendly.")],
 "island": [("the palm lean", "A palm tree that leans so far it has to be holding something."),
  ("the lagoon edge", "A lagoon as clear as glass, with tiny striped fish."),
  ("the rope swing", "A rope swing over a deep blue pool. It is begging to be used."),
  ("the shell-bell tree", "A tree hung with shells that chime like bells."),
  ("the coconut grove", "A grove of coconuts, each one trying to look innocent."),
  ("the sand spit", "A spit of white sand reaching out like a pointing finger."),
  ("the tide-cave", "A small cave that breathes in and out with the tide."),
  ("the hammock palms", "Two palms with a hammock. It has already been claimed by a crab."),
  ("the reef shallows", "Warm shallows full of brightly coloured fish.")],
}
LAND_FEEL = {  # wall density, width of floor (extra cells), rough-floor chance
 "grassland": (0.30, 0.55, 0.30), "forest": (0.45, 0.35, 0.25), "coast": (0.30, 0.45, 0.2), "tundra": (0.40, 0.35, 0.25),
 "desert": (0.20, 0.65, 0.2), "mountain": (0.55, 0.20, 0.3), "wetland": (0.55, 0.20, 0.3), "rainforest": (0.45, 0.35, 0.3), "island": (0.35, 0.40, 0.25)}
END = {  # the last section, by what is at the 'to' end
 "wonder": [("the {to} gates", "Something wonderful is close. You can feel it in your shoes."), ("the hush before {to}", "The air goes quiet, as if {to} were about to speak.")],
 "haven": [("the {to} path", "A smell of something warm drifts down the path from {to}."), ("the last turn to {to}", "A little sign, hand-painted: 'Rest Here'.")],
 "delve": [("the mine mouth of {to}", "The mouth of {to} breathes cool air and a hint of old echoes."), ("the lantern line to {to}", "A line of old lanterns leads to {to}. Please bring your own light.")],
 "lair": [("the long approach to {to}", "The grass goes silent. Something big is thinking about you from {to}."), ("the threshold of {to}", "A wide, scuffed circle of earth. The kind of place a very large friend might sleep.")],
}

def carve_section(rng, land, entry_y, exit_y, last_boss):
    wall, widen, rough = LAND_FEEL[land]
    g = [["#"] * W for _ in range(H)]
    y = entry_y
    g[y][0] = "."
    path = [(0, y)]
    for x in range(1, W - 1):
        g[y][x] = "."; path.append((x, y))
        if x < W - 2:
            r = rng.random()
            toward = (exit_y > y) - (exit_y < y)
            if r < 0.35 and toward: ny = y + toward
            elif r < 0.55: ny = y + rng.choice((-1, 1))
            else: ny = y
            ny = max(1, min(H - 2, ny))
            while y != ny:
                y += 1 if ny > y else -1; g[y][x] = "."; path.append((x, y))
    while y != exit_y:
        y += 1 if exit_y > y else -1; g[y][W - 2] = "."; path.append((W - 2, y))
    g[exit_y][W - 1] = "9"
    # widen: floor beside floor
    for _ in range(int(widen * 60)):
        x, yy = rng.randint(1, W - 2), rng.randint(1, H - 2)
        if g[yy][x] == "#" and any(g[yy + dy][x + dx] in ".," for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))): g[yy][x] = "."
    # a choice: a side loop with a find, off the main line
    x0 = rng.randint(5, 12); rows_off = [yy for yy in range(1, H - 1) if all(g[yy][x] == "#" for x in range(x0, x0 + 6))]
    if rows_off:
        yy = rng.choice(rows_off)
        for x in range(x0, x0 + 6): g[yy][x] = "."
        for xe in (x0, x0 + 5):   # join each end of the loop to the nearest floor above or below it
            for step in (1, -1):
                q = yy + step
                while 1 <= q <= H - 2 and g[q][xe] == "#": q += step
                if 1 <= q <= H - 2 and abs(q - yy) <= 2:
                    for r_ in range(min(q, yy), max(q, yy) + 1): g[r_][xe] = "."
                    break
    # wall decorations: keep walls near the middle of wide stretches
    for yy in range(1, H - 1):
        for x in range(1, W - 1):
            if g[yy][x] == "." and rng.random() < rough: g[yy][x] = ","
    # clear the wall cells so they never leave an open border except entry and exit
    for x in range(W): g[0][x] = "#"; g[H - 1][x] = "#"
    for yy in range(H):
        if yy != entry_y: g[yy][0] = "#"
        if yy != exit_y: g[yy][W - 1] = "#"
    g[exit_y][W - 1] = "9"
    seen, st = {(0, entry_y)}, [(0, entry_y)]   # drop floor that the entry cannot reach (a loop whose ends found no floor)
    while st:
        cx, cy = st.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < W and 0 <= ny < H and (nx, ny) not in seen and g[ny][nx] != "#": seen.add((nx, ny)); st.append((nx, ny))
    for yy in range(H):
        for x in range(W):
            if g[yy][x] != "#" and (x, yy) not in seen: g[yy][x] = "#"
    # tokens: finds off the main line (not on the shortest-walk cells), x from 3 to W-4
    main = set(path)
    cand = [(x, yy) for yy in range(1, H - 1) for x in range(4, W - 5) if g[yy][x] in ".," and (x, yy) not in main]
    rng.shuffle(cand)
    nF = rng.randint(1, 3)
    placed = []
    for (x, yy) in cand:
        if len(placed) >= nF: break
        if all(abs(x - a) + abs(yy - b) >= 3 for a, b in placed): placed.append((x, yy))
    if not placed:   # no side floor: take a spot on the line (never near entry / exit)
        x = W // 2; yy = next(q for q in range(1, H - 1) if g[q][x] in ".,"); placed.append((x, yy))
    for x, yy in placed: g[yy][x] = "F"
    if last_boss:   # the fixed miniboss / boss spot: on the line, 4 from the exit
        x = W - 5
        yy = next(q for q in range(1, H - 1) if g[q][x] in ".,F")
        g[yy][x] = "E"
    return ["".join(r) for r in g], exit_y

CAT = {}   # landmark slug -> {land, feature, caption, routes}: written to claude/trail-landmarks/setpieces.json (the art notes and the stand-in sprites read it)

def slugify(t): return re.sub(r"[^a-z0-9]+", "-", t.lower()).strip("-")

def walk_path(rows):
    from collections import deque
    st = next((x, y) for y, r in enumerate(rows) for x, c in enumerate(r) if x == 0 and c != "#")
    en = next((len(rows[0]) - 1, y) for y, r in enumerate(rows) if r[-1] == "9")
    prev, q = {st: None}, deque([st])
    while q:
        c = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (c[0] + dx, c[1] + dy)
            if 0 <= n[0] < W and 0 <= n[1] < H and rows[n[1]][n[0]] != "#" and n not in prev: prev[n] = c; q.append(n)
    out, c = set(), en
    while c is not None: out.add(c); c = prev[c]
    return out

def place_landmark(rng, rows, taken):
    """A floor cell off the walk line and off the finds, feet row 3 to 5 (tall sprites keep their top in the map), x 3..W-4, 2+ from other landmarks; best: close to the line."""
    line = walk_path(rows)
    best = []
    for y in range(3, H - 1):
        for x in range(3, W - 3):
            if rows[y][x] not in ".," or (x, y) in line or any(abs(x - a) + abs(y - b) < 3 for a, b in taken): continue
            d = min(abs(x - a) + abs(y - b) for a, b in line)
            if d >= 1: best.append((d, rng.random(), x, y))
    if not best:   # fallback: any floor cell off the line and not a token
        best = [(9, rng.random(), x, y) for y in range(1, H - 1) for x in range(2, W - 2) if rows[y][x] in ".," and (x, y) not in line]
    best.sort()
    return best[0][2], best[0][3]

def make_route(rid, frm, to, land, secs, end_kind, LM=None):
    rng = random.Random(zlib.crc32(f"gv-trail|{rid}".encode()))
    pool = SETS[land][:]
    rng.shuffle(pool)
    entry_y = rng.randint(1, H - 2)
    sections = []
    for si in range(secs):
        last = si == secs - 1
        exit_y = rng.randint(1, H - 2)
        srng = random.Random(zlib.crc32(f"gv-trail|{rid}|{si}".encode()))
        rows, exit_y = carve_section(srng, land, entry_y, exit_y, last and end_kind in ("delve", "lair"))
        if si == 0:
            rows = [("S" + r[1:]) if r[0] == "." or r[0] == "," else r for r in rows]
        if last and end_kind in END:
            k = rng.randrange(len(END[end_kind])); feat, cap = END[end_kind][k]; slug = f"end-{end_kind}-{k + 1}-{land}"
            CAT.setdefault(slug, {"land": land, "feature": f"the way into a {end_kind}: " + feat.format(to="<the place>"), "caption": cap.format(to="<the place>"), "routes": []})["routes"].append(rid)
            feat, cap = feat.format(to=to), cap.format(to=to)
        else:
            feat, cap = pool[si % len(pool)]; slug = land + "-" + slugify(feat)
            CAT.setdefault(slug, {"land": land, "feature": feat, "caption": cap, "routes": []})["routes"].append(rid)
        lx, ly = place_landmark(srng, rows, [])
        if LM is not None: LM.setdefault(str(rid), []).append([[lx, ly, slug, 0]])
        toks = [[x, y, c] for y, r in enumerate(rows) for x, c in enumerate(r) if c in "EF"]
        sections.append({"feature": feat, "caption": cap, "rows": rows, "tokens": toks})
        entry_y = exit_y
    return {"route_id": rid, "from": frm, "to": to, "land": land, "sections": sections}

def parse():
    out = []; grp = None
    for l in open(os.path.join(REPO, "claude", "route-list.md"), encoding="utf-8"):
        if l.startswith("## "): grp = re.sub(r" \(\d+ routes.*", "", l[3:]).strip()
        m = re.match(r"\| (\d+) \| (.*?) \((\w+)\) \| (.*?) \((\w+)\) \| (\w+) \| (\d) \| (\d+) \|", l)
        if m: out.append((grp, int(m[1]), m[2], m[4], m[6], int(m[7]), m[5]))
    return out

def slug(s): return re.sub(r"[^a-z0-9]+", "-", s.lower().replace("->", "to")).strip("-")

def main():
    have = set() if "--all" in sys.argv else {int(r["route_id"]) for r in json.load(open(os.path.join(REPO, "claude/maplewold-trail-maps/maplewold_trail_maps_22wide.json")))}   # the hand-made ones
    groups = {}
    LM = {}
    for grp, rid, frm, to, land, secs, endk in parse():
        if rid in have: continue
        groups.setdefault(grp, []).append(make_route(rid, frm, to, land, secs, endk, LM))
    n = 0
    for grp, rs in groups.items():
        d = os.path.join(REPO, "claude", slug(grp) + "-trail-maps"); os.makedirs(d, exist_ok=True)
        json.dump({"routes": rs}, open(os.path.join(d, slug(grp) + "_trail_maps.json"), "w"), indent=1, ensure_ascii=False)
        n += len(rs)
    d = os.path.join(REPO, "claude", "trail-landmarks"); os.makedirs(d, exist_ok=True)
    json.dump({"_note": "Landmarks for every route outside the Maplewold (generated by tools/gen_trail_maps.py): {route id: [[[x, y, slug, jitter]] per section]}. Same meaning as maplewold_landmarks.json. Slugs are shared set pieces (setpieces.json); sprites are stand-ins until drawn (claude/trail-setpiece-art-notes.md).", **LM}, open(os.path.join(d, "other_regions_landmarks.json"), "w"), separators=(",", ":"))
    json.dump(CAT, open(os.path.join(d, "setpieces.json"), "w"), indent=1, ensure_ascii=False)
    print(len(groups), "files,", n, "routes,", len(CAT), "set pieces")

if __name__ == "__main__": main()
