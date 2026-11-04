-- pohutukawa-seed (final pass, Opus). A ripe woody pohutukawa capsule (bell-shaped cup, ribbed bark grain, short
-- stalk, three valves split and splayed open, dark seed chamber) tipping its fine sliver seeds out onto a torn scrap
-- of pohutukawa leaf (thick elliptic leaf: glossy dark green top with midrib and veins; the torn lower edge curls to
-- show the white-felted underside). A seed on the left has germinated: thin red-brown stem, two tiny round
-- cotyledons and the first opposite pair of small elliptic leaves.
-- History: Sonnet draft (dC35) replaced.
-- quirk: one crimson stamen from last summer's bottle-brush flower lies across the leaf, gold anther and all.
local NAME = "pohutukawa-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#122e2c", "#1a4436", "#265c40", "#367848", "#559852", "#86ba66" }
local FELT  = { "#8e9488", "#b4b8aa", "#d8dacc", "#eeeee0" }
local VEIN, COOL = "#a6cc7c", "#355c66"
local WOOD  = { "#2a1a1c", "#462a26", "#664030", "#88603e", "#a88054", "#caa676" }
local SEED  = { "#5a2a22", "#8a4430", "#b8683e" }
local STEM  = { "#5a2e2a", "#8a4a3a", "#b87458" }
local SPR   = { "#2e5a3a", "#4a7e44", "#6ea250", "#98c260", "#c4dc80", "#e6f0b0" }
local RED   = { "#8a1a2e", "#d0263a", "#ff5a4a" }
local CUTS = A.CUTS

-- leaf scrap: elliptic, lying from lower-right to upper-left, torn at the right end
local lm, ln, LT, LS, len = A.blade(58, 51, 34, 53, 8, 42, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.8 * sin(pi * min(1, t * 0.88 + 0.12)) ^ 0.7)
end, { fold = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.06 + 0.06 * X.hash(floor(LS[k] * 5), 1, 3) then lm.s[k] = nil end end)

-- capsule geometry (right of centre, standing on the leaf, tilted a little)
local ccx, rimY, baseY = 41, 34, 46
local function cupR(y) local f = (baseY - y) / (baseY - rimY) return 1.6 + 4.6 * f ^ 0.75 end
local cup = HP.mask()
for y = rimY, baseY do local r = cupR(y)
  for x = floor(ccx - r), floor(ccx + r - 0.01) do if x + 0.5 >= ccx - r and x + 0.5 <= ccx + r then cup:set(x, y) end end end
local stalk = c:rect(40, 47, 41, 49)
local rimM = c:ellipse(ccx - 0.5, rimY, 6, 1.5)
local cupAll = cup:copy():add(stalk):add(rimM)
-- valves: three pointed flaps splayed out
local function valve(bx, by, tx, ty, w)
  local m, n = X.cyl(bx, by, tx, ty, function(t) return max(0.3, w * (1 - t) ^ 0.8) end)
  return m, n
end
local v1m, v1n = valve(37, 33, 31, 26, 2.4)   -- left
local v2m, v2n = valve(41, 32, 42, 24, 2.2)   -- back middle
local v3m, v3n = valve(45, 33, 51, 27, 2.4)   -- right

-- leaf shading: AO/contact under the capsule and its spilt seeds
local seeds = { { 30, 45, 1 }, { 27, 47, 0 }, { 33, 49, 1 }, { 24, 44, 0 }, { 35, 46, 0 }, { 29, 50, 1 } }
local seedM = HP.mask()
for _, s in ipairs(seeds) do seedM:set(s[1], s[2]) if s[3] == 1 then seedM:set(s[1] + 1, s[2]) else seedM:set(s[1], s[2] + 1) end end
local bias = {}
X.ao(bias, lm, cupAll, 1, -1) A.cast(bias, lm, cupAll, 2, 2, -1)
A.cast(bias, lm, seedM, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.8 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.07 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len + abs(s) * 4.5) / 4.6
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.9 and abs(s) > 0.18 and abs(s) < 0.66 and t > 0.12 and t < 0.86 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
-- glossy top: one bright specular dash along the lit half
for _, p in ipairs{ { 20, 42 }, { 21, 42 }, { 22, 43 } } do if lm:has(p[1], p[2]) and not bias[K(p[1], p[2])] then c:put(p[1], p[2], LEAF[6], ltok) end end
-- curled torn lower edge: felted white underside showing (speckled felt)
local ftok = { r = { name = "felt" } }
lm:each(function(x, y) local k = K(x, y)
  if LS[k] > 0.7 and LT[k] > 0.08 and LT[k] < 0.62 then
    local h = X.hash(x, y, 5)
    local i = (LS[k] > 0.86) and 2 or 3
    if h > 0.75 then i = i + 1 elseif h < 0.2 then i = i - 1 end
    c:put(x, y, FELT[max(1, min(4, i))], ftok)
  end
  if LS[k] > 0.56 and LS[k] <= 0.7 and LT[k] > 0.1 and LT[k] < 0.6 then c:put(x, y, LEAF[1], ltok) end   -- curl crease shadow
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] > 0.4 and LT[k] >= 0.62 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- seedling (left), growing from a seed on the leaf
local stok = { r = { name = "stem" } }
local sp = { { 18, 45 }, { 17, 39 }, { 19, 33 }, { 18, 26 } }
local sm, sn = A.tube(sp, function(t) return 0.95 end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.35, 0.7 }, tok = stok })
local ptok = { r = { name = "sprout" } }
local function lf(cx2, cy2, rx, ry, ang)
  local m, n = A.oval(cx2, cy2, rx, ry, ang, 0.7)
  m:cut(sm)
  local idx = A.shade(c, m, n, SPR, { tok = ptok, amb = 0.12, wrap = 0.3 })
  return m, idx
end
-- cotyledons (tiny, round)
lf(15, 34, 1.8, 1.4, 0) lf(22, 33, 1.8, 1.4, 0)
-- first opposite pair of elliptic leaves, angled up
local la = lf(12, 24, 4.3, 1.9, 0.42)
local lb = lf(24, 23, 4.3, 1.9, -0.42)
-- midribs
for _, p in ipairs{ { 10, 23 }, { 11, 23 }, { 12, 24 }, { 13, 24 }, { 15, 25 }, { 21, 24 }, { 23, 23 }, { 24, 23 }, { 25, 22 }, { 26, 22 } } do
  c:put(p[1], p[2], p[1] < 18 and SPR[6] or SPR[3], ptok) end
-- bud between them
c:put(18, 24, SPR[5], ptok) c:put(18, 23, SPR[4], ptok) c:put(18, 25, STEM[3], stok)
-- seed coat at the base
c:put(17, 45, SEED[2], ptok) c:put(18, 46, SEED[1], ptok) c:put(19, 46, SEED[3], ptok)

-- capsule: lathe-lit woody cup with vertical ribs, dark open chamber
local wtok = { r = { name = "capsule" } }
local cn = A.lathe(cup, ccx, cupR, 2, 0.4)
local cidx = A.shade(c, cup, cn, WOOD, { tok = wtok, amb = 0.06, wrap = 0.22 })
cup:each(function(x, y) local u = (x + 0.5 - ccx) / cupR(y)
  if floor((u + 1) * 3.2 + 0.5) % 2 == 0 and abs(u) < 0.85 and y > rimY + 1 then A.step(c, cidx, WOOD, x, y, -1, wtok) end end)
-- girdle ring scar across the cup
for x = 35, 47 do if cup:has(x, 38) then A.step(c, cidx, WOOD, x, 38, 1, wtok) end if cup:has(x, 39) then A.step(c, cidx, WOOD, x, 39, -1, wtok) end end
-- stalk
for y = 47, 49 do c:put(40, y, WOOD[3], wtok) c:put(41, y, WOOD[2], wtok) end
-- valves (back first)
local v2idx = A.shade(c, v2m, v2n, WOOD, { tok = wtok, amb = 0.04, wrap = 0.2, bias = (function() local b = {} v2m:each(function(x, y) b[K(x, y)] = -1 end) return b end)() })
local v1idx = A.shade(c, v1m, v1n, WOOD, { tok = wtok, amb = 0.08, wrap = 0.25 })
local v3idx = A.shade(c, v3m, v3n, WOOD, { tok = wtok, amb = 0.08, wrap = 0.25 })
-- inner faces of the splayed valves: pale split wood strip along the inner edge
for _, p in ipairs{ { 36, 31 }, { 35, 30 }, { 34, 29 }, { 46, 31 }, { 47, 30 }, { 48, 29 } } do c:put(p[1], p[2], WOOD[6], wtok) end
-- rim and open chamber
rimM:each(function(x, y) c:put(x, y, WOOD[4], wtok) end)
local hole = c:ellipse(ccx - 0.5, rimY, 4, 0.6)
hole:each(function(x, y) c:put(x, y, WOOD[1], wtok) end)
c:put(39, rimY, SEED[2], wtok) c:put(42, rimY, SEED[3], wtok)
-- glint on the left valve
c:put(32, 27, "#fff0cc", wtok)

-- spilt seeds: fine slivers, each with a lit end
local sdtok = { r = { name = "seeds" } }
for _, s in ipairs(seeds) do
  c:put(s[1], s[2], SEED[3], sdtok)
  if s[3] == 1 then c:put(s[1] + 1, s[2], SEED[1], sdtok) else c:put(s[1], s[2] + 1, SEED[1], sdtok) end
end
-- a few still sliding off the left valve lip
c:put(33, 33, SEED[2], sdtok) c:put(32, 35, SEED[3], sdtok) c:put(32, 36, SEED[1], sdtok)

-- quirk: a crimson stamen lying across the leaf, gold anther at the tip
local rtok = { r = { name = "stamen" } }
local st = { { 44, 52, 1 }, { 45, 52, 2 }, { 46, 51, 2 }, { 47, 51, 2 }, { 48, 50, 3 }, { 49, 50, 2 }, { 50, 49, 2 }, { 51, 49, 2 }, { 52, 48, 3 } }
for _, p in ipairs(st) do c:put(p[1], p[2], RED[p[3]], rtok) end
c:put(53, 47, "#f5b82e", rtok) c:put(53, 48, "#d98322", rtok) c:put(54, 47, "#ffe38a", rtok)

A.save(c, "ph", NAME)
