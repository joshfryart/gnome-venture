-- Anemone Nudge (cs-anemone-nudge), perch sprite 36x36. Opus richness pass (c08/opus3), hand-built at this size: coral column
-- on a grey stone with the face on it, a bold crown of nine thick lilac tentacles with 2 px pink bulb tips
-- (the Haiku perch fringe was too faint), 2x3 pill eyes and a grin.
-- Richness kept bold: rim-lit tentacles with a pale ring under each tip, verrucae dots on the column,
-- pitted stone with algae, ink-edged clownfish tail.
-- quirk: one tentacle reaches out to nudge a small clownfish (orange, one cream band, tail fin).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-anemone-nudge-perch", 36)

local CORAL = { "#6e2038", "#a83a4a", "#d8604f", "#f08a62", "#ffb48a", "#ffdcc0" }
local LAV   = { "#4a2a6a", "#7a4a9a", "#a86ac0", "#cf92da", "#ecbfe8", "#fbe4f6" }
local TIP   = { "#d84a8a", "#ff8ab8", "#ffc4dc" }
local STONE = { "#2e3048", "#444663", "#5e6080", "#74758c", "#9a9aae", "#c4c3d0" }
local FISH  = { "#6e2018", "#b23a14", "#e8641c", "#ff8a2a", "#ffb45a", "#ffd890" }

c:groundShadow(16, 33, 11, 1.5)
local sI, sT = O.shade(c, c:ellipse(15, 30, 9, 2.5), STONE, { R = 1, amb = .3, sep = STONE[1] })
O.tex(c, sI, sT, STONE, function(x, y, i) if O.H(x, y, 3) > .8 then return -2 end end)
O.dots(c, { { 8, 28 }, { 9, 28 } }, "#3f9150") O.dot(c, 8, 27, "#7cc35a")
local function tent(a, len, w)
  local r = math.rad(a)
  local x0, y0 = 15 + math.cos(r) * 3, 15
  local x1, y1 = 15 + math.cos(r) * len, 14 + math.sin(r) * len * .8
  local m, n = O.tube({ { x0, y0 }, { (x0 + x1) / 2, (y0 + y1) / 2 - 1 }, { (x0 + x1) / 2, (y0 + y1) / 2 - 1 }, { x1, y1 } }, function() return w end)
  O.shadeN(c, m, n, LAV, { amb = .3, wrap = .35, sep = LAV[1], rim = true })
  O.shade(c, c:rect(math.floor(x1 - .5), math.floor(y1 - .5), math.floor(x1 + .5), math.floor(y1 + .5)), TIP, { R = 1, amb = .45, cuts = { .45, .8 } })
end
for _, a in ipairs({ 195, 235, 270, 305, 345 }) do tent(a, 10, 1.2) end
local col = c:ellipse(15, 21, 7.5, 7) col:add(c:rect(8, 21, 22, 28)) col:cut(c:rect(0, 0, 35, 15))
O.shade(c, col, CORAL, { sphere = { 13, 18, 10 }, amb = .32, wrap = .4, sep = CORAL[1], rim = true, bounce = "#3a86b0", bmax = 2 })
O.mark(c, { { 10, 25 }, { 10, 26 }, { 20, 25 }, { 20, 26 } }, CORAL[2])
O.mark(c, { { 9, 18 }, { 21, 19 }, { 11, 16 }, { 19, 16 } }, CORAL[5])

for _, a in ipairs({ 210, 250, 290, 330 }) do tent(a, 8, 1.2) end
-- nudging tentacle + clownfish
local m, n = O.tube({ { 21, 22 }, { 24, 22 }, { 25, 25 }, { 25, 27 } }, function() return 1.1 end)
O.shadeN(c, m, n, LAV, { amb = .3, sep = LAV[1] })
O.shade(c, c:rect(25, 27, 26, 28), TIP, { R = 1, amb = .45, cuts = { .45, .8 } })
O.shade(c, c:poly{ { 28, 26 }, { 26, 23 }, { 26, 29 } }, FISH, { R = 1, amb = .35, sep = FISH[1] })
O.dots(c, { { 26, 24 }, { 26, 25 }, { 26, 27 }, { 26, 28 } }, P.ink)
local fb = c:ellipse(31, 26, 3.5, 2.5)
O.shade(c, fb, FISH, { sphere = { 30, 24, 4 }, amb = .35, wrap = .4, sep = FISH[1], rim = true })
O.dots(c, { { 30, 24 }, { 30, 25 }, { 30, 26 }, { 30, 27 }, { 30, 28 } }, "#fff4d6")
O.dots(c, { { 31, 24 }, { 31, 25 }, { 31, 26 }, { 31, 27 }, { 31, 28 } }, P.ink)
O.dot(c, 33, 25, P.ink)
-- face
c:eyeSmall(11, 19)
c:eyeSmall(17, 19)
O.dots(c, { { 9, 23 }, { 21, 23 } }, "#f5809f")
O.dots(c, { { 12, 23 }, { 13, 24 }, { 14, 24 }, { 15, 24 }, { 16, 24 }, { 17, 23 } }, P.ink)
O.shift(c, -2, -1)
O.done(c, "cs-anemone-nudge-perch")
