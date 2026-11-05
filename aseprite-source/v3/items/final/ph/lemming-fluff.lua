-- lemming-fluff (lean P1b_O3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local function dot(c, x, y, h) c:px(x, y, h) end
local c = HP.canvas{ w=64, h=64, scale=1, name="lemming-fluff" }
local FUR = { "#4a2c1e", "#7a4a2a", "#b0763a", "#d89a4c", "#f0c070", "#fff0c0" }
local DK = { "#16100e", "#2e1e18", "#4a3026", "#6a4838" }
c:groundShadow(32, 52, 18, 3)
local body = HP.mask()
body:add(c:ellipse(32, 33, 17, 15))
for i = 0, 15 do local a = i / 16 * pi * 2 local x, y = 32 + cos(a) * 18, 33 + sin(a) * 16
  body:add(c:poly{ {floor(x + 0.5) - 3, floor(y + 0.5) + 2}, {floor(x + 0.5) + 3, floor(y + 0.5) - 2}, {floor(32 + cos(a) * 23 + 0.5), floor(33 + sin(a) * 21 + 0.5)} }) end
local bias = {}
body:each(function(x, y) local h = X.hash(floor(x / 2), floor(y / 2), 7) if h > 0.75 then bias[K(x, y)] = 1 elseif h < 0.25 then bias[K(x, y)] = -1 end end)
G.toneN(c, body, X.pillow(body, 12), FUR, { bias = bias, cuts = {0.2,0.38,0.55,0.72,0.88} })
-- fur strands
body:each(function(x, y) if (x + y * 2) % 5 == 0 and X.hash(x, y, 4) > 0.45 then local k = K(x, y) c:px(x, y, FUR[2]) end end)
-- dark dorsal stripe patch (lemming marking)
local st = HP.mask() st:add(c:ellipse(30, 25, 7, 9)) st:clip(body)
G.toneN(c, st, X.pillow(st, 6), DK)
st:each(function(x, y) if (x + y) % 4 == 0 then c:px(x, y, DK[1]) end end)
-- face: tiny nose + eyes peeking
c:fillMask(c:ellipse(40, 40, 2, 1), "#e8708a") c:px(39, 39, "#ffc0cc")
c:fillMask(c:rect(35, 34, 36, 35), DK[1]) c:fillMask(c:rect(44, 34, 45, 35), DK[1]) c:px(35, 34, "#ffffff") c:px(44, 34, "#ffffff")
-- highlight tufts
c:fillMask(c:rect(22, 22, 25, 23), FUR[6]) c:px(21, 24, FUR[5]) c:px(26, 21, FUR[5])
-- quirk: one stray curl strand on top
c:line({{32,15},{33,11},{36,9},{38,11}}, 1):each(function(x, y) c:px(x, y, FUR[5]) end)
G.save(c, "lemming-fluff")
