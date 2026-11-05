-- millipede-plate (lean P1b_O4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function sh(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "millipede-plate" }
local SH = { "#3a1a14", "#6a2e1a", "#a0481e", "#d0702a", "#f09a3c", "#ffd078" }
local DK = { "#241418", "#3e2420", "#5e362a", "#7e4c34", "#a06a44", "#c89868" }
c:groundShadow(32, 50, 22, 3)
-- legs (tubes) under both plates
local function legs(x0, x1, y, col, col2)
  for x = x0, x1, 4 do
    for k = 0, 5 do c:px(x + floor(k / 3), y + k, col) end
    c:px(x - 1 + floor(1), y + 6, col2) c:px(x, y + 6, col2)
  end
end
-- back plate (smaller, dark)
local bk = c:ellipse(18, 36, 11, 13) bk:cut(c:rect(0, 37, 63, 63))
legs(10, 26, 37, DK[2], DK[1])
sh(c, bk, 9, DK)
for y = 24, 36 do c:px(18, y, DK[2]) end
-- front plate: wide dome
local m = c:ellipse(36, 38, 20, 19)
m:cut(c:rect(0, 39, 63, 63))
legs(24, 48, 39, SH[2], SH[1])
local n = X.pillow(m, 14)
G.toneN(c, m, n, SH, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- ridges: concentric arcs from the hinge, dark groove + light lip
m:each(function(x, y)
  local d = sqrt(((x - 36) / 20) ^ 2 + ((y - 38) / 19) ^ 2)
  local k = (d * 40) % 8
  if k < 1 and d > 0.15 and d < 0.9 then c:px(x, y, SH[1]) elseif k >= 1 and k < 2 and d > 0.15 and d < 0.9 then c:px(x, y, SH[6]) end
end)
-- bottom rim band + pale ventral edge
for x = 16, 56 do if m:has(x, 38) then c:px(x, 38, SH[2]) end if m:has(x, 37) then c:px(x, 37, SH[3]) end end
-- spiracle pores along the top (quirk: one glowing pore)
for _, p in ipairs{ {26,24},{36,21},{46,24},{53,31} } do c:px(p[1], p[2], SH[1]) end
c:px(36, 22, "#ffe8a0") c:px(35, 21, "#ffe8a0")
c:px(28, 24, SH[6]) c:px(29, 23, SH[6]) c:px(27, 25, SH[6])
G.save(c, "millipede-plate")
