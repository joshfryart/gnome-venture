local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- ico-worm: fat pink worm on a soil clod, S curve, smile, one dewdrop. quirk: wears a tiny green leaf as a sunhat.
local c = D.new("ico-worm")
local PK = { "#7d2c5e", "#b04a70", "#d9648a", "#f08aa4", "#ffaabd", "#ffd0dc" }
c:groundShadow(32, 54, 18, 2)
local clod = c:ellipse(32, 50, 18, 5):add(c:ellipse(26, 47, 8, 5))
D.lit(clod, D.BRN, 3)
for _, p in ipairs{{20,51},{27,53},{38,50},{44,52},{33,48}} do c:px(p[1], p[2], "#3a2030") end
local m, T = H.sweep({{14,46},{22,26},{40,52},{48,24}}, function(t) return 3.6 - t*0.6 end, 90)
D.lit(m, PK, 3.2)
m:each(function(x, y) local t = T[B.K(x, y)] or 0 if floor(t*22) % 2 == 0 and t > .25 then c:px(x, y, PK[3]) end end)
local band = HP.mask() m:each(function(x,y) local t = T[B.K(x,y)] or 0 if t>.18 and t<.28 then band:set(x,y) end end)
band:each(function(x,y) c:px(x,y,"#f4c0a0") end)
-- head end near (48,24): eyes and smile
c:eyeSmall(46, 22) c:eyeSmall(51, 21)
c:px(47,27,"#7d2c5e") c:px(48,28,"#7d2c5e") c:px(49,28,"#7d2c5e") c:px(50,27,"#7d2c5e")
-- hat leaf
D.lf(46, 17, 5, 2, -0.3, D.LEAF)
c:px(41,22,"#b6f0e0") c:px(41,23,"#5fc4c8")
D.fin()
