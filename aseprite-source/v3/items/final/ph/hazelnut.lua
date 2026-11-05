-- hazelnut (lean P1b_O3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local function dot(c, x, y, h) c:px(x, y, h) end
local c = HP.canvas{ w=64, h=64, scale=1, name="hazelnut" }
local NUT = { "#3a1f14", "#5e3418", "#8a5424", "#b27a3a", "#d6a458", "#f0cf8a" }
local HUSK = { "#1d3a22", "#2c5a2c", "#44802f", "#6ba63a", "#96c84e", "#c4e47a" }
local TAN = { "#6a4a2a", "#a07a46", "#d2ae72", "#ecd39c" }
-- husk: ragged leafy cup behind, fringed edge
local husk = HP.mask()
husk:add(c:ellipse(30, 24, 15, 11))
for i = 0, 8 do local a = pi * (0.1 + i * 0.1) local x, y = 30 - cos(a) * 15 + 0, 24 - sin(a) * 11
  husk:add(c:ellipse(floor(x + 0.5), floor(y + 0.5), 3, 4)) end
for i = 0, 5 do local x = 17 + i * 5 husk:add(c:poly{{x-2,30},{x+2,30},{x+(i%2==0 and 0 or 1),38}}) end
shade(c, husk, 7, HUSK)
for i = 0, 5 do local x = 17 + i * 5 c:line({{x, 22},{x + (i%2==0 and -1 or 1), 33}}, 1):each(function(px, py) c:px(px, py, HUSK[2]) end) end
-- small nut at back right
local n2 = G.oval(43, 40, 8, 10, 0.5, 1)
shade(c, n2, 6, NUT)
-- main nut
local nut = G.oval(28, 38, 12, 14, -0.25, 1)
local idx = shade(c, nut, 8, NUT)
-- grain streaks
nut:each(function(x, y) if (x * 3 + y) % 7 == 0 and X.hash(x, y, 3) > 0.35 and y < 46 then c:px(x, y, NUT[2]) end end)
-- pale scar at base
local scar = G.oval(27, 49, 6, 2.5, 0, 1) scar:cut(c:rect(0,0,63,46))
scar:add(c:ellipse(27, 49, 6, 2)) scar:clip(nut)
shade(c, scar, 3, TAN)
-- tip + spec
c:px(34, 25, NUT[1]) c:px(33, 26, NUT[2])
c:fillMask(c:rect(21, 31, 23, 32), NUT[6]) c:px(24, 31, NUT[5]) c:px(20, 33, NUT[5])
-- quirk: tiny worm hole
c:fillMask(c:ellipse(33, 40, 1, 1), NUT[1]) c:px(32, 39, NUT[3])
G.save(c, "hazelnut")
