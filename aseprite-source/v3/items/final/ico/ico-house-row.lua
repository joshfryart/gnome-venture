-- ico-house-row (final, Opus). Three joined, gable-front terrace houses, staggered heights, tall slim middle one.
-- Left: red tile roof over a plank wall (plank seams, nail dots, paler board ends). Middle: violet slate roof over
-- cream plaster with dark half-timber posts and a brace, brick chimney with a cap. Right: teal tile roof over brick
-- (running bond, mortar lines). Roofs: lit left slope, shaded right slope, tile rows with staggered breaks, fascia
-- rim. Windows: cream frames, cross muntins, sea-glass panes with a glint and sill shadow. Doors: plank doors with a
-- gold knob and a step. AO under every eave, cast shadow where a lower roof meets the taller wall, ground shadow.
-- quirk: a ginger cat sits on the ridge of the right-hand roof, tail curled down the slope.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-house-row")
local RED  = { "#5e1a30", "#8e243a", "#b8323d", "#da4a3c", "#f07150", "#ff9c70" }
local DSK  = { "#2c2050", "#43337a", "#5f48a6", "#7a62c6", "#9c86e0", "#c4b2f4" }
local TEAL = { "#1c3e4a", "#245a60", "#2f7d78", "#43a08e", "#6cc2a4", "#a8e2c4" }
local PLK  = { "#51302b", "#7a4a30", "#a2683e", "#c48a52", "#dfad70", "#f2cd94" }
local PLS  = { "#7e6058", "#ae8c78", "#d2b294", "#e8d0ae", "#f6e6c6", "#fff4dc" }
local BRK  = { "#4e2428", "#76342e", "#9c4836", "#bc6246", "#d8845e", "#eeaa82" }
local TIM  = { "#3a2220", "#5a3428", "#7a4a32", "#9a6440" }
local GL   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local WF   = { "#a89078", "#d8c4a4", "#f2e4c6" }
local CAT  = { "#7a3a1c", "#b85e24", "#e88a30", "#fbb454", "#ffd88a" }

c:groundShadow(32, 56, 26, 1)

-- wall fill with flat-front light: base tone, lighter upper-left, darker right edge column, AO under the eave
local function wall(x0, x1, y0, y1, ramp, tok)
  local idx = {}
  for y = y0, y1 do for x = x0, x1 do
    local i = 4
    if x >= x1 - 1 then i = 3 end
    if y - y0 < 2 then i = i - 1 end
    if y - y0 < 1 then i = i - 1 end
    if x == x0 and y - y0 > 2 then i = 5 end
    idx[K(x, y)] = i c:put(x, y, ramp[i], tok)
  end end
  return idx
end
-- gable roof: triangle with eave overhang; tile rows every 3 px; left slope lit, right slope shaded
local function roof(x0, x1, peakY, eaveY, ramp, tok, slate)
  local px = (x0 + x1) / 2
  local m = HP.poly{ { px - 0.5, peakY - 0.5 }, { px + 0.5, peakY - 0.5 }, { x1 + 0.5, eaveY + 0.5 }, { x0 - 0.5, eaveY + 0.5 } }
  local idx = {}
  m:each(function(x, y)
    local i = (x < px) and 5 or 3
    if x < px and x > px - 3 and y < peakY + 6 then i = 6 end
    local r = (eaveY - y) % 3
    if r == 0 then i = i - 2 end
    -- staggered tile breaks
    local off = ((eaveY - y) // 3) % 2 == 0 and 0 or 2
    if r ~= 0 and (x + off) % 4 == 0 then i = i - 1 end
    if slate and r == 1 then i = i + 1 end
    i = max(1, min(6, i))
    idx[K(x, y)] = i c:put(x, y, ramp[i], tok)
  end)
  -- fascia: eave row is a darker board, lit underside lip
  for x = x0, x1 do if m:has(x, eaveY) then c:put(x, eaveY, ramp[x < px and 3 or 2], tok) end end
  return m, idx
end
local function window(x, y, tok)
  -- 5x6 frame + 3x4 panes split by a cross, sill below
  A.map(c, {
    "bbbbb",
    "bgfhb",
    "bfffb",
    "bcbcb",
    "bfefb",
    "accca",
  }, x, y, { a = WF[1], b = WF[2], c = WF[3], f = GL[2], g = GL[4], h = GL[3], e = GL[1] }, tok)
end
local function door(x, y, tok)
  A.map(c, {
    ".abba.",
    "abcbca",
    "abcbca",
    "abcbca",
    "abcbka",
    "abcbca",
    "abcbca",
    "ssssss",
  }, x, y, { a = TIM[1], b = TIM[3], c = TIM[4], k = "#f5b82e", s = "#aaa9b8" }, tok)
end

-- LEFT house: plank wall
local t1, r1 = A.tok("left"), A.tok("roofL")
local w1 = wall(10, 23, 36, 54, PLK, t1)
for y = 36, 54 do for x = 10, 23 do
  if (y - 36) % 3 == 2 then A.step(c, w1, PLK, x, y, -1, t1) end
  if (y - 36) % 3 == 0 and (x == 13 or x == 20) then A.step(c, w1, PLK, x, y, 1, t1) end
end end
window(12, 40, t1) door(16, 47, t1)
local rm1 = roof(8, 25, 23, 35, RED, r1)

-- RIGHT house: brick wall (running bond)
local t3, r3 = A.tok("right"), A.tok("roofR")
local w3 = wall(40, 53, 33, 54, BRK, t3)
for y = 33, 54 do for x = 40, 53 do
  local row = (y - 33) // 3
  if (y - 33) % 3 == 2 then A.step(c, w3, BRK, x, y, 2, t3)
  elseif (x + (row % 2) * 2) % 4 == 0 then A.step(c, w3, BRK, x, y, 1, t3) end
end end
window(42, 37, t3) window(48, 37, t3) door(45, 47, t3)
local rm3 = roof(38, 55, 20, 32, TEAL, r3)

-- MIDDLE house: plaster + half-timber, tallest, drawn last so it overlaps the side roofs
local t2, r2 = A.tok("mid"), A.tok("roofM")
-- chimney first (behind the roof's right slope)
local ch = HP.rect(34, 10, 37, 20)
ch:each(function(x, y) local i = (x == 34) and 5 or (x == 37 and 3 or 4)
  if (y - 10) % 3 == 2 then i = i - 1 elseif (x + ((y - 10) // 3 % 2) * 2) % 4 == 0 then i = i + 1 end
  c:put(x, y, BRK[min(6, i)], t2) end)
for x = 33, 38 do c:put(x, 9, x == 33 and "#aaa9b8" or "#74758c", t2) c:put(x, 8, x < 36 and "#e2e0e6" or "#aaa9b8", t2) end
local w2 = wall(24, 39, 27, 54, PLS, t2)
-- half-timber: corner posts, a beam under the windows, one brace
for y = 27, 54 do for _, x in ipairs{ 24, 39 } do c:put(x, y, TIM[x == 24 and 3 or 2], t2) end end
for x = 24, 39 do c:put(x, 38, TIM[3], t2) c:put(x, 39, TIM[1], t2) end
for i = 0, 6 do c:put(26 + i, 46 - i, TIM[2], t2) c:put(27 + i, 46 - i, TIM[3], t2) end
window(26, 30, t2) window(33, 30, t2) door(32, 47, t2)
-- cast shadow of the left roof on the middle wall and the right roof's AO against the wall
for y = 27, 36 do c:put(25, y, PLS[2], t2) end
local rm2 = roof(22, 41, 12, 26, DSK, r2, true)
for y = 30, 35 do if rm3:has(40, y) then c:put(40, y, TEAL[1], r3) c:put(41, y, TEAL[2], r3) end end
for y = 33, 35 do c:put(40, y, BRK[1], t3) end
-- AO rows under every eave (contact shadow)
for x = 10, 23 do A.step(c, w1, PLK, x, 36, -1, t1) end

-- pop: 2x1 hi + cream glint on the middle roof's lit slope
c:put(28, 18, DSK[6], r2) c:put(29, 18, DSK[6], r2) c:put(27, 19, "#fff4d6", r2)

-- quirk: ginger cat on the right roof ridge, tail curling down the shaded slope
A.map(c, {
  "a...a..",
  "ab.ba..",
  "acccb..",
  "cecec..",
  "bcdcb..",
  ".bcb...",
  "bcddb..",
  "bcdcb.d",
  ".bbbbdd",
}, 44, 12, { a = CAT[1], b = CAT[2], c = CAT[3], d = CAT[4], e = "#2b1c26" }, A.tok("cat"))
A.save(c, "ico-house-row")
