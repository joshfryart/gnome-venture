-- finger-lime (lean P1b_O1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local NAME = "finger-lime"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local SKIN = { "#0f2a20", "#1a4a32", "#2a6b3a", "#47903f", "#7ab44c", "#bfe07a" }
local BEAD = { "#8c1f4a", "#c43a62", "#ec6a80", "#ff9aa0", "#ffc8c4", "#fffaf0" }
local PITH = { "#c9b36a", "#e6d58a", "#fbf3c4" }
PITH[3] = "#fbf3c4"
local STEM = { "#3a2412", "#5e3a1c", "#8c5a2a" }
c:groundShadow(30, 55, 18, 3)
local fm, fn, T = G.tube({ {13, 49}, {13, 32}, {28, 25}, {44, 19} }, function(t)
  return 3 + 3.2 * sin(min(1, t * 1.15) * pi * 0.75) ^ 0.8 end)
local idx = G.toneN(c, fm, fn, SKIN, { amb = 0.1, wrap = 0.3 })
fm:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 4) > 0.9 then c:px(x, y, SKIN[5]) end
  if X.hash(x, y, 6) > 0.95 then c:px(x, y, SKIN[1]) end end)
-- yellow-green streak on the lit side
fm:each(function(x, y) local k = K(x, y) local t = T[k]
  if t > 0.2 and t < 0.85 and fn[k] and fn[k].nx and false then end end)
-- stem nub
local st = c:ellipse(12, 51, 2.4, 2.4)
G.toneN(c, st, X.pillow(st, 2), STEM, {})
c:px(11, 50, STEM[3]) c:px(13, 54, STEM[1])
-- cut end: pith ring + glossy caviar beads
local face = c:ellipse(45, 18, 5.2, 6.6)
G.toneN(c, face, X.pillow(face, 3), PITH, { amb = 0.3 })
local fi = c:ellipse(45, 18, 3.8, 5.2)
c:fillMask(fi, BEAD[1])
local beads = { {44,14},{47,15},{44,18},{47,19},{44,22},{46,22},{45,16},{46,17},{45,20} }
for _, b in ipairs(beads) do local bm = c:ellipse(b[1], b[2], 1.5, 1.5):clip(fi)
  G.toneN(c, bm, X.pillow(bm, 1.6), BEAD, { amb = 0.1 }) c:px(b[1] - 1, b[2] - 1, BEAD[6]) end
-- loose pearls (quirk: one rolling away)
for _, b in ipairs{ {52,28,"#ff7e9a"},{56,32,"#f4d06a"},{50,34,"#ff9aa0"},{55,37,"#ec6a80"} } do
  local bm = c:ellipse(b[1], b[2], 1.7, 1.7)
  G.toneN(c, bm, X.pillow(bm, 1.7), BEAD, { amb = 0.1 }) c:px(b[1] - 1, b[2] - 1, BEAD[6]) end
G.save(c, NAME)
