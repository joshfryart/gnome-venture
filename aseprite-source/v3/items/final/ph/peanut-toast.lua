-- peanut-toast (lean W2_12)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "peanut-toast" }
local CR = { "#4a2a17", "#6e3f1e", "#955a28", "#b97a38", "#d89c52", "#efc17c" }
local BR = { "#8e5a2a", "#b87d38", "#d9a152", "#efc67a", "#f9e0a2", "#fff1c6" }
local PB = { "#6a3d1c", "#8c5524", "#ad7030", "#cb8f42", "#e0ab5a", "#f1c982" }
local cuts = { 0.22, 0.4, 0.56, 0.72, 0.87 }
c:groundShadow(32, 54, 18, 2)
local slice = HP.mask()
slice:add(c:rect(14, 20, 50, 51)):add(c:ellipse(22, 21, 9, 6)):add(c:ellipse(42, 21, 9, 6)):add(c:rect(14, 22, 50, 22))
slice:cut(c:rect(10, 14, 20, 17))
-- corners rounded
for _, p in ipairs{ {14,51},{15,51},{14,50},{50,51},{49,51},{50,50} } do slice:cut(HP.mask():add(c:rect(p[1],p[2],p[1],p[2]))) end
-- bite from upper right
local bite = HP.mask():add(c:ellipse(51, 24, 4, 3)):add(c:ellipse(47, 20, 3, 3)):add(c:ellipse(53, 30, 3, 3))
slice:cut(bite)
local n = X.pillow(slice, 5)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
local crust = slice:copy():cut(slice:copy():shrink(3))
local crumb = slice:copy():shrink(3)
G.tone(c, crust, v, CR, cuts)
G.tone(c, crumb, v, BR, cuts)
-- pores in crumb
crumb:shrink(2):each(function(x, y) if X.hash(x, y, 5) > 0.93 then c:px(x, y, BR[1]) end end)
-- peanut butter spread: ragged blob, knife swirls
local pb = HP.mask():add(c:ellipse(31, 37, 13, 10)):add(c:ellipse(25, 31, 6, 4)):add(c:ellipse(37, 44, 6, 3))
pb:each(function(x, y) if X.hash(x, y, 2) > 0.9 and pb:copy():shrink(1):has(x, y) == false then pb:cut(HP.mask():add(c:rect(x,y,x,y))) end end)
local pbm = pb:copy():clip(crumb)
local pn = X.pillow(pbm, 6)
G.tone(c, pbm, X.light(pn, { amb = 0.12, wrap = 0.3 }), PB, cuts)
for i = 0, 3 do
  local y = 30 + i * 4
  G.line(c, { {22 + i, y}, {28, y - 1}, {34, y}, {40 - i, y - 1} }, PB[2])
  G.line(c, { {23 + i, y - 1}, {28, y - 2}, {34, y - 1} }, PB[5])
end
c:px(25, 29, PB[6]) c:px(26, 29, PB[6]) c:px(24, 30, PB[6])
-- drip over left crust
local drip = HP.mask():add(c:rect(13, 34, 15, 44)):add(c:ellipse(14, 46, 2, 2))
G.tone(c, drip, X.light(X.pillow(drip, 2), { amb = 0.15, wrap = 0.3 }), PB, cuts)
-- quirk: lone peanut at lower right
local pnut = HP.mask():add(c:ellipse(52, 54, 3, 2)):add(c:ellipse(56, 52, 2, 2))
G.tone(c, pnut, X.light(X.pillow(pnut, 2), { amb = 0.2, wrap = 0.3 }), CR, cuts)
c:px(51, 53, CR[6])
G.fin(c, "peanut-toast")
