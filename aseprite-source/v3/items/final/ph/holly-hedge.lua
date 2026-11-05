-- holly-hedge (lean P1b_O3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local function dot(c, x, y, h) c:px(x, y, h) end
local c = HP.canvas{ w=64, h=64, scale=1, name="holly-hedge" }
local H = { "#10301f", "#1c4a2a", "#2a6a34", "#3c8a3e", "#64ae4a", "#a4d870" }
local BR = { "#5a0c1c", "#9a1428", "#d42a38", "#f2605a", "#ffb0a0" }
c:groundShadow(32, 52, 24, 3)
local hm = HP.mask()
hm:add(c:rrect(8, 22, 56, 52, 5))
for x = 9, 55, 5 do hm:add(c:ellipse(x, 22, 3, 3)) end
for x = 11, 53, 6 do hm:add(c:ellipse(x, 29, 1, 1)) end
local bias = {}
hm:each(function(x, y) local h = X.hash(floor(x/4), floor(y/3), 9) if h > 0.7 then bias[K(x,y)] = 1 elseif h < 0.22 then bias[K(x,y)] = -1 end end)
G.toneN(c, hm, X.pillow(hm, 11), H, { bias = bias, cuts = {0.18,0.36,0.54,0.72,0.88} })
-- spiky leaf marks: small bright zigzags with dark underside
for y = 26, 49, 5 do for x = 12 + (y % 2) * 3, 53, 6 do
  c:px(x, y, H[6]) c:px(x + 1, y + 1, H[5]) c:px(x + 2, y, H[6]) c:px(x + 1, y + 2, H[1]) c:px(x + 2, y + 2, H[1]) c:px(x - 1, y + 1, H[1]) end end
-- spikes on top edge
for x = 10, 54, 6 do c:px(x, 17, H[3]) c:px(x, 18, H[4]) c:px(x + 1, 19, H[2]) end
-- berry clusters
local function berry(x, y) shade(c, c:ellipse(x, y, 2, 2), 3, BR) c:px(x - 1, y - 1, BR[5]) end
for _, p in ipairs{ {17,33},{20,35},{18,36},{38,30},{41,32},{39,34},{50,40},{47,42} } do berry(p[1], p[2]) end
-- quirk: berry heart chain dropped on bottom
berry(26, 46) berry(29, 47)
-- trimmed square notch
c:fillMask(c:rect(30, 14, 36, 16), H[2]) c:fillMask(c:rect(31, 13, 35, 13), H[4])
G.save(c, "holly-hedge")
