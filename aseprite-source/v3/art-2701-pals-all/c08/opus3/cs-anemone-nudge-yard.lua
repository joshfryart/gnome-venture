-- Anemone Nudge (cs-anemone-nudge), yard sprite 64x64. Opus second pass (art-2701-pals-all/c08/opus2), redrawn from ../haiku.
-- Common, seedkeeper. "Nudges the clownfish home whenever they wander too far."
-- A bubble-tip sea anemone on a reef stone: coral-peach column with fine vertical grooves and the face on it,
-- a full crown of lilac tentacles with bulbed pink tips.
-- Fixes: the Haiku blob had no anemone read (no crown); the clownfish read as a candy. Now the crown is the
-- silhouette and the clownfish has a body, fins, tail, eye and ink-edged cream bands.
-- Richness: tentacles with a pale translucent core stripe, rim light and a lighter ring below each bulb tip;
-- column with rows of lit verrucae bumps and vertical grooves, porous reef
-- stone with pits, a green algae fuzz and a barnacle; clownfish with ink-edged fins, curved bands, rim light.
-- closer look: a tiny baby clownfish already tucked into the crown (home), peeking out on the left.
-- quirk: one long tentacle reaches out and gently nudges the clownfish's tail toward home.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-anemone-nudge-yard", 64)

local CORAL = { "#6e2038", "#a83a4a", "#d8604f", "#f08a62", "#ffb48a", "#ffdcc0" }
local LAV   = { "#4a2a6a", "#7a4a9a", "#a86ac0", "#cf92da", "#ecbfe8", "#fbe4f6" }
local TIP   = { "#9a2a6a", "#d84a8a", "#ff8ab8", "#ffc4dc" }
local STONE = { "#2e3048", "#444663", "#5e6080", "#74758c", "#9a9aae", "#c4c3d0" }
local FISH  = { "#6e2018", "#b23a14", "#e8641c", "#ff8a2a", "#ffb45a", "#ffd890" }
local BNC = "#3a86b0"
local ALG = { "#24544a", "#3f9150", "#7cc35a" }

c:groundShadow(29, 58, 17, 2)

-- reef stone
local rock = c:ellipse(28, 54, 14, 4.5)
rock:add(c:ellipse(20, 52, 6, 4))
local rI, rT = O.shade(c, rock, STONE, { sphere = { 22, 49, 14 }, amb = .25, wrap = .35, sep = STONE[1] })
O.tex(c, rI, rT, STONE, function(x, y, i)
  local h = O.H(x // 2, y, 3)
  if h > .82 and (x % 2 == 0) then return -2 end           -- pits
  if O.H(x, y, 21) > .9 and i >= 3 then return 1 end      -- lit grit
end)
-- algae fuzz on the stone's top edge (left) and a barnacle (right)
O.dots(c, { { 15, 49 }, { 17, 48 }, { 18, 48 }, { 20, 48 }, { 14, 50 }, { 16, 49 } }, ALG[2])
O.dots(c, { { 17, 47 }, { 20, 47 } }, ALG[3]) O.dots(c, { { 15, 50 }, { 19, 49 } }, ALG[1])
O.shade(c, c:ellipse(38.5, 53.5, 1.5, 1.5), { "#74758c", "#c4c3d0", "#e8e4e0" }, { R = 1, amb = .45, cuts = { .4, .75 } })
O.dot(c, 38, 53, STONE[1])

local function tent(x0, y0, x1, y1, w, back)
  local mx, my = (x0 + x1) / 2 + (x1 - x0) * .1, (y0 + y1) / 2 - 1
  local p = { { x0, y0 }, { mx, my }, { mx, my }, { x1, y1 } }
  local m, n, T, S = O.tube(p, function(t) return w * (1 - t * .25) end)
  local ramp = back and { LAV[1], LAV[2], LAV[3], LAV[4], LAV[5] } or LAV
  local I, Tk = O.shadeN(c, m, n, ramp, { amb = .25, wrap = .35, sep = LAV[1], rim = not back })
  O.tex(c, I, Tk, ramp, function(x, y, i)
    local t, sv = T[O.K(x, y)], S[O.K(x, y)]
    if not t then return 0 end
    if t > .78 and t < .86 then return 1 end                         -- pale ring under the bulb
    if not back and math.abs(sv) < .3 and t > .2 and t < .7 and i >= 3 then return 1 end -- translucent core
  end)
  local tip = c:ellipse(x1, y1, 1.5, 1.5)
  O.shade(c, tip, TIP, { R = 1, amb = .45, cuts = { .3, .55, .8 }, sep = LAV[1] })
  O.dot(c, math.floor(x1 - .5), math.floor(y1 - .5), TIP[4])
end

-- back row of tentacles
for i, a in ipairs({ 200, 222, 244, 266, 288, 310, 332 }) do
  local r = math.rad(a)
  local bx = 29 + math.cos(r) * 6
  tent(bx, 28, 29 + math.cos(r) * 18, 27 + math.sin(r) * 15, 1.8, true)
end

-- column
local col = c:ellipse(29, 40, 12, 12)
col:add(c:rect(17, 40, 41, 50))
col:add(c:ellipse(29, 50, 12, 3))
col:cut(c:rect(0, 0, 63, 27))
local cI, cT = O.shade(c, col, CORAL, { sphere = { 25, 36, 18 }, amb = .32, wrap = .4, sep = CORAL[1], rim = true, bounce = BNC, bmax = 2 })
-- vertical grooves and tiny verrucae spots
local function onFace(x, y) return ((x - 28.5) / 9.5)^2 + ((y - 39) / 6.5)^2 < 1 end
O.tex(c, cI, cT, CORAL, function(x, y, i)
  if (x == 20 or x == 38) and y > 41 then return -1 end
  if (x == 24 or x == 34) and y > 45 then return -1 end
  if onFace(x, y) then return 0 end
  -- rows of verrucae: lit bump with a dark pixel below
  local ok = function(yy) return (x + (yy // 4) * 2) % 4 == 0 and O.H(x, yy, 4) > .35 end
  if y % 4 == 1 and ok(y) and i >= 2 then return 1 end
  if y % 4 == 2 and ok(y - 1) and i >= 3 then return -1 end
end)
-- oral disc rim
local disc = c:ellipse(29, 28, 12, 2.5)
O.shade(c, disc, CORAL, { R = 1, amb = .35, sep = CORAL[1] })
O.mark(c, { { 27, 28 }, { 28, 28 }, { 29, 28 }, { 30, 28 }, { 31, 28 } }, CORAL[2])

-- front row of tentacles
for _, a in ipairs({ 190, 212, 236, 258, 282, 304, 328, 350 }) do
  local r = math.rad(a)
  local bx = 29 + math.cos(r) * 10
  tent(bx, 29, 29 + math.cos(r) * 16, 28 + math.sin(r) * 11, 2, false)
end

-- closer look: a baby clownfish tucked into the crown, peeking out on the left
do
  local bx, by = 14, 30
  O.shade(c, c:ellipse(bx, by, 3, 2), FISH, { sphere = { bx - 1, by - 1, 3 }, amb = .35, wrap = .4, sep = LAV[1] })
  O.dots(c, { { bx + 1, by - 1 }, { bx + 1, by }, { bx + 1, by + 1 } }, "#fff4d6")
  O.dots(c, { { bx + 2, by - 1 }, { bx + 2, by + 1 } }, P.ink)
  O.dot(c, bx - 2, by - 1, P.ink) O.dot(c, bx - 2, by - 2, "#fff4d6")
end

-- the nudging tentacle, out to the right and down
do
  local p = { { 39, 39 }, { 45, 39 }, { 46, 45 }, { 47, 49 } }
  local m, n = O.tube(p, function(t) return 2 * (1 - t * .3) end)
  O.shadeN(c, m, n, LAV, { amb = .3, sep = LAV[1] })
  local tip = c:ellipse(47.5, 50, 1.5, 1.5)
  O.shade(c, tip, TIP, { R = 1, amb = .45, cuts = { .3, .55, .8 }, sep = LAV[1] })
end

-- clownfish, swimming off right, its tail at the tentacle tip
do
  local fx, fy = 54, 47
  -- tail
  local tail = c:poly{ { fx - 5, fy }, { fx - 9, fy - 3 }, { fx - 9, fy + 3 } }
  O.shade(c, tail, FISH, { R = 1, amb = .35, sep = FISH[1] })
  O.dots(c, { { fx - 9, fy - 2 }, { fx - 9, fy - 1 }, { fx - 9, fy }, { fx - 9, fy + 1 }, { fx - 9, fy + 2 } }, "#2b1c26")
  O.dots(c, { { fx - 8, fy - 1 }, { fx - 8, fy + 1 } }, "#fff4d6")
  -- dorsal + belly fins
  O.shade(c, c:ellipse(fx, fy - 3.5, 3, 2), FISH, { R = 1, amb = .35, sep = FISH[1] })
  O.shade(c, c:poly{ { fx - 1, fy + 3 }, { fx + 1, fy + 5 }, { fx + 2, fy + 3 } }, FISH, { R = 1, amb = .35, sep = FISH[1] })
  local body = c:ellipse(fx, fy, 6, 3.6)
  O.shade(c, body, FISH, { sphere = { fx - 1, fy - 2, 6 }, amb = .3, wrap = .4, sep = FISH[1], rim = true })
  -- cream bands edged in ink
  for _, bx in ipairs({ fx - 3, fx + 2 }) do
    local band = c:rect(bx, fy - 4, bx, fy + 4) band:clip(body)
    O.mark(c, (function() local l = {} band:each(function(x, y) l[#l+1] = { x, y } end) return l end)(), "#fff4d6")
    local edge = c:rect(bx + 1, fy - 4, bx + 1, fy + 4) edge:clip(body)
    O.mark(c, (function() local l = {} edge:each(function(x, y) l[#l+1] = { x, y } end) return l end)(), P.ink)
  end
  O.dot(c, fx + 4, fy - 1, P.ink)
  O.dot(c, fx + 4, fy - 2, "#fff4d6")
  O.dot(c, fx + 6, fy + 1, FISH[1]) -- mouth
end

-- face on the column
c:eyeLocked(22, 35)
c:eyeLocked(32, 35)
c:cheek(19, 41) c:cheek(38, 41)
O.dots(c, { { 25, 42 }, { 26, 43 }, { 27, 43 }, { 28, 43 }, { 29, 43 }, { 30, 43 }, { 31, 43 }, { 32, 42 } }, P.ink)

O.shift(c, -3, -1)
O.done(c, "cs-anemone-nudge-yard", function(c)
  -- a bubble from the clownfish
  c:put(59, 40, "#3a86b0") c:put(58, 41, "#3a86b0") c:put(60, 41, "#3a86b0") c:put(59, 42, "#3a86b0") c:put(59, 41, "#e4f6ff")
end)
