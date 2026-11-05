-- frog-skin (lean P1b_O1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local NAME = "frog-skin"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local GRN = { "#123f2a", "#1f6a34", "#35953a", "#5cba46", "#92dc5a", "#d2f58a" }
local BEL = { "#8c8a3c", "#bcb85a", "#e0dc84", "#f4f0ac", "#fffbd2", "#fffaf0" }
local SPOT = { "#0c2a1c", "#16401f" }
local PEG = { "#4a2a1c", "#74421f", "#a2652e", "#d9a45a" }
c:groundShadow(32, 58, 18, 2)
local hide = HP.mask()
hide:add(c:ellipse(32, 34, 8.5, 13)):add(c:ellipse(32, 19, 7.5, 5.5))
local limbs = {
  { {26,26},{20,24},{14,24},{10,31}, 2.4, 1.2 },
  { {38,26},{44,24},{50,24},{54,31}, 2.4, 1.2 },
  { {26,42},{16,42},{14,50},{9,55}, 3.6, 1.4 },
  { {38,42},{48,42},{50,50},{55,55}, 3.6, 1.4 },
}
local ends = {}
for _, L in ipairs(limbs) do
  local m = G.tube({ L[1], L[2], L[3], L[4] }, function(t) return L[5] - (L[5] - L[6]) * t end)
  hide:add(m)
  local ex, ey = L[4][1], L[4][2]
  -- webbed foot: three toes fanned
  local dx = (ex < 32) and -1 or 1
  local web = c:poly{ {ex, ey - 1}, {ex + dx * 3, ey + 5}, {ex - dx * 3, ey + 5}, {ex + dx * 6, ey + 2} }
  hide:add(web)
  ends[#ends + 1] = { ex + dx * 2, ey + 3 }
end
local n = X.pillow(hide, 4)
G.toneN(c, hide, n, GRN, { amb = 0.15, wrap = 0.35 })
-- pale belly seam down the middle and inner limbs
c:fillMask(c:ellipse(32, 36, 3.2, 10), BEL[3])
local belly = c:ellipse(32, 36, 3.2, 10)
G.toneN(c, belly, X.pillow(belly, 3), BEL, { amb = 0.25 })
-- dark blotches
for _, s in ipairs{ {28,30,2},{36,28,1.6},{29,44,2},{37,41,1.8},{32,17,1.4},{12,27,1.2},{52,27,1.2},{14,46,1.6},{50,46,1.6},{18,43,1.2},{46,43,1.3},{27,22,1.2} } do
  local sm = c:ellipse(s[1], s[2], s[3], s[3] * 0.8):clip(hide)
  c:fillMask(sm, SPOT[1]) c:px(s[1] - 1, s[2] - 1, SPOT[2]) end
-- empty eye holes (quirk: hollow pelt)
for _, e in ipairs{ {28,17},{36,17} } do
  local em = c:ellipse(e[1], e[2], 2.2, 2.2)
  c:fillMask(em, "#1a0f22") c:px(e[1] - 1, e[2] - 1, GRN[6]) c:px(e[1] - 2, e[2] - 2, GRN[5]) end
-- glossy specs
c:px(29, 24, GRN[6]) c:px(30, 24, GRN[6]) c:px(24, 36, GRN[5]) c:px(23, 45, GRN[5])
-- bone pegs through the toes
for _, e in ipairs(ends) do c:fillMask(c:ellipse(e[1], e[2], 1.5, 1.5), PEG[3]) c:px(e[1] - 1, e[2] - 1, PEG[4]) c:px(e[1] + 1, e[2] + 1, PEG[1]) end
G.save(c, NAME)
