-- wind-chime (lean D3o_13)
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wind-chime" }
-- hanging cord + ring
G.line(c, { {32,5}, {32,12} }, "#c8b890") c:px(31,5,"#e8dcb0")
local ring = c:ellipse(32, 6, 2, 2) c:px(32,4,"#a89868")
-- round wooden top disc
local top = c:ellipse(32, 14, 15, 3)
sh(c, top, WOOD, 3)
for x = 20, 44, 4 do c:px(x, 14, WOOD[2]) end
-- strings
local lens = { {19,31}, {25,39}, {32,26}, {39,44}, {45,34} }
local rampM = { "#1f3a4a", "#2e5a6a", "#4a8a94", "#7cbcb8", "#b4e4d0", "#f0fff0" }
for i, L in ipairs(lens) do
  local x, len = L[1], L[2]
  G.line(c, { {x,16}, {x,19} }, "#c8b890")
  local tube = c:rect(x - 1, 19, x + 1, 19 + len - 12)
  sh(c, tube, i % 2 == 0 and rampM or COPPER, 1.6)
  c:px(x - 1, 21, "#fff6e0")
  c:fillMask(c:rect(x - 1, 19 + len - 12, x + 1, 19 + len - 12), i % 2 == 0 and rampM[1] or COPPER[1])
end
-- clapper centre + wind sail
G.line(c, { {32,17}, {32,36} }, "#c8b890")
local clap = c:ellipse(32, 38, 3, 3)
sh(c, clap, WOOD, 2)
G.line(c, { {32,41}, {32,46} }, "#c8b890")
-- sail: leaf-shaped wood catcher with cut-out star (quirk)
local sail = blade(32, 46, 27, 52, 32, 59, function(t) return 4.2 * sin(pi * t) ^ 0.8 end)
sh(c, sail, WOOD, 3)
c:px(32, 52, "#ffe9a0") c:px(31, 52, "#ffe9a0") c:px(32, 51, "#ffe9a0") c:px(32, 53, "#ffe9a0") c:px(33, 52, "#ffe9a0")
G.fin(c, "wind-chime")
