-- scarab-shell (lean P1b_O8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "scarab-shell" }
local EL  = { "#0d2a4a", "#12507a", "#1a7f94", "#27ae9a", "#6fd8a8", "#d4f7b0" }
local GLD = { "#5a3a10", "#9a6a18", "#d09a28", "#f4cc50", "#fff0a0" }
local PRO = { "#1a1840", "#2d2f72", "#3e57a8", "#5e8ad0", "#98c0f0", "#d8ecff" }
local LEG = { "#14102a", "#2b2350", "#46407a", "#6c64a0" }
-- legs first (behind)
local function leg(pts, w)
  local m, n = G.tube(pts, function(t) return w * (1 - 0.4 * t) end)
  G.toneN(c, m, n, LEG, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
end
leg({ {24,26}, {14,22}, {9,24}, {7,32} }, 1.8)
leg({ {22,36}, {11,36}, {6,42}, {7,50} }, 1.8)
leg({ {24,46}, {14,50}, {12,56}, {17,60} }, 1.8)
leg({ {40,26}, {50,22}, {55,24}, {57,32} }, 1.8)
leg({ {42,36}, {53,36}, {58,42}, {57,50} }, 1.8)
leg({ {40,46}, {50,50}, {52,56}, {47,60} }, 1.8)
-- head + horn
local hm, hn = G.oval(32, 11, 6, 4.2, 0, 1.2)
G.toneN(c, hm, hn, PRO, { amb = 0.1, wrap = 0.25 })
local horn = HP.mask() horn:add(c:poly{ {30,8}, {32,3}, {34,8} })
G.toneN(c, horn, X.pillow(horn, 2.5), GLD, { amb = 0.2, wrap = 0.3, cuts = { 0.3, 0.55, 0.8, 0.95 } })
c:px(32, 4, GLD[5])
-- elytra: two halves
local W = HP.mask() W:add(c:ellipse(32, 38, 15.5, 20))
local wn = X.pillow(W, 14)
local L, R = HP.mask(), HP.mask()
W:each(function(x, y) if x < 32 then L:set(x, y) else R:set(x, y) end end)
G.toneN(c, L, wn, EL, { amb = 0.1, wrap = 0.2 })
G.toneN(c, R, wn, EL, { amb = 0.05, wrap = 0.15, bias = (function() local b = {} R:each(function(x, y) b[K(x, y)] = -0.5 end) return b end)() })
-- seam
for y = 20, 58 do if W:has(31, y) then c:px(31, y, EL[1]) end if W:has(32, y) then c:px(32, y, EL[2]) end end
-- striae (grooves)
for _, gx in ipairs{ 25, 38, 20, 43 } do
  for y = 24, 56 do
    local inside = W:has(gx, y) and W:has(gx, y - 2)
    if inside and (y % 4 ~= 0) then c:px(gx, y, EL[2]) end
  end
end
-- gold iridescent sheen upper-left
for _, p in ipairs{ {22,26},{23,25},{24,24},{21,28},{20,30},{22,29},{23,27},{24,26},{26,24},{27,23} } do c:px(p[1], p[2], GLD[3 + (p[1] + p[2]) % 2]) end
c:px(21, 27, GLD[5]) c:px(22, 26, GLD[5])
-- violet bounce lower right
for _, p in ipairs{ {44,48},{43,50},{41,53},{39,55},{45,44},{46,40} } do if W:has(p[1], p[2]) then c:px(p[1], p[2], PRO[4]) end end
-- pronotum
local pm = HP.mask() pm:add(c:ellipse(32, 20, 11, 5.2))
G.toneN(c, pm, X.pillow(pm, 6), PRO, { amb = 0.08, wrap = 0.25 })
c:px(27, 18, PRO[6]) c:px(28, 18, PRO[6]) c:px(26, 19, PRO[5])
-- quirk: a chipped hole in the shell shows the hollow dark inside
local hole = HP.mask() hole:add(c:poly{ {38,44}, {43,42}, {46,46}, {43,50}, {39,49} })
hole:clip(W)
c:fillMask(hole, "#0a0a1c")
for _, p in ipairs{ {39,44},{40,43},{41,43} } do c:px(p[1], p[2], EL[5]) end
c:px(44, 46, "#1a1a3a") c:px(42, 47, "#1a1a3a")
c:sparkle(50, 12)
G.save(c, "scarab-shell")
