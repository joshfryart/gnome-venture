-- frog-skin (lean W2_4)
-- Spread frog hide: body, four splayed limbs with toe pads, mottled dark spots, pale belly patch, one dewdrop quirk.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local function shade(c, m, R, r, amb, bias) local n = X.pillow(m, r) local v = X.light(n, { amb = amb or 0.1, wrap = 0.25 }) G.tone(c, m, v, R, CUTS, bias) return v, n end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "frog-skin" }
local GR = { "#1e3d2a", "#2c5d34", "#3f8040", "#5da24a", "#85c35a", "#b4de7c" }
local BE = { "#6a6a3a", "#97994e", "#c2c26a", "#e0df90", "#f2f0b4", "#fdfbd6" }
local DK = { "#17301f", "#1e3d2a", "#2c5d34" }
local body = c:ellipse(32, 31, 9, 13)
local head = c:ellipse(32, 15, 8, 5)
local limbs = HP.mask()
limbs:add(c:line({{24,22},{16,20},{9,14}}, 3)) limbs:add(c:line({{40,22},{48,20},{55,14}}, 3))
limbs:add(c:line({{25,38},{17,44},{14,52}}, 4)) limbs:add(c:line({{39,38},{47,44},{50,52}}, 4))
limbs:add(c:line({{14,52},{11,56}}, 2)) limbs:add(c:line({{50,52},{53,56}}, 2))
local all = body:copy():add(head):add(limbs)
local v = shade(c, all, GR, 5, 0.1)
-- toe pads
for _, p in ipairs{ {8,13},{10,12},{7,15},{56,13},{54,12},{57,15},{10,57},{12,58},{9,55},{54,57},{52,58},{55,55} } do c:put(p[1], p[2], BE[4]) c:put(p[1]+1, p[2], BE[3]) end
-- belly patch
local belly = c:ellipse(32, 33, 4, 8):cut(c:ellipse(32, 33, 2, 5))
local bm = c:ellipse(32, 34, 5, 9)
shade(c, bm, BE, 5, 0.15)
for y = 24, 44 do c:put(32, y, BE[2]) end
-- spots
for i = 1, 40 do
  local x, y = floor(14 + X.hash(i, 1, 7) * 36), floor(14 + X.hash(i, 2, 7) * 42)
  if all:has(x, y) and not bm:has(x, y) and X.hash(i, 3, 7) > 0.35 then
    c:put(x, y, DK[1 + i % 3]) c:put(x + 1, y, DK[2]) if i % 2 == 0 then c:put(x, y + 1, DK[3]) end
  end
end
-- eye holes in the hide
for _, x in ipairs{ 27, 37 } do c:fillMask(c:ellipse(x, 13, 2, 2), DK[1]) c:put(x - 1, 12, GR[6]) end
-- leg creases + spec + dewdrop quirk
for _, p in ipairs{ {16,20},{48,20},{17,44},{47,44} } do c:put(p[1], p[2], GR[1]) end
c:put(28, 20, GR[6]) c:put(29, 20, GR[6]) c:put(27, 21, GR[5])
c:put(38, 40, "#bfeaff") c:put(39, 40, "#fff") c:put(38, 41, "#6fb7e0") c:put(39, 41, "#4f8fc8")
G.fin(c, "frog-skin")
