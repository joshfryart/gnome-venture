-- tide-shell (lean W2_34)
-- Scallop fan: ribbed pink valves with scalloped rim, two hinge ears, pearl at the hinge (quirk), barnacle dots.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tide-shell" }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local PINK = { "#5a2a5e", "#8a3d7a", "#b85a90", "#dc7fa4", "#f2a6b6", "#ffd6d2" }
local PEARL = { "#9a8fb8", "#d8d0e6", "#fff6f4" }
local HX, HY, NR = 32, 49, 11
c:groundShadow(32, 54, 18, 3)
local fan, ribs = HP.mask(), {}
local A0 = 1.38
for y = 14, 52 do for x = 8, 56 do
  local dx, dy = x - HX, y - HY
  local r = sqrt(dx*dx + dy*dy)
  local th = atan(dx, -dy)
  if abs(th) <= A0 and dy <= 0 then
    local rib = (th / A0 * 0.5 + 0.5) * 9
    local edge = 24.5 - 2.2 * abs(sin(rib * pi)) ^ 0.7 - 5 * (abs(th) / A0) ^ 3
    if r <= edge then
      fan:set(x, y)
      ribs[K(x, y)] = { r = r, ph = abs(sin(rib * pi)), s = cos(rib * pi), th = th, edge = edge }
    end
  end
end end
-- hinge base block
local base = HP.mask()
base:add(c:poly{ {HX - 9, HY - 2}, {HX + 9, HY - 2}, {HX + 12, HY + 4}, {HX - 12, HY + 4} })
base:add(c:ellipse(HX, HY + 2, 12, 3))
base:cut(c:rect(0, 0, 63, HY - 3))
local all = fan:copy():add(base)
local v = {}
all:each(function(x, y)
  local k = K(x, y)
  local q = ribs[k]
  local val
  if q then
    val = 0.5 + 0.28 * q.s * (q.th > 0 and -1 or 1) * -1
    val = val + (1 - q.ph) * 0.12 - q.r / 24 * 0.2
    if q.th < 0 then val = val + 0.12 else val = val - 0.1 end
    -- concentric growth lines
    if floor(q.r + 0.5) % 6 == 0 then val = val - 0.14 end
  else
    val = 0.4 - (y - HY) * 0.03
  end
  v[k] = max(0, min(1, val))
end)
G.tone(c, all, v, PINK, { 0.2, 0.36, 0.5, 0.64, 0.8 })
-- rib valley lines
fan:each(function(x, y)
  local q = ribs[K(x, y)]
  if q and q.ph < 0.1 and q.r > NR and q.r < q.edge - 1 then c:px(x, y, PINK[2]) end
end)
-- ears
for _, s in ipairs{ -1, 1 } do
  c:fillMask(c:poly{ {HX + s * 10, HY - 3}, {HX + s * 15, HY - 1}, {HX + s * 12, HY + 3} }, PINK[s < 0 and 4 or 2])
end
-- hinge shading + pearl
for x = HX - 6, HX + 6 do c:px(x, HY + 3, PINK[1]) end
c:fillMask(c:ellipse(HX, HY, 3, 3), PEARL[2])
c:px(HX + 1, HY + 1, PEARL[1]) c:px(HX + 2, HY, PEARL[1]) c:px(HX - 1, HY - 1, PEARL[3]) c:px(HX - 2, HY - 1, PEARL[3])
-- highlight streak on upper-left valve, barnacles
for i = 0, 5 do c:px(20 + i, 27 - i, PINK[6]) end
c:px(21, 26, PINK[6]) c:px(44, 38, PEARL[2]) c:px(45, 38, PEARL[3]) c:px(44, 39, PEARL[1]) c:px(40, 22, PEARL[2]) c:px(40, 23, PEARL[1])
G.fin(c, "tide-shell")
