#!/usr/bin/env python3
"""Build per-pal params (ramps, knob, accessory, face, quirk, sparkle) -> params.lua for perch_gen.lua.
usage: build_params.py [repo] [outfile]"""
import sys, re, colorsys, hashlib, os
import numpy as np
from PIL import Image

REPO = sys.argv[1] if len(sys.argv) > 1 else "/home/user/gnome-venture"
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "params.lua")
DATA = REPO + "/game/includes/data/puzzle_pals.txt"
STK = REPO + "/game/assets/img/puzzles/pals/%s.png"

def H(key, salt):
    return int(hashlib.md5((key + "|" + salt).encode()).hexdigest()[:8], 16)

def hx(rgb):
    r, g, b = [max(8, min(247, int(round(v)))) for v in rgb]  # no pure black / white
    return "#%02x%02x%02x" % (r, g, b)

def hls(rgb):
    return colorsys.rgb_to_hls(*[v / 255 for v in rgb])

def fromhls(h, l, s):
    return [v * 255 for v in colorsys.hls_to_rgb(h % 1.0, max(0, min(1, l)), max(0, min(1, s)))]

def hue_mix(h, target, t):  # circular blend
    d = ((target - h + 0.5) % 1.0) - 0.5
    return (h + d * t) % 1.0

WARM, VIOLET = 50 / 360, 268 / 360

def kmeans(px, k=5, iters=12, seed=1):
    rng = np.random.default_rng(seed)
    c = [px[rng.integers(len(px))]]
    for _ in range(k - 1):
        d = np.min(((px[:, None, :] - np.array(c)[None]) ** 2).sum(2), axis=1)
        c.append(px[rng.choice(len(px), p=d / d.sum())] if d.sum() > 0 else px[rng.integers(len(px))])
    c = np.array(c, float)
    for _ in range(iters):
        lab = ((px[:, None, :] - c[None]) ** 2).sum(2).argmin(1)
        for i in range(k):
            m = lab == i
            if m.any():
                c[i] = px[m].mean(0)
    cnt = np.bincount(((px[:, None, :] - c[None]) ** 2).sum(2).argmin(1), minlength=k)
    return c, cnt

def ramp_from(base_rgb_list, fam=None):
    """5 colours (any order) -> 5-tone ramp lightest..darkest: spaced lightness, warm light / violet shade."""
    cs = sorted(base_rgb_list, key=lambda c: -hls(c)[1])
    Ls = [hls(c)[1] for c in cs]
    med = Ls[2]
    out = []
    for i, c in enumerate(cs):
        h, l, s = hls(c)
        syn = max(0.2, min(0.93, med + (2 - i) * 0.125))
        l2 = 0.5 * l + 0.5 * syn
        if fam: h, s = hue_mix(h, fam[0], .85), .7 * fam[1] + .3 * s
        out.append([h, l2, s])
    for i in range(1, 5):  # strictly descending with min step
        out[i][1] = min(out[i][1], out[i - 1][1] - 0.07)
    res = []
    for i, (h, l, s) in enumerate(out):
        if i == 0: h = hue_mix(h, WARM, 0.10)
        if i == 1: h = hue_mix(h, WARM, 0.05)
        if i == 3: h = hue_mix(h, VIOLET, 0.12)
        if i == 4: h = hue_mix(h, VIOLET, 0.28); s = min(1, s * 1.05 + 0.04)
        l = max(0.13 + (4 - i) * 0.0 , l) if i == 4 else l
        res.append(hx(fromhls(h, max(0.14, l), s)))
    return res

def sticker_ramps(key):
    im = Image.open(STK % key).convert("RGBA")
    a = np.array(im).reshape(-1, 4)
    a = a[a[:, 3] > 128][:, :3].astype(float)
    if len(a) == 0:
        a = np.array([[150, 150, 150.]])
    L = np.array([hls(p)[1] for p in a])
    keep = a[L > 0.16]
    if len(keep) >= 40:
        a = keep
    if len(a) > 2500:
        a = a[np.random.default_rng(3).choice(len(a), 2500, replace=False)]
    c, cnt = kmeans(a, 5, seed=H(key, "km") % 1000)
    # weighted mean colour -> hue identity
    main = (c * cnt[:, None]).sum(0) / cnt.sum()
    top = c[cnt.argmax()]
    th, tl, ts = hls(top)
    fw = []
    for ci, n in zip(c, cnt):
        h_, l_, s_ = hls(ci)
        if ts < .15 or (s_ > .12 and abs(((h_ - th + .5) % 1) - .5) < 45 / 360):
            fw.append((h_, s_, n))
    if ts < .15 or not fw:
        fam = (th, ts)
    else:
        w = sum(x[2] for x in fw)
        # circular mean of hue
        import math
        sx = sum(math.cos(x[0] * 6.2832) * x[2] for x in fw); sy = sum(math.sin(x[0] * 6.2832) * x[2] for x in fw)
        fam = ((math.atan2(sy, sx) / 6.2832) % 1.0, sum(x[1] * x[2] for x in fw) / w)
    ramp = ramp_from(list(c), fam)
    # secondary: cluster most different from main in hue/sat among the five
    best, bd = None, -1
    mh, ml, ms = hls(main)
    for ci in c:
        h, l, s = hls(ci)
        dh = abs(((h - mh + .5) % 1) - .5)
        d = dh * 2 * min(s, ms + .2) + abs(l - ml) * .8 + abs(s - ms) * .3
        if d > bd: bd, best = d, ci
    h, l, s = hls(best)
    sec = [fromhls(h, l + dl, s) for dl in (0.25, 0.12, 0.0, -0.12, -0.22)]
    sec = ramp_from([fromhls(h, max(.2, min(.9, l + dl)), s) for dl in (0.22, 0.11, 0, -0.11, -0.22)])
    return ramp, sec, mh, ms, ml

# accent ramps for cloth-ish accessories (5 tones)
ACC_HUES = {"red": (4, .62), "orange": (24, .75), "yellow": (46, .8), "lime": (90, .6), "green": (135, .5), "teal": (175, .55),
            "sky": (200, .65), "blue": (222, .6), "purple": (272, .5), "pink": (330, .65), "brown": (22, .38), "cream": (42, .4)}
def acc_ramp(name):
    h, s = ACC_HUES[name]
    h /= 360
    if name == "cream":
        Ls = (.93, .86, .76, .62, .48)
    else:
        Ls = (.8, .66, .53, .40, .29)
    out = []
    for i, l in enumerate(Ls):
        hh = hue_mix(h, WARM, .08) if i == 0 else (hue_mix(h, VIOLET, .15) if i == 3 else (hue_mix(h, VIOLET, .3) if i == 4 else h))
        out.append(hx(fromhls(hh, l, s)))
    return out

# ---------------- keyword -> accessory tables (first match wins; name checked before blurb) ----------------
HAT_KW = [
 ("mushroom", "mushroom|toadstool|spore|fungus|shroom|truffle"),
 ("crown", "crown|king|queen|royal|throne|prince|regal|diadem"),
 ("wizard", "wizard|witch|star|moon|night|owl|dusk|comet|astro|sage|mystic|spell"),
 ("chefhat", "chef|cook|bake|bread|noodle|stew|soup|brew|pot|kettle|dumpling|pie|cake|feast"),
 ("minerhat", "miner|mine|cave|quarry|cavern|ore|tunnel|dig|gem"),
 ("tuft", "wheat|barley|reed|grain|catkin|oat|rye|thatch|straw tuft|cattail"),
 ("straw", "straw|farm|hay|field|scarecrow|harvest|rice|paddy|corn|maize|meadow|plough|plow"),
 ("acorncap", "acorn|oak|nut|chestnut|hazel|walnut|pecan"),
 ("fez", "fez|bazaar|souk|spice|camel|desert|dune|oasis|market"),
 ("conehat", "cone|bamboo|pagoda|ferry|boat|stupa|temple|monk|rain hat|lantern boat"),
 ("snowcap", "snow|ice|frost|winter|glacier|cold|frozen|icicle|blizzard|chill"),
 ("flame", "flame|fire|ember|lava|volcano|candle|cinder|blaze|hot|warm|kiln"),
 ("antlers", "antler|deer|stag|goat|yak|ram|elk|moose|horn|ibex"),
 ("helmet", "helm|knight|guard|shield|castle|tower|watch|armor|armour|soldier|sentinel|wall|fort"),
 ("tophat", "top hat|gentle|merchant|banker|tea|clock|dapper|host|butler|mayor|ring-?master"),
 ("fruit", "berry|cherry|apple|fruit|plum|peach|orange|lemon|pear|grape|fig|olive|mango|melon"),
 ("flowercrown", "flower|petal|bloom|blossom|rose|lotus|daisy|tulip|poppy|marigold|lily|orchid|pink|bud|bouquet|garden"),
 ("leafcrown", "leaf|leaves|maple|fern|ivy|moss|vine|forest|tree|bough|branch|willow|birch|pine|bark|wood|grove|jungle"),
 ("sprout", "sprout|seedling|grass|clover|shoot|green|sapling|seed|root"),
 ("feather", "feather|bird|finch|wing|swallow|crane|heron|gull|jay|sparrow|stork|eagle|parrot|plume|flock|nest|duck|goose"),
 ("ears", "cat|bear|fox|wolf|fur|mouse|rabbit|hare|panda|squirrel|badger|hedgehog|otter|beaver|lynx|puppy|kit|cub|mole"),
 ("bucket", "fish|koi|crab|shell|sea|wave|tide|river|lake|pond|reef|fisher|sail|harbor|harbour|pearl|splash|stream|canal|dock"),
 ("bandana", "bandana|pirate|thief|bandit|rogue|outlaw|rascal|sneak|scamp|prank"),
 ("bow", "bow|ribbon|gift|sweet|candy|honey|sugar|cute|puff|fluff|snug|cozy|cosy|pillow"),
]
HAT_DEFAULT = ["beret", "beanie", "bow", "sprout", "bucket", "ears", "flowercrown", "leafcrown", "beanie", "beret", "straw", "tuft"]
FACE_KW = [
 ("eyepatch", "pirate|patch|one-eyed|scar|veteran|salt|sailor"),
 ("mask", "mask|bandit|raccoon|thief|ninja|rogue|sneak|shadow|stealth|prowl"),
 ("monocle", "monocle|noble|clock|curious|inspect|appraise|judge|detective|snoop"),
 ("glasses", "scholar|sage|wise|read|book|map|lore|study|owl|spectacle|squint|glass|scribe|teach|ponder|think|note|count"),
]
NECK_KW = [
 ("scarf", "scarf|winter|wind|cold|wool|knit|yarn|cloth|weav|thread|shawl|snow|frost|breeze|chill|mist"),
 ("bowtie", "gentle|merchant|dapper|host|butler|tea|banker|mayor|polite|proper|fancy|wedding|party"),
 ("bell", "bell|chime|ring|cow|goat|jingle|tinkle|clang|gong|toll"),
 ("beads", "shell|pearl|bead|gem|jewel|crystal|amber|necklace|treasure|coin|gold|pebble|charm"),
]
BACK_KW = [
 ("shovel", "dig|garden|mole|soil|spade|dirt|dug|burrow|bury|plant|plough|plow|hoe"),
 ("rod", "fish|angler|ferry|river|reel|catch|cast|net|koi|pond|lake|bait"),
 ("umbrella", "rain|umbrella|drizzle|monsoon|puddle|shower|storm|drip|mist|cloud"),
 ("flag", "flag|banner|pennant|kite|pilgrim|prayer|festival|parade|march|signal"),
 ("lantern", "lantern|lamp|night|glow|candle|dusk|torch|light|firefly|moon|star"),
 ("sword", "blade|thorn|dart|knife|spike|sword|needle|prick|sting|dagger|spear|sharp|guard|knight"),
 ("broom", "sweep|broom|witch|tidy|dust|clean|brush|tidy|mop|chimney"),
 ("staff", "wander|walk|trail|hike|path|road|pilgrim|journey|wayfind|travel|compass|guide|roam|trek|stroll|crook|shepherd"),
]
HATS = [k for k, _ in HAT_KW] + ["beret", "beanie"]
FACES = ["glasses", "monocle", "eyepatch", "mask"]
NECKS = ["scarf", "bowtie", "bell", "beads"]
BACKS = ["staff", "shovel", "rod", "flag", "umbrella", "lantern", "sword", "broom"]

def kw_pick(table, name, blurb):
    for text in (name.lower(), blurb.lower()):
        for acc, pat in table:
            if re.search(r"(?<![a-z])(" + pat + r")(?![a-z])", text):
                return acc
    return None

EYES = {"rootwarden": ["dot", "closed", "dot"], "thornblade": ["sharp", "sharp", "wide"], "bloomcaller": ["happy", "round", "happy"],
        "seedkeeper": ["round", "dot", "round"], "wayfinder": ["wide", "round", "wide"], "brewroot": ["closed", "dot", "wink"]}
MOUTH = {"rootwarden": ["flat", "smile"], "thornblade": ["grin", "flat", "smile"], "bloomcaller": ["smile", "tongue", "cat"],
         "seedkeeper": ["smile", "o", "cat"], "wayfinder": ["o", "smile", "open"], "brewroot": ["grin", "tongue", "smile"]}
QUIRKS = ["pollen", "note", "heart", "butterfly", "drop", "star", "leaf", "bubbles"]
PATTERNS = ["plain", "speckle", "belly", "stripes", "spots", "weave", "plain", "belly"]

def load_rows():
    rows = []
    for l in open(DATA, encoding="utf-8"):
        l = l.rstrip("\n")
        if not l.strip() or l.startswith("#"):
            continue
        f = l.split("|")
        if len(f) != 14 or f[0] == "pic_slug":
            continue
        if f[10].startswith("whimsy"):
            continue
        rows.append(dict(slug=f[0], key=f[1], name=f[2], rarity=f[3], calling=f[4], knob=f[11], blurb=f[13]))
    return rows

def build(r):
    k = r["key"]
    ramp, sec, mh, ms, ml = sticker_ramps(k)
    h = lambda s, n: H(k, s) % n
    # accent: hue distance >= 50deg from body hue unless body is grey
    names = list(ACC_HUES)
    cand = [n for n in names if ms < .18 or abs(((ACC_HUES[n][0] / 360 - mh + .5) % 1) - .5) > 50 / 360]
    acc = acc_ramp(cand[h("acc", len(cand))])
    hat = kw_pick(HAT_KW, r["name"], r["blurb"]) or HAT_DEFAULT[h("hat", len(HAT_DEFAULT))]
    face = kw_pick(FACE_KW, r["name"], r["blurb"]) or ""
    neck = kw_pick(NECK_KW, r["name"], r["blurb"]) or ""
    back = kw_pick(BACK_KW, r["name"], r["blurb"]) or ""
    # variety: hash adds optional extras when no keyword matched (about 45 / 40 / 25 / 25 %)
    if not face and h("f?", 100) < 25: face = FACES[h("f", 4)]
    if not neck and h("n?", 100) < 40: neck = NECKS[h("n", 4)]
    if not back and h("b?", 100) < 25: back = BACKS[h("b", 8)]
    if face and not neck and h("fn", 100) < 30: neck = NECKS[h("n2", 4)]
    side = 1 if h("side", 2) else -1
    eyes = EYES[r["calling"]][h("eyes", 3)]
    if face == "mask": eyes = "wide"
    if face == "eyepatch": eyes = "round"
    return dict(key=k, rarity=r["rarity"], ramp=ramp, r2=sec, acc=acc, hat=hat, face=face, neck=neck, back=back,
                eyes=eyes, mouth=MOUTH[r["calling"]][h("mouth", len(MOUTH[r["calling"]]))],
                blush=1 if (r["calling"] == "bloomcaller" or h("blush", 100) < 25) else 0,
                brow=1 if (eyes == "sharp") else 0,
                knob=r["knob"], side=side, kdy=h("kdy", 5) - 2,
                quirk=QUIRKS[h("quirk", 8)], pattern=PATTERNS[h("pat", len(PATTERNS))],
                lean=1 if h("lean", 2) else -1, ldiv=10 + h("ldiv", 5),
                rx=13 + h("rx", 3), ry=11.5 + h("ry", 4) * 0.5, pw=3 + h("pw", 2),
                foot=h("foot", 6), lift=h("lift", 4), sp=h("sp", 4), q2=h("q2", 4)), (mh, ms, ml)

def lua_val(v):
    if isinstance(v, str): return '"%s"' % v
    if isinstance(v, (list, tuple)): return "{" + ",".join(lua_val(x) for x in v) + "}"
    if isinstance(v, float): return repr(round(v, 3))
    return str(v)

def main():
    rows = load_rows()
    pals = []
    for r in rows:
        try:
            p, _ = build(r)
        except Exception as e:
            print("SKIP", r["key"], e, file=sys.stderr); continue
        pals.append(p)
    with open(OUT, "w") as f:
        f.write("return {\n")
        for p in pals:
            f.write(" {" + ",".join("%s=%s" % (a, lua_val(b)) for a, b in p.items()) + "},\n")
        f.write("}\n")
    print("pals", len(pals), "->", OUT)

if __name__ == "__main__":
    main()
