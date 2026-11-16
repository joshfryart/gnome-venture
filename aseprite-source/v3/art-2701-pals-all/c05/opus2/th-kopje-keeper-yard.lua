-- Kopje Keeper (th-kopje-keeper), yard sprite 64x64. Opus second pass (art-2701-pals-all/c05/opus2) over the Haiku pass.
-- Thornblade, uncommon, Thornacre. "Keeps a stony watch over the savanna and never once blinks."
-- A kopje come to life: a wide warm savanna-granite boulder (pink-ochre, onion-skin exfoliation lines, grain
-- flecks, orange lichen) with a smaller boulder balanced on top like a hat and a pebble wedged at its foot,
-- dry golden grass tufts and a thorn sprig at the base. Wide-open locked eyes under a heavy ledge, flat
-- watchful mouth: it does not blink.
-- Fixes vs Haiku: no longer one cool-grey blob with 10 colours. Stacked boulders give the kopje silhouette,
-- warm 6-tone granite with rim light and bounce, exfoliation curves and lichen give texture.
-- quirk: a blue-and-orange agama lizard sunning itself on the top boulder.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("th-kopje-keeper-yard", 64)

local GRAN  = { "#3b2a2e", "#5e4344", "#86625a", "#a98472", "#c9a68c", "#e4c8a8" }
local GRASS = { "#6a4a1e", "#a07a2e", "#d0aa4a", "#ecd27a" }
local LIZ   = { "#1d2f5e", "#2f55a0", "#4f86d0", "#86b8ec" }
local LHD   = { "#8a3a1a", "#d8682a", "#f4a050" }
local LICH  = { "#b8682a", "#e0913a", "#f4bc6a" }
local THORN = { "#4d3326", "#7a5236", "#efe4c8" }
local BNC   = "#6a6688"

c:groundShadow(32, 57, 21, 2.5)

-- pebble wedged at the foot (right)
local peb = c:ellipse(48.5, 52.5, 5, 3.5)
O.shade(c, peb, GRAN, { R = 2, amb = .25, wrap = .35, sep = GRAN[1], rim = true, bounce = BNC, bmax = 2 })

-- main boulder
local big = c:ellipse(31, 42, 17, 12.5)
big:cut(c:rect(0, 55, 63, 63))
local bb = {}
big:each(function(x, y) if y >= 53 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, big, GRAN, { R = 7, bias = bb, amb = .2, wrap = .35, sep = GRAN[1], rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, GRAN, function(x, y, i)
  local face = x > 20 and x < 43 and y > 33 and y < 49
  local h = H(x, y, 11)
  if h > (face and .985 or .93) and i >= 2 and i <= 5 then return 1 end
  if h < (face and .01 or .05) and i >= 3 then return -1 end
end)
-- onion-skin exfoliation: curved lines following the boulder, lit lip above each
local function arc(cx, cy, rx, ry, a0, a1, hex, lit)
  local pts, lip = {}, {}
  for a = a0, a1, 2 do
    local r = math.rad(a)
    local x, y = math.floor(cx + math.cos(r) * rx + .5), math.floor(cy + math.sin(r) * ry + .5)
    pts[#pts+1] = { x, y } lip[#lip+1] = { x, y - 1 }
  end
  if lit then O.mark(c, lip, lit) end
  O.mark(c, pts, hex)
end
arc(31, 44, 14, 9.5, 20, 70, GRAN[2], GRAN[4])
arc(31, 44, 14, 9.5, 115, 160, GRAN[2], GRAN[5])
arc(31, 40, 16, 12, 195, 220, GRAN[3])
-- lichen blotches
for _, l in ipairs({ { 18, 47 }, { 43, 36 }, { 26, 51 } }) do
  local x, y = l[1], l[2]
  O.mark(c, { { x, y }, { x + 1, y }, { x, y + 1 }, { x - 1, y + 1 } }, LICH[2])
  O.mark(c, { { x, y } }, LICH[3]) O.mark(c, { { x - 1, y + 1 } }, LICH[1])
end

-- top boulder balanced on its crown, tilted left
local top = c:ellipse(28, 24, 10.5, 7)
top:add(c:ellipse(33, 26, 6, 5))
local tb = {}
top:each(function(x, y) if y >= 29 then tb[K(x, y)] = -1 end end)
local tI, tT = O.shade(c, top, GRAN, { R = 4, bias = tb, amb = .22, wrap = .35, sep = GRAN[1], rim = true, bounce = BNC, bmax = 2 })
O.tex(c, tI, tT, GRAN, function(x, y, i)
  local h = H(x, y, 12)
  if h > .93 and i >= 2 and i <= 5 then return 1 end
  if h < .05 and i >= 3 then return -1 end
end)
arc(28, 25, 8, 5, 200, 250, GRAN[3], GRAN[6])
O.mark(c, { { 38, 25 }, { 38, 26 } }, LICH[2])

-- face: heavy ledge, wide-open unblinking eyes, flat mouth
for _, ex in ipairs({ 23, 35 }) do
  O.mark(c, { { ex - 1, 36 }, { ex, 35 }, { ex + 1, 35 }, { ex + 2, 35 }, { ex + 3, 35 }, { ex + 4, 35 }, { ex + 5, 36 } }, GRAN[6])
  O.mark(c, { { ex, 36 }, { ex + 1, 36 }, { ex + 2, 36 }, { ex + 3, 36 }, { ex + 4, 36 } }, GRAN[2])
  c:eyeLocked(ex, 37)
end
O.mark(c, { { 31, 41 }, { 31, 42 }, { 32, 43 } }, GRAN[3]) O.mark(c, { { 30, 42 } }, GRAN[5]) -- nose ridge
c:cheek(20, 43) c:cheek(41, 43)
O.dots(c, { { 28, 46 }, { 29, 46 }, { 30, 46 }, { 31, 46 }, { 32, 46 }, { 33, 46 }, { 34, 46 }, { 35, 46 } }, P.ink)
O.mark(c, { { 29, 47 }, { 30, 47 }, { 31, 47 }, { 32, 47 }, { 33, 47 }, { 34, 47 } }, GRAN[5])

-- dry grass tufts at the base and a thorn sprig
for _, t in ipairs({ { 12, 55, { -2, 0, 2 } }, { 55, 55, { -1, 1 } } }) do
  for k, dx in ipairs(t[3]) do
    local hgt = 3 + (k % 2) * 3
    local pts = {}
    for j = 0, hgt do pts[#pts+1] = { t[1] + math.floor(dx * j / hgt + .5), t[2] - j } end
    O.dots(c, pts, GRASS[2 + (k % 2)])
    O.dot(c, pts[#pts][1], pts[#pts][2], GRASS[4])
  end
end
local th = c:line({ { 15, 55 }, { 16, 51 }, { 18, 48 } }, 1)
O.flat(c, th, THORN[2], "thorn")
O.dots(c, { { 14, 51 }, { 19, 50 }, { 17, 47 } }, THORN[3])

-- quirk: agama lizard sunning on the top boulder (orange head, blue body, tail curling down the right side)
local lb, ln = O.tube({ { 22, 16.5 }, { 26, 15.5 }, { 30, 15.5 }, { 33, 16.5 } }, function(t) return 1.8 - t * .3 end)
O.shadeN(c, lb, ln, LIZ, { amb = .3, cuts = { .3, .55, .8 }, sep = GRAN[1] })
local tl, tn = O.tube({ { 33, 16.5 }, { 37, 17 }, { 40, 18 }, { 40, 23 } }, function(t) return .9 - t * .5 end)
O.shadeN(c, tl, tn, LIZ, { amb = .3, cuts = { .3, .55, .8 } })
local hd = c:ellipse(19, 15.5, 3, 2)
O.shade(c, hd, LHD, { R = 1, amb = .4, cuts = { .35, .7 }, sep = LIZ[1] })
O.dot(c, 18, 15, P.ink) O.dot(c, 17, 14, LHD[3]) O.dot(c, 16, 16, LHD[1])
O.dots(c, { { 24, 19 }, { 30, 19 }, { 23, 13 }, { 29, 13 } }, LIZ[2])
O.mark(c, { { 25, 15 }, { 27, 15 }, { 29, 15 } }, LIZ[4]) -- back spots -- splayed feet

O.shift(c, 0, -2)
O.done(c, "th-kopje-keeper-yard")
