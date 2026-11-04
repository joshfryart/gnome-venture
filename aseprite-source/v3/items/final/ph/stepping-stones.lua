-- stepping-stones (lean D2o_12)
-- A winding path of four flat stones (slate, sandstone, granite) with thick sides, grass tufts, moss, and a tiny daisy.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local sin, cos, pi, abs, floor, max, min, sqrt, atan2 = math.sin, math.cos, math.pi, math.abs, math.floor, math.max, math.min, math.sqrt, math.atan
local function solid(c, m, ramp, R, amb) local n = X.pillow(m, R) local idx = G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp) return n, idx end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stepping-stones" }
local GR = { "#1f4a3a", "#2f6b46", "#4f9450", "#7cb55e", "#a9d078" }
local R1 = { "#3d3a4d", "#5b576b", "#7d788a", "#a29da9", "#c9c4c8", "#e9e4dc" }
local R2 = { "#5a4a45", "#7d675c", "#a08777", "#c4a995", "#e2cdb8", "#f3e6d2" }
local R3 = { "#34415a", "#4d5f7c", "#6c82a2", "#8fa5c2", "#b4c7dc", "#dae6f2" }
local function stone(cx, cy, rx, ry, th, R)
  local top = c:ellipse(cx, cy, rx, ry)
  local side = c:ellipse(cx, cy + th, rx, ry):cut(top)
  c:fillMask(side, R[2])
  side:each(function(x, y) if not side:has(x, y + 1) then c:px(x, y, R[1]) end end)
  for x = floor(cx - rx), floor(cx + rx) do if side:has(x, floor(cy + th + ry - 1)) then end end
  local n = X.pillow(top, ry + 3)
  local v = X.light(n, { amb = 0.12, wrap = 0.3 })
  G.tone(c, top, v, R)
  top:each(function(x, y) local h = X.hash(x, y, floor(cx)) if h > 0.93 then c:px(x, y, R[2]) elseif h < 0.04 then c:px(x, y, R[5]) end end)
  return top, side
end
local function tuft(bx, by, h)
  for i, d in ipairs{ -2, 0, 2 } do
    G.line(c, { {bx, by}, {bx + d, by - h + (i == 2 and 0 or 2)} }, GR[i == 2 and 4 or 3])
    c:px(bx + d, by - h + (i == 2 and 0 or 2), GR[5])
  end
  c:px(bx, by, GR[1])
end
tuft(34, 21, 5)
local s1 = stone(46, 15, 9, 5, 3, R2)
local s2, sd2 = stone(24, 27, 11, 6, 3, R1)
local s3 = stone(43, 40, 10, 5, 3, R3)
local s4 = stone(21, 51, 9, 4.5, 3, R2)
tuft(29, 44, 6) tuft(52, 31, 5)
-- cracks and moss
G.line(c, { {42, 13}, {45, 15}, {44, 17} }, R2[1])
G.line(c, { {20, 25}, {23, 27}, {22, 30} }, R1[1])
G.line(c, { {40, 39}, {43, 41} }, R3[1])
for _, p in ipairs{ {15, 28}, {16, 29}, {15, 30}, {16, 31}, {17, 31}, {16, 27} } do if s2:has(p[1], p[2]) then c:px(p[1], p[2], GR[3]) end end
for _, p in ipairs{ {14, 53}, {15, 54}, {16, 55}, {14, 52} } do c:px(p[1], p[2], GR[2]) end
c:px(15, 29, GR[5]) c:px(17, 31, GR[4])
-- quirk: little daisy
G.line(c, { {8, 46}, {8, 40} }, GR[3]) c:px(9, 44, GR[4]) c:px(10, 43, GR[4]) c:px(7, 46, GR[2])
for _, d in ipairs{ {-2, 0}, {2, 0}, {0, -2}, {0, 2}, {-1, -1}, {1, -1}, {-1, 1}, {1, 1} } do c:px(8 + d[1], 38 + d[2], "#fff8ea") end
c:px(8, 38, "#f5c842")
G.fin(c, "stepping-stones")
