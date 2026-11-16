-- Anemone Nudge (cs-anemone-nudge), yard sprite 64x64. Opus second pass (art-2701-pals-all/c08/opus2), redrawn from ../haiku.
-- Common, seedkeeper. "Nudges the clownfish home whenever they wander too far."
-- A bubble-tip sea anemone on a reef stone: coral-peach column with fine vertical grooves and the face on it,
-- a full crown of lilac tentacles with bulbed pink tips.
-- Fixes: the Haiku blob had no anemone read (no crown); the clownfish read as a candy. Now the crown is the
-- silhouette and the clownfish has a body, fins, tail, eye and ink-edged cream bands.
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

c:groundShadow(29, 58, 17, 2)

-- reef stone
local rock = c:ellipse(28, 54, 14, 4.5)
rock:add(c:ellipse(20, 52, 6, 4))
local rI, rT = O.shade(c, rock, STONE, { sphere = { 22, 49, 14 }, amb = .25, wrap = .35, sep = STONE[1] })
O.tex(c, rI, rT, STONE, function(x, y, i) if O.H(x, y, 3) > .88 then return -1 end end)

local function tent(x0, y0, x1, y1, w, back)
  local mx, my = (x0 + x1) / 2 + (x1 - x0) * .1, (y0 + y1) / 2 - 1
  local p = { { x0, y0 }, { mx, my }, { mx, my }, { x1, y1 } }
  local m, n = O.tube(p, function(t) return w * (1 - t * .25) end)
  local ramp = back and { LAV[1], LAV[2], LAV[3], LAV[4], LAV[5] } or LAV
  O.shadeN(c, m, n, ramp, { amb = .25, wrap = .35, sep = LAV[1] })
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
O.tex(c, cI, cT, CORAL, function(x, y, i)
  if (x == 20 or x == 38) and y > 41 then return -1 end
  if (x == 24 or x == 34) and y > 44 then return -1 end
  if O.H(x, y, 9) > .96 and i >= 3 then return 1 end
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
  -- dorsal + belly fins
  O.shade(c, c:ellipse(fx, fy - 3.5, 3, 2), FISH, { R = 1, amb = .35, sep = FISH[1] })
  O.shade(c, c:poly{ { fx - 1, fy + 3 }, { fx + 1, fy + 5 }, { fx + 2, fy + 3 } }, FISH, { R = 1, amb = .35, sep = FISH[1] })
  local body = c:ellipse(fx, fy, 6, 3.6)
  O.shade(c, body, FISH, { sphere = { fx - 1, fy - 2, 6 }, amb = .3, wrap = .4, sep = FISH[1] })
  -- cream bands edged in ink
  for _, bx in ipairs({ fx - 3, fx + 2 }) do
    local band = c:rect(bx, fy - 4, bx, fy + 4) band:clip(body)
    O.mark(c, (function() local l = {} band:each(function(x, y) l[#l+1] = { x, y } end) return l end)(), "#fff4d6")
    local edge = c:rect(bx + 1, fy - 4, bx + 1, fy + 4) edge:clip(body)
    O.mark(c, (function() local l = {} edge:each(function(x, y) l[#l+1] = { x, y } end) return l end)(), P.ink)
  end
  O.dot(c, fx + 4, fy - 1, P.ink)
  O.dot(c, fx + 4, fy - 2, "#fff4d6")
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
