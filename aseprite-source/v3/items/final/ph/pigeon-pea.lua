-- pigeon-pea (lean P1b_O6)
local NAME = "pigeon-pea"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function line(pts, hex) c:line(pts, 1):each(function(x, y) c:px(x, y, hex) end) end
local function paint(m, ramp, R, o) o = o or {} local n = X.pillow(m, R) local _, v = G.toneN(c, m, n, ramp, o) return n, v end

local POD  = { "#2f4a1c", "#587f26", "#86ac32", "#b1ce4a", "#d6e47a", "#eef3b0" }
local LEAF = { "#17392c", "#1f5a34", "#2f7d3a", "#4a9c42", "#74bb4e", "#a3d664" }
local PEA  = { "#4e6a1e", "#7a9a2c", "#a4c043", "#c8dc6a", "#e6efa0" }
c:groundShadow(34, 58, 14, 2)
-- branch
local sm, sn = G.tube({ {58,5}, {52,4}, {38,13}, {27,26} }, function(t) return 1.5 - 0.3 * t end)
G.toneN(c, sm, sn, { "#2e1a10", "#5a3a22", "#8a5e36", "#b88a52" })
-- trifoliate leaf
local function lf(bx, by, cx, cy, w) local m, n = G.blade(27, 27, cx, cy, bx, by, function(t) return w * sin(pi * t) ^ 0.7 end, { fold = 0.3 })
  G.toneN(c, m, n, LEAF) line(c, { {27,27},{(27+bx)//2 + (cx-27)//4,(27+by)//2 + (cy-27)//4},{bx,by} }, LEAF[6]) end
lf(8, 28, 14, 34, 3.6)
lf(12, 6, 12, 22, 4.4)
lf(30, 8, 36, 20, 3.4)
-- pod hanging from branch
local N = 5
local pm, pn, T = G.tube({ {52,6}, {60,28}, {38,54}, {10,52} }, function(t)
  local taper = min(1, t * 9, (1 - t) * 4)
  return (3.3 + 1.5 * abs(sin(t * pi * N))) * max(0.15, taper) end)
local _, v = G.toneN(c, pm, pn, POD)
pm:each(function(x, y) local k = K(x, y) local t = T[k]
  if abs(sin(t * pi * N)) < 0.14 and t > 0.1 and t < 0.9 then c:px(x, y, POD[2]) end
  if X.hash(x, y, 5) > 0.84 and v[k] < 0.7 and t > 0.12 and t < 0.92 then c:px(x, y, "#8e2f4a") end
end)
c:px(52, 7, "#b88a52") c:px(53, 8, "#8a5e36")
-- seam highlight
pm:each(function(x, y) local k = K(x, y) if v[k] > 0.85 and X.hash(x, y, 2) > 0.45 then c:px(x, y, POD[6]) end end)
-- loose peas (quirk: one has sprouted a tiny root)
for _, p in ipairs{ {44,50,3.6}, {51,45,3.2}, {40,44,3.0} } do
  local m = c:ellipse(p[1], p[2], p[3], p[3])
  paint(m, PEA, 4, { amb = 0.15 })
  c:px(floor(p[1] - 1), floor(p[2] - 1), "#fffbe0")
end
c:px(44, 52, "#3a2a1a") c:px(45, 52, "#3a2a1a")
c:px(45, 54, "#e6efa0") c:px(46, 55, "#e6efa0") c:px(47, 55, "#c8dc6a")
G.save(c, NAME)
