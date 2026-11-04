-- lavender-border-cross (lean W2_7)
-- Plus-shaped raised wooden bed seen from slightly above: soil, five sage mounds each topped with purple spikes, a bee (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "lavender-border-cross" }
local WOOD = { "#3a2418", "#5a3a22", "#7e5430", "#a1713f", "#c28e55" }
local SOIL = { "#2c1c18", "#44291f", "#5e3a28" }
local SAGE = { "#2b4a42", "#42695a", "#6a917a", "#93b89b", "#c0d8b8" }
local PUR  = { "#3a2466", "#5a3a96", "#7c58b8", "#a483d4", "#d2b6ee" }
local STEM = { "#3e6b46", "#6a9a58" }
c:groundShadow(32, 56, 22, 3)
local function cross(dy)
  local m = HP.mask()
  m:add(c:rect(6, 36 + dy, 57, 47 + dy)) m:add(c:rect(24, 22 + dy, 39, 56 + dy - 4))
  return m
end
local top = cross(0)
local front = cross(4)
c:part(front, { WOOD[1], WOOD[2], WOOD[3], WOOD[4] })
-- wood grain on front face
front:each(function(x, y) if not top:has(x, y) and (x + y) % 5 == 0 then c:px(x, y, WOOD[1]) end end)
c:part(top, { WOOD[2], WOOD[3], WOOD[4], WOOD[5] })
top:each(function(x, y) if X.hash(x, y, 2) > 0.9 then c:px(x, y, WOOD[2]) end end)
local soil = top:copy():shrink(2)
soil:each(function(x, y) c:px(x, y, SOIL[1 + floor(X.hash(x, y, 8) * 2.99)]) end)
-- bolts
for _, p in ipairs{ {8,38},{55,38},{26,24},{37,24} } do c:px(p[1], p[2], WOOD[1]) c:px(p[1], p[2] - 1, WOOD[5]) end
local function mound(cx, cy, rx, ry)
  local mm, mn = G.oval(cx, cy, rx, ry, 0, 1.3)
  G.toneN(c, mm, mn, SAGE)
  for i = 1, 5 do local x, y = cx + floor((X.hash(i, cx, 4) - 0.5) * rx * 1.4), cy + floor((X.hash(i, cy, 6) - 0.5) * ry) if mm:has(x, y) then c:px(x, y, SAGE[5]) end end
end
local function spike(x, y, h)
  for yy = y, y - h + 4 do c:px(x, yy, (yy % 2 == 0) and STEM[2] or STEM[1]) end
  local yt = y - h + 3
  for i = 0, 4 do
    local yy = yt - i
    local w = (i == 4) and 0 or ((i % 2 == 0) and 1 or 0)
    for xx = x - w, x + w do c:px(xx, yy, PUR[(xx <= x and 4 or 3) - (i == 4 and 1 or 0) + (i % 2)]) end
    c:px(x + w + 1, yy, PUR[2])
  end
  c:px(x, yt - 5, PUR[5]) c:px(x - 1, yt - 2, PUR[5])
end
local M = { {32,28,6,4,{30,32,34},{9,11,8}}, {13,41,6,4,{11,14,16},{9,12,8}}, {51,41,6,4,{49,51,54},{9,11,8}}, {32,41,6,4,{30,33,35},{9,12,10}}, {32,50,6,3,{30,33,35},{8,10,8}} }
for _, M1 in ipairs(M) do
  mound(M1[1], M1[2], M1[3], M1[4])
  for i, sx in ipairs(M1[5]) do spike(sx, M1[2] - 1, M1[6][i]) end
end
-- bee (quirk)
c:px(44, 31, "#f2c14a") c:px(45, 31, "#2b1c26") c:px(46, 31, "#f2c14a") c:px(47, 31, "#2b1c26") c:px(48, 31, "#f2c14a")
c:px(45, 30, "#e8f4ff") c:px(46, 29, "#e8f4ff") c:px(47, 30, "#e8f4ff") c:px(44, 30, "#e8f4ff")
G.save(c, "lavender-border-cross")
