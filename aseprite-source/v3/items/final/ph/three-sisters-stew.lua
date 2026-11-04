-- three-sisters-stew (lean D3o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function clampi(i, a, b) if not b then a, b = 1, a end return max(a, min(b, i)) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "three-sisters-stew" }
local IRON = { "#1c1a26", "#2f2c3e", "#47445a", "#66627a", "#8a869c", "#b8b4c8" }
local BROTH = { "#6a2c18", "#8a3c1e", "#b0562a", "#cc7430" }
local SQ = { "#8a3a10", "#d9731c", "#f4a43c", "#ffd079" }
c:groundShadow(32, 57, 20, 2)
-- legs
for _, pl in ipairs{ { {18,47}, {24,47}, {22,56}, {19,56} }, { {40,47}, {46,47}, {45,56}, {42,56} }, { {29,50}, {35,50}, {34,58}, {30,58} } } do
  local m = c:poly(pl)
  G.tone(c, m, X.light(X.pillow(m, 3), { amb = 0.1, wrap = 0.3 }), IRON, { 0.25, 0.45, 0.65, 0.85 })
end
-- body
local body = c:ellipse(32, 40, 18, 15):cut(c:rect(0, 0, 63, 33))
local rimE = c:ellipse(32, 34, 19, 5)
local bn = X.pillow(body:copy():add(rimE), 11)
local bv = X.light(bn, { amb = 0.08, wrap = 0.25 })
G.tone(c, body, bv, IRON, { 0.22, 0.4, 0.58, 0.74, 0.9 })
G.tone(c, rimE, bv, IRON, { 0.08, 0.2, 0.34, 0.5, 0.7 })
for y = 40, 47 do c:px(19, y, IRON[6]) c:px(20, y, IRON[5]) end
for _, x in ipairs{ 22, 27, 32, 37, 42 } do c:px(x, 43, IRON[2]) c:px(x - 1, 42, IRON[5]) end
-- stew
local st = c:ellipse(32, 34, 16, 3.5)
local sv = X.light(X.pillow(st, 6), { amb = 0.3, wrap = 0.4 })
G.tone(c, st, sv, BROTH, { 0.3, 0.55, 0.8 })
st:each(function(x, y) if y <= 31 then c:px(x, y, BROTH[1]) end end)
local function cube(x, y)
  c:rect(x, y, x + 2, y + 2):each(function(px, py) c:px(px, py, SQ[2]) end)
  c:px(x, y, SQ[4]) c:px(x + 1, y, SQ[3]) c:px(x, y + 1, SQ[3]) c:px(x + 2, y + 2, SQ[1]) c:px(x + 1, y + 2, SQ[1])
end
cube(23, 33) cube(35, 34) cube(40, 32)
for _, p in ipairs{ {28,35}, {32,32}, {38,36}, {26,32}, {43,35}, {20,34} } do
  c:px(p[1], p[2], "#f6d548") c:px(p[1] + 1, p[2], "#d9a824") c:px(p[1], p[2] + 1, "#d9a824") c:px(p[1], p[2], "#fff09a")
end
for _, p in ipairs{ { {29,33}, {31,34}, {32,34} }, { {36,32}, {38,33}, {39,32} } } do
  c:line(p, 1):each(function(x, y) c:px(x, y, "#5ba04c") end)
  c:px(p[1][1], p[1][2], "#9ccd6c")
end
-- lugs + bail
for _, x in ipairs{ 11, 51 } do
  c:rect(x, 32, x + 2, 36):each(function(px, py) c:px(px, py, IRON[3]) end)
  c:px(x, 32, IRON[5]) c:px(x + 1, 32, IRON[4])
end
local pts = {}
for i = 0, 16 do local th = pi * i / 16 pts[#pts + 1] = { 32 - 20 * cos(th), 34 - 20 * sin(th) } end
local bail = c:line(pts, 1)
bail:add(bail:copy():shift(1, 0)):each(function(x, y)
  if y > 33 and (x == 12 or x == 13 or x == 51 or x == 52) then return end
  local lit = (x - 32) + (y - 14) * 0.4 < 8
  c:px(x, y, lit and IRON[5] or IRON[3])
end)
-- steam, with a little heart curl (quirk)
local WS = "#e0e6f0"
c:line({ {26,29}, {25,26}, {27,23}, {26,20}, {28,17} }, 1):each(function(x, y) c:px(x, y, WS) end)
c:line({ {33,29}, {34,26}, {32,23}, {33,20}, {31,18} }, 1):each(function(x, y) c:px(x, y, "#c0c8dc") end)
c:line({ {39,29}, {38,26}, {40,23}, {39,20} }, 1):each(function(x, y) c:px(x, y, WS) end)
G.fin(c, "three-sisters-stew")
