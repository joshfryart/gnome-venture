-- loach-scale (lean P1b_O4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function sh(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "loach-scale" }
local SV = { "#4a5f8a", "#7a93bc", "#a9c0dc", "#cfe0ee", "#e6f2f8", "#f6fbfc" }
local RM = { "#7a4a8c", "#b46aa8", "#e898b8", "#f6c8c0", "#ffe6c0" }
c:groundShadow(32, 51, 18, 3)
local cx, cy, rx, ry = 31, 29, 22, 20
local m = c:ellipse(cx, cy, rx, ry)
-- chip bite out of lower right (quirk)
local bite = c:ellipse(50, 42, 5, 4)
m:cut(bite)
local n = X.pillow(m, 14)
G.toneN(c, m, n, SV, { cuts = { 0.22, 0.4, 0.58, 0.74, 0.88 }, amb = 0.15 })
-- growth rings around nucleus (off-centre toward lower right)
local nx, ny = 36, 34
m:each(function(x, y)
  local d = sqrt((x - nx) ^ 2 + (y - ny) ^ 2)
  if d % 4.5 < 1 and d > 3 then c:px(x, y, SV[2]) elseif d % 4.5 < 2 and d % 4.5 >= 1 and d > 3 and (x + y) % 2 == 0 and false then end
end)
-- radial ridges fanning from nucleus to upper-left edge
for _, a in ipairs{ 3.4, 3.9, 4.4, 4.9, 5.3 } do
  for r = 6, 30 do
    local x, y = floor(nx + cos(a) * r + 0.5), floor(ny + sin(a) * r + 0.5)
    if m:has(x, y) and r > 7 then c:px(x, y, SV[1 + (r % 2)]) end
  end
end
-- iridescent rim crescent lower-right
m:each(function(x, y)
  local d = sqrt((x - cx) ^ 2 / (rx * rx) + (y - cy) ^ 2 / (ry * ry))
  if d > 0.86 and x + y > 62 then c:px(x, y, RM[1 + floor((x - y + 40) / 5) % 4]) end
end)
c:fillMask(c:ellipse(37, 35, 2, 2), RM[3]) c:px(37, 35, RM[5])
-- spec glint upper left
for _, p in ipairs{ {18,17},{19,16},{20,15},{17,18} } do c:px(p[1], p[2], SV[6]) end
G.save(c, "loach-scale")
