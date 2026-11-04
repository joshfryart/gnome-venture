-- silk-net (lean D2o_0)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c
local function shade(m, ramp, R, o) local n = X.pillow(m, R) return G.toneN(c, m, n, ramp, o), n end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "silk-net" }
local WOOD = { "#2f1d1a", "#4d2f26", "#6e4533", "#91603f", "#b98456", "#dcad76" }
local SILK = { "#4a4c80", "#6a6fa6", "#8f93c4", "#b7bbe0", "#dcdff3", "#f2f3ff" }
local GOLD = { "#6b3c14", "#98591a", "#c98524", "#eaaa2f", "#f9cf55", "#fff0a0" }
-- handle (slim, diagonal) with gold ferrule at the hoop end
local hm, hn, T = G.tube({ {35, 30}, {41, 40}, {47, 49}, {53, 58} }, function(t) return 1.8 end)
local fer, wd = HP.mask(), HP.mask()
hm:each(function(x, y) if T[K(x, y)] < 0.15 then fer:set(x, y) else wd:set(x, y) end end)
G.toneN(c, wd, hn, WOOD)
G.toneN(c, fer, hn, GOLD)
wd:each(function(x, y) if X.hash(x, y, 3) > 0.9 then c:px(x, y, WOOD[2]) elseif X.hash(x, y, 8) > 0.93 then c:px(x, y, WOOD[5]) end end)
-- silk bag hanging through the hoop
local inner = c:ellipse(26, 22, 10, 9)
local bag = inner:copy():add(c:ellipse(26, 30, 10, 16):clip(c:rect(0, 22, 63, 63)))
shade(bag, SILK, 7)
local bn = X.pillow(bag, 7)
local l = X.light(bn, { amb = 0.08, wrap = 0.25 })
bag:each(function(x, y)
  if (x + y) % 4 == 0 or (x - y) % 4 == 0 then
    c:px(x, y, (l[K(x, y)] or 0) > 0.5 and SILK[6] or SILK[4])
  end
end)
-- quirk: dangling thread with a gold bead
c:px(26, 47, SILK[3]) c:px(26, 48, SILK[3]) c:fillMask(c:rect(25, 49, 26, 50), GOLD[4]) c:px(25, 49, GOLD[6]) c:px(26, 50, GOLD[2])
-- hoop
local ring = c:ellipse(26, 22, 13, 12):cut(inner)
local _, n2 = shade(ring, WOOD, 2.4)
local sx, sy = G.specAt(ring, n2, 30)
c:px(sx, sy, "#fff0d0")
G.save(c, "silk-net")
