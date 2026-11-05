-- fox-fang (lean P1b_O1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local NAME = "fox-fang"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local IV = { "#6a5a7a", "#9a8aa6", "#c8bccb", "#ece2de", "#fff6e6", "#fffaf0" }
local FUR = { "#7a2a10", "#b84a14", "#e8701c", "#ff9a34", "#ffc468", "#fff0cc" }
local CORD = { "#0e3c4a", "#176472", "#2a94a0", "#58c4c0", "#a0eadc" }
local AMB = { "#5a3418", "#8a5a24", "#b8863a" }
c:groundShadow(36, 57, 15, 3)
local fm, fn, T = G.tube({ {19, 17}, {14, 38}, {32, 52}, {52, 54} }, function(t)
  return 0.5 + 6.3 * (1 - t) ^ 0.75 end)
G.toneN(c, fm, fn, IV, { amb = 0.12, wrap = 0.3 })
-- amber root stain and enamel groove
fm:each(function(x, y) local t = T[K(x, y)]
  if t < 0.14 then c:px(x, y, (t < 0.07) and AMB[2] or AMB[3]) end end)
for t = 0.2, 0.8, 0.03 do local x, y = G.bez({ {19, 17}, {14, 38}, {32, 52}, {52, 54} }, t)
  c:px(floor(x + 1.2 * (1 - t) + 0.5), floor(y + 0.5), IV[2]) end
-- spec streak
for _, p in ipairs{ {15,27},{15,29},{16,32},{18,36} } do c:px(p[1], p[2], IV[6]) end
-- chip near tip (quirk)

-- pierced hole + cord loop through it
c:fillMask(c:ellipse(19, 21, 1.6, 1.6), IV[1]) c:px(19, 21, CORD[1])
local loop = c:ellipse(20, 11, 6, 6):cut(c:ellipse(20, 11, 3.5, 3.5))
local lm = loop:copy()
G.toneN(c, lm, X.pillow(lm, 1.5), CORD, { amb = 0.2, cuts = { 0.25, 0.45, 0.65, 0.85 } })
loop:each(function(x, y) if (x + y) % 3 == 0 then c:px(x, y, CORD[2]) end end)
-- wrap band of cord with fur tuft
for i = 0, 2 do for dx = -6, 6 do
  local y = 26 + i * 2 + floor(dx * 0.25)
  local x = 15 + dx
  if fm:has(x, y) then c:px(x, y, (i % 2 == 0) and CORD[3] or CORD[1]) end end end
local tuft = HP.mask()
tuft:add(c:poly{ {9,27},{6,18},{12,24},{12,14},{16,23},{18,12},{20,23},{25,17},{23,27} })
tuft:cut(fm)
G.toneN(c, tuft, X.pillow(tuft, 2.5), FUR, { amb = 0.25, wrap = 0.4 })
tuft:each(function(x, y) if y < 20 and X.hash(x, y, 1) > 0.5 then c:px(x, y, FUR[6]) end end)
G.save(c, NAME)
