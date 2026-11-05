-- lizard-scale (lean P1b_O4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function sh(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "lizard-scale" }
local GR = { "#14403f", "#1e6a4a", "#2f9552", "#58bf54", "#9ae060", "#d8f58a" }
local GD = { "#261f3a", "#3c3a5e", "#4f6a78", "#5f9a86", "#86c79a", "#c6efb4" }
c:groundShadow(32, 50, 20, 3)
-- back scale (darker, teal)
local b = c:poly{ {40,8},{56,18},{50,34},{36,28},{32,16} }
sh(c, b, 9, GD)
-- front scale: pointed shield
local f = c:poly{ {32,16},{50,26},{46,44},{30,52},{14,44},{10,26} }
f:cut(HP.mask()) 
local n = X.pillow(f, 12)
G.toneN(c, f, n, GR, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- keel ridge down the middle, 2 tone
for t = 0, 1, 0.02 do
  local x, y = 30 + t * 2, 18 + t * 30
  c:px(floor(x), floor(y), GR[6]) c:px(floor(x) + 1, floor(y), GR[2])
end
-- growth rows: curved bands
f:each(function(x, y)
  local d = (y - 16) + 0.025 * (x - 30) ^ 2
  if d % 8 < 1 and y > 22 and abs(x - 30) < 18 and not (abs(x - 30) < 2) then c:px(x, y, GR[2]) end
end)
-- pits
for _, p in ipairs{ {20,34},{24,40},{38,34},{36,42},{26,28},{34,26} } do c:px(p[1], p[2], GR[1]) c:px(p[1] - 1, p[2] - 1, GR[5]) end
-- quirk: gold fleck spot
c:fillMask(c:ellipse(40, 31, 2, 2), "#f0c040") c:px(40, 30, "#fff2a0") c:px(41, 32, "#c48a20")
c:px(18, 28, "#f4ffd0") c:px(19, 27, "#f4ffd0") c:px(18, 29, GR[5])
G.save(c, "lizard-scale")
