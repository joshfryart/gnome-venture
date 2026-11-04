-- wishing-well (lean D3o_13)
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wishing-well" }
local ROOF = { "#3a1a2e", "#5e2a3e", "#8a3e4a", "#b45a52", "#da7e62", "#f4a87a" }
c:groundShadow(32, 56, 20, 3)
-- stone drum
local drum = HP.mask()
for y = 38, 55 do local h = 15 - (y > 52 and (y - 52) or 0) for x = 32 - h, 32 + h do drum:set(x, y) end end
local dn = X.pillow(drum, 14)
G.tone(c, drum, X.light(dn, { amb = 0.12, wrap = 0.3 }), STONE, CUTS)
-- brick courses
for r = 0, 3 do
  local y = 41 + r * 4
  for x = 17, 47 do if drum:has(x, y) then c:px(x, y, STONE[2]) end end
  for x = 18 + (r % 2) * 3, 46, 6 do for yy = y - 3, y - 1 do if drum:has(x, yy) then c:px(x, yy, STONE[2]) end end end
end
-- rim ellipse + dark water
local rim = c:ellipse(32, 38, 15, 4)
sh(c, rim, STONE, 5)
local water = c:ellipse(32, 38, 12, 2)
G.tone(c, water, X.light(X.pillow(water, 3), { amb = 0.2, wrap = 0.3 }), { "#142a4a", "#1e4a7a", "#2e78a8", "#58a8cc", "#94d4e4", "#e0fafa" }, CUTS)
c:px(28, 38, "#fff6f2") c:px(29, 38, "#fff6f2")
-- QUIRK: wishing coin glint
c:px(36, 39, "#ffe070") c:px(37, 39, "#d09a30")
-- posts
sh(c, c:rect(20, 18, 23, 38), WOOD, 1.8)
sh(c, c:rect(41, 18, 44, 38), WOOD, 1.8)
-- crank beam + rope + bucket
sh(c, c:rect(21, 24, 43, 26), WOOD, 1.2)
c:fillMask(c:rect(36, 24, 38, 26), WOOD[1]) c:px(39, 25, COPPER[5]) c:px(40, 25, COPPER[5]) c:px(41, 25, COPPER[3])
G.line(c, { {30,26}, {30,31} }, "#c8b890")
local bk = c:poly{ {27,31}, {33,31}, {32,36}, {28,36} }
sh(c, bk, WOOD, 2)
c:fillMask(c:rect(27, 31, 33, 31), COPPER[3]) c:fillMask(c:rect(28, 34, 32, 34), COPPER[2])
-- peaked shingle roof
local roof = c:poly{ {32,4}, {50,16}, {52,19}, {12,19}, {14,16} }
local rn = X.pillow(roof, 8)
G.tone(c, roof, X.light(rn, { amb = 0.15, wrap = 0.3 }), ROOF, CUTS)
for r = 0, 3 do for x = 14, 50, 4 do local y = 9 + r * 3 if roof:has(x + (r % 2) * 2, y) then c:px(x + (r % 2) * 2, y, ROOF[1]) c:px(x + (r % 2) * 2, y + 1, ROOF[1]) end end end
G.line(c, { {14,19}, {50,19} }, ROOF[1])
c:px(32, 3, ROOF[6]) c:px(31, 8, ROOF[6])
G.fin(c, "wishing-well")
