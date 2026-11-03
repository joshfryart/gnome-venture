-- ico-apple (final pass, Opus single pass). Bold icon: an upright apple, a touch taller than wide, two soft
-- shoulders round a sunken stalk cavity, tapering to a narrow base. Per-pixel sphere light (6-tone red, cool
-- violet shade), faint darker meridian streaks running out of the cavity, pale lenticel freckles, waxy bloom on the
-- lit rim, one big specular + cream glint, cool reflected light lower-right, dark AO in the cavity.
-- Stalk: 3 px curved twig, pale end grain. Leaf: 6-tone blade, pale midrib, veins, dark base where it joins.
-- quirk: a little worm pokes its head out of a hole on the right side and smiles.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aA0_3.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs, atan = math.floor, math.max, math.min, math.sqrt, math.abs, math.atan
local c = T.new("ico-apple")
local RED  = { "#5a1830", "#8c2036", "#c22a38", "#e64838", "#ff7048", "#ffa874" }
local LEAF = { "#1c4a3a", "#26623f", "#348046", "#4fa24e", "#7cc35a", "#b4dc78" }
local WOOD = { "#3e2422", "#6a3e2c", "#9a6440", "#c89260" }
local BLOOM, BOUNCE, FRECK = "#f08a7e", "#9c4068", "#ffc488"
local rtok, ltok, wtok = { r = { name = "apple" } }, { r = { name = "leaf" } }, { r = { name = "stalk" } }

-- stalk first (body paints over its foot)
local sm, sn = X.cyl(32, 25, 34, 13, function(t) return 1.15 - t * 0.15 end)
local sidx = T.shade(c, sm, sn, WOOD, { amb = 0.15, wrap = 0.3, tok = wtok })
c:put(33, 12, WOOD[4], wtok) c:put(34, 12, WOOD[4], wtok) c:put(35, 13, WOOD[3], wtok) c:put(34, 13, WOOD[3], wtok)

-- leaf off the stalk, up to the right
local lm, ln, LT, LS = T.blade(34, 18, 41, 9, 51, 12, function(t) return 4.6 * math.sin(math.pi * math.min(1, t * 1.05)) ^ 0.8 - 0.2 end, { fold = 0.5 })
local lbias = {}
lm:each(function(x, y) local k = K(x, y) if LT[k] < 0.12 then lbias[k] = -1 end end)
local lidx = T.shade(c, lm, ln, LEAF, { amb = 0.1, wrap = 0.25, bias = lbias, tok = ltok })
-- midrib + veins
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  if abs(s) < 0.16 and t > 0.08 and t < 0.9 then c:put(x, y, LEAF[min(6, (lidx[k] or 4) + 2)], ltok) end
end)
for _, v in ipairs{ { 0.35, -1 }, { 0.55, -1 }, { 0.42, 1 }, { 0.65, 1 } } do
  lm:each(function(x, y) local k = K(x, y)
    local t, s = LT[k], LS[k]
    if s * v[2] > 0.25 and s * v[2] < 0.8 and abs((t - v[1]) - abs(s) * 0.16) < 0.03 then
      c:put(x, y, LEAF[max(1, (lidx[k] or 4) - 1)], ltok) end end)
end

-- body: two shoulders + tapered base, cavity at top
local m = c:ellipse(25.5, 33, 10.5, 11):add(c:ellipse(38.5, 33, 10.5, 11)):add(c:ellipse(32, 41, 12, 12.5)):add(c:ellipse(29, 46, 8, 7.5)):add(c:ellipse(35, 46, 8, 7.5))
m:cut(c:ellipse(32, 22.5, 3, 2))
m:cut(c:ellipse(32, 54, 1.5, 1))
local CX, CY, R = 33, 36, 19
local ns = X.sphere(CX, CY, R, m)
local np = X.pillow(m, 5)
local n = T.blend(ns, np, 0.3)
-- cavity: normals tip toward the stalk socket
local bias = {}
m:each(function(x, y) local k = K(x, y)
  local dx, dy = x - 32, y - 24
  local d = sqrt(dx * dx + dy * dy * 2)
  if d < 4.5 then bias[k] = -2 elseif d < 6.5 then bias[k] = -1 end
end)
local idx = T.shade(c, m, n, RED, { amb = 0.02, wrap = 0.12, bias = bias, cuts = { 0.14, 0.3, 0.5, 0.7, 0.88 } })
for k, i in pairs(idx) do local x, y = k % 1024 - 256, k // 1024 - 256 c:put(x, y, RED[i], rtok) end
-- meridian streaks from the cavity (one tone darker, broken)
m:each(function(x, y) local k = K(x, y)
  local i = idx[k]
  if i and i >= 3 and i <= 5 then
    local a = atan(x - 32, (y - 22) * 1.2)
    local f = (a * 7) % 1
    if f < 0.1 and X.hash(x, y, 3) > 0.15 and y > 29 and i <= 4 then T.step(c, idx, RED, x, y, -1, rtok) end
  end
end)
-- lenticel freckles on lit mid tones
m:each(function(x, y) local k = K(x, y)
  local i = idx[k]
  if i and i >= 4 and i <= 5 and X.hash(x, y, 11) > 0.978 then c:put(x, y, FRECK, rtok) end
end)
-- waxy bloom along the lit upper-left rim
m:edge():each(function(x, y) local k = K(x, y)
  local nn = n[k]
  if nn[1] < -0.45 and nn[2] < 0.25 and y > 26 then c:put(x, y, BLOOM, rtok) end
end)
-- cool reflected light lower-right
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and y > 36 and x > 30 then c:put(x, y, BOUNCE, rtok) end
end)
-- specular: soft 6-tone patch + cream glint
T.map(c, {
  ".hh.",
  "hssh",
  "hsh.",
  ".h..",
}, 21, 28, { h = RED[6], s = "#ffd4a8" }, rtok)
c:put(22, 29, T.CREAM, rtok)
-- stalk socket: dark cup and stalk foot
T.map(c, {
  ".ddd.",
  "ddDdd",
  ".ddd.",
}, 30, 23, { d = RED[1], D = WOOD[1] }, rtok)
c:put(32, 23, WOOD[2], wtok) c:put(33, 23, WOOD[1], wtok)

-- quirk: worm hole on the right flank + a worm poking out
local hx, hy = 44, 42
T.map(c, {
  ".DDD.",
  "DDDDD",
  "fDDDF",
  ".fFF.",
}, hx - 2, hy - 1, { f = "#ffe0a4", F = "#e8b874", D = "#4a1828" }, rtok)
-- worm body: curls up and out to the right, 4 px thick
local WORM = { "#8c3c5c", "#c45a7a", "#f088a0", "#ffbccc" }
local wm, wn = X.cyl(45, 42, 52, 34, function(t) return 1.7 - t * 0.1 end)
local widx = T.shade(c, wm, wn, WORM, { amb = 0.12, wrap = 0.3, tok = { r = { name = "worm" } } })
-- segment rings
wm:each(function(x, y) if (x + y) % 3 == 0 and widx[K(x, y)] and widx[K(x, y)] > 1 then
  c:put(x, y, WORM[widx[K(x, y)] - 1], { r = { name = "worm" } }) end end)
-- head
local hm = c:ellipse(53, 32, 3, 3)
local hn = X.sphere(53, 32, 3, hm)
T.shade(c, hm, hn, WORM, { amb = 0.15, wrap = 0.3, tok = { r = { name = "wormh" } } })
c:eyeSmall(53, 30)
c:put(55, 34, WORM[1]) c:put(54, 35, WORM[1])
c:put(51, 33, "#ff9cae")
-- hole lip overlaps the worm root
T.save(c, "ico-apple", "ico")
