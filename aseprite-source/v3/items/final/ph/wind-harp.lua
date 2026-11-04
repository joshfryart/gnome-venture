-- wind-harp (lean D3o_13)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local function blade(ax, ay, cx, cy, bx, by, wf) return (G.tube({ {ax,ay}, {cx,cy}, {cx,cy}, {bx,by} }, wf)) end
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local WOOD = { "#2e1d1f", "#4b2e2a", "#6e4330", "#93603b", "#b98650", "#dcb36f" }
local COPPER = { "#3a2230", "#6a3a35", "#a05a3a", "#d08a48", "#efb964", "#fff0a8" }
local STONE = { "#2f3040", "#4a4a5e", "#6a6a7c", "#8d8d98", "#b2b0b4", "#d8d4d0" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local function sh(c, m, ramp, R, amb) local n = X.pillow(m, R or 3) G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wind-harp" }
-- slim feet
for _, x in ipairs{ 18, 44 } do sh(c, c:rect(x, 46, x + 2, 55), WOOD, 1.5) end
-- soundbox: a long tapered trapezoid box lying slightly tilted
local box = c:poly{ {10,40}, {54,34}, {54,46}, {10,46} }
sh(c, box, WOOD, 5)
for x = 14, 52, 6 do c:px(x, 43, WOOD[2]) c:px(x + 1, 41, WOOD[5]) end
-- sound hole
local hole = c:ellipse(32, 42, 3, 2)
c:fillMask(hole, WOOD[1]) c:fillMask(c:ellipse(32, 42, 2, 1), "#120a10") c:px(30, 41, WOOD[3])
-- bridges
local br = c:poly{ {12,40}, {14,40}, {14,38}, {12,38} }
-- tuning posts / upper rail
local rail = c:poly{ {10,20}, {54,12}, {54,15}, {10,23} }
sh(c, rail, WOOD, 2)
for x = 14, 50, 6 do c:px(x, 21 - floor((x - 10) * 0.18), WOOD[6]) end
-- end posts joining rail and box
sh(c, c:rect(10, 22, 12, 40), WOOD, 1.5)
sh(c, c:rect(52, 14, 54, 35), WOOD, 1.5)
-- strings, slightly varying brightness; one is vibrating (quirk)
local S1, S2 = "#f4ecd0", "#c9bd96"
for i = 0, 7 do
  local x = 15 + i * 5
  local yt = 22 - floor((x - 10) * 0.18)
  local yb = 40 - floor((x - 10) * 0.136)
  for y = yt + 2, yb - 1 do
    local off = 0
    if i == 4 then off = floor(sin((y - yt) * 0.55) * 1.2 + 0.5) end
    c:px(x + off, y, (i % 2 == 0) and S1 or S2)
  end
  c:px(x, yb, WOOD[1])
end
-- wind swirl
G.line(c, { {2,12}, {6,10}, {10,10}, {12,8}, {11,6} }, "#b4dcf0")
G.line(c, { {3,56}, {7,58}, {13,58}, {15,60}, {13,62} }, "#b4dcf0")
G.fin(c, "wind-harp")
