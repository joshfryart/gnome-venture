-- wing-dust (lean D3o_13)
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wing-dust" }
local GL = { "#3a5a7a", "#5c88aa", "#8cbcd0", "#bce4ea", "#e0f6f4", "#fff6f2" }
local DUST = { "#5a3a8a", "#8a5ac0", "#c07ae0", "#e8a0e8", "#9ad8f0", "#fff0a0" }
c:groundShadow(32, 56, 17, 3)
-- spilled dune in front
local dune = HP.mask()
for y = 46, 55 do local h = 5 + (y - 46) * 1.8 for x = floor(34 - h), floor(34 + h) do dune:set(x, y) end end
dune = dune:copy()
local dn = X.pillow(dune, 5)
local dv = X.light(dn, { amb = 0.1, wrap = 0.3 })
G.tone(c, dune, dv, { "#4a3a7a", "#6a52a0", "#8a6ac0", "#aa86d8", "#c8a6ea", "#e8ccf6" }, CUTS)
dune:each(function(x, y) local h = X.hash(x, y, 5)
  if h > 0.88 then c:px(x, y, DUST[6]) elseif h > 0.8 then c:px(x, y, DUST[5]) elseif h > 0.74 then c:px(x, y, DUST[4]) end end)
-- tilted jar (glass) lying on its side, mouth to the lower-right
local jar = c:poly{ {10,22}, {32,12}, {44,30}, {22,42} }
sh(c, jar, GL, 6, 0.25)
-- dust inside jar
local inner = c:poly{ {14,25}, {32,17}, {41,31}, {23,38} }
inner = inner:copy():shrink(0)
G.tone(c, inner, X.light(X.pillow(inner, 5), { amb = 0.2, wrap = 0.3 }), DUST, CUTS)
inner:each(function(x, y) local h = X.hash(x, y, 9) if h > 0.9 then c:px(x, y, DUST[6]) elseif h > 0.82 then c:px(x, y, DUST[5]) end end)
-- cork neck
local neck = c:poly{ {40,24}, {47,28}, {49,34}, {42,36} }
sh(c, neck, GL, 2, 0.25)
local cork = c:poly{ {47,27}, {52,31}, {49,37}, {46,34} }
sh(c, cork, WOOD, 2)
c:px(49, 30, WOOD[6])
-- glass rim glints
G.line(c, { {12,22}, {30,14} }, GL[6])
c:px(16, 36, GL[5])
-- QUIRK: a tiny wing scrap fluttering up out of the dust
local w = blade(26, 15, 22, 5, 16, 8, function(t) return 3 * sin(pi * t) ^ 0.7 end)
G.tone(c, w, X.light(X.pillow(w, 2), { amb = 0.2, wrap = 0.3 }), { "#6a3a9a", "#9a5ac8", "#c880e0", "#e8a8f0", "#f8d0fa", "#fff6f2" }, CUTS)
-- sparkles
c:sparkle(50, 14) c:sparkle(10, 50) c:sparkle(56, 48)
G.fin(c, "wing-dust")
