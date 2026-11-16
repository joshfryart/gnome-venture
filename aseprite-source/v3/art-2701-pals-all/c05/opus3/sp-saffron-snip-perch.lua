-- Saffron Snip (sp-saffron-snip), perch sprite 36x36. Opus richness pass (c05/opus3), hand-built at this size.
-- Fixes vs opus2: the cap is now a tilted goblet crocus (rounded petals, green receptacle, two slim leaves,
-- drooping threads) instead of a three-point crown; the scissors are bigger (6-7 px blades, 2 px brass loops
-- with holes, a lit rivet) so they read at 1x. Hue-shifted gold ramp, petal veins.
-- Bold and few: round saffron-gold body, three-petal lilac crocus cap with three crimson threads, pill eyes,
-- humming "o" mouth; small open scissors (two brass loops, steel blades) in the right hand.
-- quirk: the hum: a plum music note floating at the left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sp-saffron-snip-perch", 36)

local GLD   = { "#5a2a1c", "#93501e", "#cc7a22", "#eca62e", "#f8cc56", "#fce69c" }
local GRN   = { "#1f3f2e", "#2f6a3a", "#4f9a48", "#8acb6a", "#d0ecb0" }
local PET   = { "#3a2556", "#5a3a82", "#7f5aae", "#a582d0", "#c8aae6", "#e6d6f6" }
local THR   = { "#5a1218", "#9a1e22", "#d23a2a", "#f06a3a" }
local STEEL = { "#3a3e52", "#6a7088", "#a4aabc", "#dde0e8" }
local BRASS = { "#6a3a12", "#b0701e", "#e6aa3a", "#f8d27a" }
local NOTE  = { "#3a2244", "#6a3e78", "#9a6aac" }
local BNC   = "#7a5a8a"

c:groundShadow(17, 32, 8, 1.5)
for _, fx in ipairs({ 14, 20 }) do O.shade(c, c:ellipse(fx, 30.5, 2, 1.2), GLD, { R = 1, amb = .3, sep = GLD[1] }) end
local body = c:ellipse(17, 23.5, 7.5, 7)
O.shade(c, body, GLD, { sphere = { 15, 21, 9 }, amb = .3, wrap = .4, rim = true, bounce = BNC, bmax = 2 })

local function rell(cx, cy, rx, ry, deg)
  local m, a = HP.mask(), math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = math.floor(cy - 8), math.floor(cy + 8) do for x = math.floor(cx - 8), math.floor(cx + 8) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
-- leaves
O.flat(c, c:line({ { 15, 16 }, { 12, 15 }, { 9, 12 } }, 1), GRN[3], "leaf") O.dot(c, 9, 12, GRN[4]) O.dot(c, 12, 15, GRN[5])
O.flat(c, c:line({ { 20, 16 }, { 23, 15 }, { 26, 12 } }, 1), GRN[2], "leaf") O.dot(c, 26, 12, GRN[3])
O.flat(c, c:rect(16, 16, 19, 16), GRN[3], "recep") O.dot(c, 16, 16, GRN[4])
-- back petals
for i, m in ipairs({ rell(14.5, 10.5, 2.5, 5, -16), rell(20.5, 10, 2.5, 5, 26) }) do
  m:cut(c:rect(0, 16, 35, 35))
  local bias = {} if i == 2 then m:each(function(x, y) bias[K(x, y)] = -1 end) end
  O.shade(c, m, PET, { R = 1, bias = bias, amb = .3, wrap = .4, sep = PET[1], rim = true })
end
-- threads drooping over the lip
for _, t in ipairs({ { { 18, 7 }, { 19, 3 }, { 23, 3 }, { 24, 6 } }, { { 16, 7 }, { 15, 3 }, { 12, 3 }, { 11, 6 } } }) do
  local m = HP.mask()
  for k = 0, 20 do local x, y = O.bez(t, k / 20) m:set(math.floor(x + .5), math.floor(y + .5)) end
  O.flat(c, m, THR[3], "thread")
  O.flat(c, c:rect(t[4][1], t[4][2], t[4][1], t[4][2] + 1), THR[4], "tip")
end
local front = rell(17.5, 11, 3, 5.5, 6)
front:cut(c:rect(0, 16, 35, 35))
O.shade(c, front, PET, { R = 1, amb = .3, wrap = .4, sep = PET[1], rim = true, bounce = BNC, bmax = 2 })
O.mark(c, { { 17, 14 }, { 17, 12 }, { 18, 10 }, { 14, 12 }, { 21, 11 } }, PET[2]) -- veins
O.mark(c, { { 16, 6 } }, PET[6])
for x = 11, 23 do if c:get(x, 17) and x ~= 16 and x ~= 19 then O.mark(c, { { x, 17 } }, GLD[3]) end end

c:eyeSmall(13, 20) c:eyeSmall(19, 20)
O.dot(c, 11, 24, "#f5809f") O.dot(c, 23, 24, "#f5809f")
O.dots(c, { { 16, 24 }, { 17, 24 }, { 15, 25 }, { 18, 25 }, { 16, 26 }, { 17, 26 } }, P.ink) O.dots(c, { { 16, 25 }, { 17, 25 } }, "#a23a3a")

-- scissors: bigger, open round a thread
O.flat(c, c:line({ { 27, 21 }, { 29, 18 }, { 32, 14 } }, 1), STEEL[3], "blade") O.flat(c, c:line({ { 28, 21 }, { 30, 18 }, { 33, 15 } }, 1), STEEL[2], "blade")
O.dot(c, 32, 14, STEEL[4]) O.dot(c, 30, 17, STEEL[4])
O.flat(c, c:line({ { 28, 22 }, { 34, 21 } }, 1), STEEL[2], "blade2") O.dot(c, 31, 21, STEEL[3])
for _, L in ipairs({ { 25.5, 25.5 }, { 29.5, 26.5 } }) do
  local ring = c:ellipse(L[1], L[2], 2, 2) ring:cut(c:rect(math.floor(L[1]), math.floor(L[2]), math.floor(L[1]), math.floor(L[2])))
  O.shade(c, ring, BRASS, { R = 1, amb = .4, cuts = { .35, .6, .85 }, sep = BRASS[1] })
end
O.flat(c, c:rect(27, 22, 28, 23), STEEL[1], "rivet") O.dot(c, 27, 22, STEEL[4])

-- hum note
O.flat(c, c:rect(5, 10, 5, 14), NOTE[2], "note") O.flat(c, c:rect(6, 10, 7, 10), NOTE[2], "note")
O.flat(c, c:rect(3, 14, 4, 15), NOTE[2], "note") O.dot(c, 3, 14, NOTE[3])

O.shift(c, 0, 0)
O.done(c, "sp-saffron-snip-perch")
