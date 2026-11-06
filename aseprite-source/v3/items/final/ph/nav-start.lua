-- nav-start (final, Opus single pass). A first sprout in a little soil mound: a slim, gently curved stem (tube
-- light), two folded cotyledon leaves with midribs and side veins and a dark base where they join the stem, a closed
-- golden bud cupped by two green sepals (sphere light, glint), and a crumbly soil mound (pillow light, crumbs, two
-- pebbles, a dark hole where the stem goes in) with a 2-tone ground shadow.
-- quirk: a pink earthworm peeks out of the soil on the right to see what is growing.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("nav-start")
local SOIL = { "#2e1a1e", "#4a2a26", "#6b3e2e", "#8c573a", "#ab7449", "#c9955e" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#1f4a3a", "#2e6a44", "#3f8a4c", "#5ba552", "#86c463", "#b4dc80" }
local BUD  = { "#8f4a1f", "#c4741f", "#e39a2a", "#f5bc3a", "#ffdc70", "#fff2b4" }
local STONE = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local WORM = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }

c:groundShadow(32, 54, 19, 2)

-- stem
local sp = { { 32, 47 }, { 33, 38 }, { 30, 28 }, { 31, 18 } }
local stm, stn = A.tube(sp, function(t) return 1.4 - t * 0.35 end)
local sti = A.shade(c, stm, stn, STEM, { wrap = 0.3 })

-- cotyledons (folded blades)
local function leaf(ax, ay, cx, cy, bx, by, wmax, fold)
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t < 0.06 then return 0.6 end
    return wmax * math.sin(math.pi * (t ^ 0.8)) ^ 0.75
  end, { fold = fold })
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.12 then bias[k] = -1 end end)   -- dark base at the stem
  local idx = A.shade(c, m, n, LEAF, { bias = bias, wrap = 0.3 })
  A.adjust(c, m, idx, LEAF, function(x, y, i)
    local k = K(x, y)
    local t, s = T[k], S[k]
    if t > 0.08 and t < 0.92 and abs(s) < 0.14 then return (s < 0) and 1 or -1 end          -- midrib: lit / dark sides
    local u = t * len - abs(s) * wmax * 1.3
    if t > 0.15 and t < 0.85 and abs(s) > 0.25 and abs(s) < 0.8 and floor(u) % 4 == 0 then return -1 end   -- veins
  end)
  return m, idx
end
local lm1, li1 = leaf(31, 31, 22, 22, 12, 26, 4.2, 0.5)
local lm2, li2 = leaf(32, 29, 42, 19, 52, 22, 4.4, 0.5)
-- leaf joins: stem node dark ring
c:put(31, 30, STEM[1]) c:put(32, 30, STEM[2]) c:put(31, 29, STEM[2])

-- bud with sepals
local bm, bn = A.oval(31.5, 14.5, 3.4, 4.3, 0.15, 1)
local bi = A.shade(c, bm, bn, BUD, { wrap = 0.2 })
-- petal seams: two lines converging at the tip
A.adjust(c, bm, bi, BUD, function(x, y, i)
  if y >= 12 and (x == 31 and y >= 13) then return -2 end
  if y >= 15 and x == 33 then return -1 end
end)
c:put(30, 12, BUD[6]) c:put(30, 11, "#fffbe6")
local sep = c:poly{ { 27, 17 }, { 30, 19 }, { 33, 19 }, { 36, 16 }, { 34, 20 }, { 32, 21 }, { 29, 20 } }
local sepn = X.pillow(sep, 1.2, 1)
A.shade(c, sep, sepn, STEM, { wrap = 0.3 })
c:put(29, 18, STEM[6])

-- soil mound
local mm = c:ellipse(32, 51, 18, 9)
mm:cut(c:rect(0, 54, 63, 63))
mm:add(c:ellipse(32, 52, 18, 2))
local mn = X.pillow(mm, 5, 0.8)
local mbias = {}
mm:each(function(x, y) if abs(x - 32) <= 2 and y <= 46 then mbias[K(x, y)] = -1 end end)
local mi = A.shade(c, mm, mn, SOIL, { bias = mbias, wrap = 0.3, amb = 0.1 })
-- crumbs: lit top + dark under
A.adjust(c, mm, mi, SOIL, function(x, y, i)
  local h = X.hash(x, y, 11)
  if h > 0.86 and i < 6 then return 1 end
  if h < 0.12 and i > 1 then return -1 end
end)
-- hole where the stem enters
c:put(31, 44, SOIL[1]) c:put(32, 44, SOIL[1]) c:put(33, 44, SOIL[1]) c:put(30, 43, SOIL[2]) c:put(34, 43, SOIL[2])
-- stem re-enters over the hole (stem base in front)
c:put(31, 43, STEM[3]) c:put(32, 43, STEM[2]) c:put(31, 42, STEM[4]) c:put(32, 42, STEM[3])
-- pebbles
local function pebble(x, y)
  c:put(x, y, STONE[3]) c:put(x + 1, y, STONE[2]) c:put(x, y + 1, STONE[2]) c:put(x + 1, y + 1, STONE[1])
  c:put(x, y - 1, STONE[4]) c:put(x + 2, y + 1, SOIL[1])
end
pebble(21, 48) pebble(38, 51)

-- quirk: worm peeking out on the right
local wp = { { 45, 49 }, { 46, 44 }, { 49, 42 }, { 50, 44 } }
local wm, wn, WT = A.tube(wp, function(t) return 1.3 end)
local wi = A.shade(c, wm, wn, { WORM[1], WORM[2], WORM[2], WORM[3], WORM[3], WORM[4] }, { wrap = 0.3 })
A.adjust(c, wm, wi, { WORM[1], WORM[2], WORM[2], WORM[3], WORM[3], WORM[4] }, function(x, y)
  if floor(WT[K(x, y)] * 9) % 2 == 0 and WT[K(x, y)] < 0.75 then return -1 end   -- segment rings
end)
c:eyeSmall(50, 42)
-- burrow hole dark where the worm leaves the soil
c:put(44, 49, SOIL[1]) c:put(46, 49, SOIL[1]) c:put(47, 48, SOIL[2])

A.save(c, "nav-start")
