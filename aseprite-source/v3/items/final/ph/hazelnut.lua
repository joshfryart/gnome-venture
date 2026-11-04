-- hazelnut (lean W2_6)
local NAME = "hazelnut"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, R, ramp, amb, wrap)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = amb or 0.1, wrap = wrap or 0.25 })
  X.tone(c, m, v, ramp, { cuts = {.22,.4,.56,.72,.86} })
  return v, n
end
local c = HP.canvas{ w=64, h=64, scale=1, name=NAME }
local NUT = { "#4a2a1e", "#6f4126", "#93602f", "#b88142", "#d9a45a", "#f2cf8a" }
local HUSK = { "#1f4a2c", "#2e6a34", "#46903f", "#6bb34c", "#98d160", "#c6ea8a" }
local PALE = { "#8a6a44", "#b08e5a", "#d2b078", "#ecd49a", "#f8e8b8", "#fffadc" }
c:groundShadow(30, 54, 14, 2)
-- second nut behind-right (smaller), tilted
local n2 = HP.mask() n2:add(c:ellipse(43, 42, 8, 9))
shade(c, n2, 8, NUT)
c:px(40, 37, NUT[6]) c:px(41, 37, NUT[6])
-- main nut: round, slightly pointed tip
local nut = HP.mask() nut:add(c:ellipse(28, 39, 12, 13)):add(c:poly{ {22,48}, {34,48}, {28,54} })
local v = shade(c, nut, 11, NUT, 0.1, 0.25)
-- vertical grain streaks
nut:each(function(x, y) if y > 33 and (x*2 + floor(y/5)) % 5 == 0 and X.hash(x,y,3) > 0.45 then c:px(x, y, NUT[2]) end end)
-- pale base scar
local scar = HP.mask() scar:add(c:ellipse(28, 51, 5, 3)):clip(nut)
X.tone(c, scar, X.light(X.pillow(scar, 3), {amb=0.2, wrap=0.3}), PALE, { cuts = {.2,.4,.55,.7,.85} })
-- specular
c:px(21, 34, "#fff3d0") c:px(22, 33, "#fff3d0") c:px(21, 35, NUT[6]) c:px(23, 33, NUT[6])
-- husk: frilly leafy cap with torn fringe
local husk = HP.mask() husk:add(c:ellipse(28, 28, 14, 8)):cut(c:rect(0, 36, 63, 63))
for i = 0, 6 do local x = 16 + i*4.4; husk:add(c:ellipse(x, 34 + (i%2)*2, 3, 4)) end
shade(c, husk, 8, HUSK, 0.12, 0.3)
husk:each(function(x, y) if y < 33 and abs((x - 28) * 0.5 + y*0.3) % 3 < 0.5 and X.hash(x,y,7) > 0.3 then c:px(x, y, HUSK[2]) end end)
c:px(20, 24, HUSK[6]) c:px(21, 24, HUSK[6]) c:px(22, 23, HUSK[5])
-- stem + leaf
local st = G.tube({ {28,21}, {29,17}, {31,13}, {34,10} }, function(t) return 1.8 - 0.5*t end)
shade(c, st, 1.5, PALE)
local m = G.blade(33, 11, 40, 4, 48, 8, function(t) return 4.5 * sin(pi*min(1,t+0.08)) end)
shade(c, m, 3, HUSK)
m:each(function(x,y) if abs(y - (11 - (x-33)*0.45 + max(0,x-40)*0.3)) < 0.6 then c:px(x,y,HUSK[5]) end end)
-- quirk: tiny wormhole dot
c:px(33, 41, NUT[1]) c:px(34, 41, NUT[1])
G.save(c, NAME)
