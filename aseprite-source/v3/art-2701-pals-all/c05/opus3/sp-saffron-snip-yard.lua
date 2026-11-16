-- Saffron Snip (sp-saffron-snip), yard sprite 64x64. Opus richness pass (c05/opus3), built on c05/opus2.
-- Richness pass / fix (opus2 cap could read as a purple crown): the crocus is now a real goblet bloom set at a
-- tilt on the head: narrow at the base, rounded overlapping petals with the dark crocus veins, a green
-- receptacle and two slim crocus leaves (pale midstripe) fanning out from under it; the three crimson
-- stigma threads droop over the petal lip with flared tips. Body: hue-shifted gold ramp with pollen freckles;
-- scissors get a bevel line, rivet glint and an engraved loop.
-- closer-look detail: a tiny woven basket at its foot with the threads it has already picked.
-- Seedkeeper, common, Spicepeak. "Snips saffron threads with tiny scissors and hums while picking."
-- A round saffron-gold sprite wearing a lilac crocus bloom as a cap (three cupped petals, veined), with three
-- crimson saffron threads standing up out of the bloom. It holds a pair of tiny scissors (brass finger loops,
-- steel blades, pivot rivet) open round one thread it has just snipped, which drifts off the blade tip. Mouth
-- in a small "o": it is humming.
-- Fixes vs Haiku: the grey X now reads as scissors (loops, pivot, blades), the threads come from a crocus so the
-- saffron read is clear, body has a 6-tone ramp with rim light and a cool bounce, threads have flared tips.
-- quirk: the hum: a little plum music note floating off to the left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("sp-saffron-snip-yard", 64)

local GLD   = { "#5a2a1c", "#93501e", "#cc7a22", "#eca62e", "#f8cc56", "#fce69c" }
local PET   = { "#3a2556", "#5a3a82", "#7f5aae", "#a582d0", "#c8aae6", "#e6d6f6" }
local THR   = { "#5a1218", "#9a1e22", "#d23a2a", "#f06a3a" }
local STEEL = { "#3a3e52", "#6a7088", "#a4aabc", "#dde0e8" }
local BRASS = { "#6a3a12", "#b0701e", "#e6aa3a", "#f8d27a" }
local NOTE  = { "#3a2244", "#6a3e78", "#9a6aac" }
local GRN   = { "#1f3f2e", "#2f6a3a", "#4f9a48", "#8acb6a", "#d0ecb0" }
local WCK   = { "#4a2e1a", "#7a5230", "#a87c48", "#d0a86a" }
local BNC   = "#7a5a8a"

c:groundShadow(31, 58, 14, 2.5)
for _, fx in ipairs({ 25, 37 }) do
  O.shade(c, c:ellipse(fx, 55.5, 3.5, 2), GLD, { R = 1, amb = .25, sep = GLD[1], rim = true })
end

-- body
local body = c:ellipse(31, 42, 13, 12)
local bI, bT = O.shade(c, body, GLD, { sphere = { 27, 37, 15 }, amb = .25, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, GLD, function(x, y, i) -- faint pollen freckles
  if (x > 21 and x < 41 and y > 34 and y < 50) then return nil end
  if H(x, y, 7) > .95 and i >= 2 and i <= 5 then return 1 end
end)
O.shade(c, c:ellipse(17.5, 44, 2.5, 4), GLD, { R = 1, amb = .3, sep = GLD[1], rim = true }) -- left arm

-- rotated ellipse mask
local function rell(cx, cy, rx, ry, deg)
  local m, a = HP.mask(), math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = math.floor(cy - 12), math.floor(cy + 12) do for x = math.floor(cx - 12), math.floor(cx + 12) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
-- crocus leaves: two slim blades with a pale midstripe, fanning from under the bloom
for _, L in ipairs({ { { 30, 30 }, { 25, 27 }, { 21, 25 }, { 18, 21 } }, { { 34, 30 }, { 39, 29 }, { 43, 27 }, { 46, 23 } } }) do
  local m, n = O.tube(L, function(t) return 1.9 - t * 1.3 end)
  O.shadeN(c, m, n, GRN, { amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 }, sep = GRN[1], rim = true })
  for t = .15, .75, .15 do local x, y = O.bez(L, t) O.mark(c, { { math.floor(x + .5), math.floor(y + .5) } }, GRN[5]) end
end
-- green receptacle on the crown of the head
O.shade(c, c:ellipse(32, 29, 3, 2), GRN, { R = 1, amb = .3, cuts = { .25, .45, .65, .85 }, sep = GLD[1] })
-- the goblet: back petals, then the front petal; whole bloom tilted to the right
local PB = { rell(27.5, 20, 4, 8, -14), rell(37, 19.5, 4, 8, 26) }
for i, m in ipairs(PB) do
  m:cut(c:rect(0, 29, 63, 63))
  local bias = {} m:each(function(x, y) bias[K(x, y)] = (i == 2) and -1 or 0 end)
  local pI, pT = O.shade(c, m, PET, { R = 2, bias = bias, amb = .25, wrap = .4, sep = PET[1], rim = true })
end
-- threads: three stigmas rising out of the cup and drooping over the right lip, flared tips
for _, t in ipairs({ { { 32, 16 }, { 33, 8 }, { 39, 6 }, { 42, 11 } }, { { 31, 16 }, { 29, 8 }, { 24, 7 }, { 22, 11 } }, { { 33, 16 }, { 35, 9 }, { 44, 4 }, { 47, 9 } } }) do
  local m, n = O.tube(t, function() return .75 end)
  O.shadeN(c, m, n, THR, { amb = .3, cuts = { .3, .55, .8 }, sep = THR[1] })
  local ex, ey = t[4][1], t[4][2]
  O.flat(c, c:rect(ex - 1, ey, ex + 1, ey + 1), THR[3], "tip") O.dot(c, ex - 1, ey, THR[4]) O.dot(c, ex + 1, ey + 1, THR[2])
end
local front = rell(32, 21.5, 5, 8.5, 6)
front:cut(c:rect(0, 29, 63, 63))
local fI, fT = O.shade(c, front, PET, { R = 3, amb = .25, wrap = .4, sep = PET[1], rim = true, bounce = BNC, bmax = 2 })
-- crocus veins: dark feathered lines up each petal from the base
O.mark(c, { { 32, 27 }, { 32, 25 }, { 32, 23 }, { 33, 21 }, { 31, 24 }, { 33, 26 } }, PET[2])
O.mark(c, { { 26, 24 }, { 27, 22 }, { 38, 23 }, { 39, 21 } }, PET[3])
O.mark(c, { { 30, 15 }, { 31, 14 } }, PET[6]) -- lit rounded tip
-- petal tips of the back petals curl slightly outward: lit rim pixels
O.mark(c, { { 25, 13 }, { 39, 12 } }, PET[6])
for x = 22, 40 do if c:get(x, 31) and not c:get(x, 29) then O.mark(c, { { x, 31 } }, GLD[3]) end end

-- face: humming "o"
c:eyeLocked(24, 34) c:eyeLocked(34, 34)
c:cheek(21, 41) c:cheek(40, 41)
O.dots(c, { { 30, 42 }, { 31, 42 }, { 29, 43 }, { 32, 43 }, { 30, 44 }, { 31, 44 } }, P.ink)
O.dots(c, { { 30, 43 }, { 31, 43 } }, "#a23a3a")

-- scissors in the right hand: blades up-right open round a thread, loops down
for _, bl in ipairs({ { { 49, 37 }, { 51, 34 }, { 54, 30 }, { 57, 26 } }, { { 49, 37 }, { 52, 36 }, { 56, 35 }, { 59, 34 } } }) do
  local m, n = O.tube(bl, function(t) return 1.3 - t * .9 end)
  O.shadeN(c, m, n, STEEL, { amb = .35, wrap = .4, cuts = { .3, .55, .8 }, sep = STEEL[1] })
end
O.dots(c, { { 52, 32 }, { 54, 35 } }, STEEL[4]) -- edge glints
O.mark(c, { { 53, 31 }, { 55, 29 }, { 53, 36 }, { 56, 35 } }, STEEL[2]) -- bevel line
for _, L in ipairs({ { 44.5, 41.5 }, { 49.5, 43.5 } }) do
  local ring = c:ellipse(L[1], L[2], 2.5, 2.5)
  ring:cut(c:ellipse(L[1], L[2], 1, 1))
  O.shade(c, ring, BRASS, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = BRASS[1] })
end
O.flat(c, c:line({ { 46, 39 }, { 48, 37 } }, 1), BRASS[2], "shank") O.flat(c, c:line({ { 49, 40 }, { 49, 38 } }, 1), BRASS[2], "shank")
O.flat(c, c:rect(48, 36, 49, 37), STEEL[1], "rivet") O.dot(c, 48, 36, STEEL[4])
O.mark(c, { { 51, 42 }, { 50, 45 } }, BRASS[4]) -- engraved loop glints
O.shade(c, c:ellipse(43, 44, 2.5, 2.5), GLD, { R = 1, amb = .3, sep = GLD[1] }) -- hand through the loop
-- the snipped thread drifting off the blade tips
O.flat(c, c:line({ { 59, 29 }, { 58, 26 } }, 1), THR[3], "cut") O.dot(c, 58, 26, THR[4]) O.dot(c, 59, 29, THR[2])

-- closer-look detail: tiny woven basket at its left foot holding the threads already picked
local bk = c:rrect(12, 50, 18, 55, 1)
local kI, kT = O.shade(c, bk, WCK, { R = 1, amb = .3, cuts = { .3, .55, .8 }, sep = WCK[1] })
O.tex(c, kI, kT, WCK, function(x, y, i) if x % 3 == 0 and i >= 2 then return -1 elseif y % 2 == 0 and x % 3 == 1 and i <= 3 then return 1 end end)
O.mark(c, { { 12, 50 }, { 13, 50 }, { 14, 50 }, { 15, 50 }, { 16, 50 }, { 17, 50 }, { 18, 50 } }, WCK[4])
O.flat(c, c:line({ { 14, 49 }, { 13, 46 } }, 1), THR[3], "picked") O.flat(c, c:line({ { 16, 49 }, { 17, 46 } }, 1), THR[2], "picked")
O.dot(c, 13, 46, THR[4]) O.dot(c, 17, 46, THR[3])

-- quirk: the hum, a music note floating off to the left
O.flat(c, c:rect(13, 22, 13, 27), NOTE[2], "note")
O.flat(c, c:rect(14, 22, 15, 23), NOTE[2], "note") O.dot(c, 16, 24, NOTE[2])
local head = c:ellipse(11.5, 28, 1.5, 1.2)
O.shade(c, head, NOTE, { R = 1, amb = .4, cuts = { .4, .75 } })

O.done(c, "sp-saffron-snip-yard")
