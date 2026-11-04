-- sundial (lean W2_32)
-- Stone pedestal with a verdigris bronze dial plate and a slim brass gnomon; quirk: a ladybird on the rim, moss on the plinth.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sundial" }
local abs, sin, cos, pi, floor = math.abs, math.sin, math.cos, math.pi, math.floor
local STONE = { "#3c3a54", "#5a5874", "#7e7c96", "#a4a2b6", "#c8c6d4", "#e8e6ee" }
local BRASS = { "#4a2c26", "#7c4a22", "#aa7222", "#d69c30", "#f2cc58", "#fff2a8" }
local VERD  = { "#26363a", "#3a5a54", "#5a8470", "#84aa8a", "#b0cca6", "#d8e8cc" }
local MOSS  = { "#2c5a34", "#478a40", "#74b450" }
local function shade(m, ramp, R, o, bias)
  local n = X.pillow(m, R)
  G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.25 }), ramp, nil, bias)
  return n
end
c:groundShadow(32, 57, 17, 2)
-- plinth steps
shade(c:rect(20, 52, 44, 55), STONE, 3)
shade(c:rect(24, 49, 40, 51), STONE, 2)
-- column
local cm, cn = X.cyl(32, 49, 32, 34, function(t) return 5.6 - 1.6 * t end)
G.tone(c, cm, X.light(cn, { amb = 0.1, wrap = 0.3 }), STONE)
for y = 36, 48 do c:px(31 + (y % 3 == 0 and 1 or 0), y, STONE[2]) end
for x = 28, 36 do c:px(x, 42, STONE[2]) end
cm:each(function(x, y) if x <= 29 and y >= 43 and X.hash(x, y, 5) > 0.45 then c:px(x, y, MOSS[1 + floor(X.hash(x, y, 9) * 2.99)]) end end)
for x = 23, 27 do if X.hash(x, 0, 3) > 0.3 then c:px(x, 52, MOSS[2]) c:px(x, 53, MOSS[1]) end end
-- collar
shade(c:rect(26, 33, 38, 35), STONE, 2)
-- dial plate: stone-dark underside, brass rim, verdigris face
local E1, E2 = c:ellipse(32, 30, 20, 7), c:ellipse(32, 30, 17, 5)
shade(c:ellipse(32, 32, 20, 7), STONE, 4, { amb = 0, wrap = 0.1 })
local rim = E1:copy():cut(E2)
shade(E1, BRASS, 4)
shade(E2, VERD, 6, { amb = 0.15, wrap = 0.5 })
for i = 0, 11 do
  local a = i * pi / 6
  local ca, sa = cos(a), sin(a)
  G.line(c, { { floor(32 + ca * 17 * 0.68 + 0.5), floor(30 + sa * 5 * 0.68 + 0.5) }, { floor(32 + ca * 17 * 0.95 + 0.5), floor(30 + sa * 5 * 0.95 + 0.5) } }, "#22322e")
end
c:px(32, 30, BRASS[5])
-- gnomon shadow on the face
local shw = c:poly{ { 35, 30 }, { 37, 31 }, { 48, 33 }, { 45, 35 } }
shw:each(function(x, y) if E2:has(x, y) then c:px(x, y, VERD[1]) end end)
-- gnomon
local gm = c:poly{ { 30, 31 }, { 36, 31 }, { 33, 9 } }
shade(gm, BRASS, 3, { amb = 0.1, wrap = 0.3 })
G.line(c, { { 30, 31 }, { 33, 11 } }, BRASS[5])
c:px(32, 17, BRASS[6]) c:px(31, 24, BRASS[6]) c:px(33, 10, BRASS[5])
for y = 22, 30 do c:px(34, y, BRASS[2]) end
-- ladybird on the rim
c:px(46, 28, "#d8403a") c:px(47, 28, "#d8403a") c:px(46, 29, "#b02c34") c:px(47, 29, "#b02c34") c:px(48, 28, "#2b1c26")
-- rim glints
c:px(18, 30, BRASS[6]) c:px(22, 26, BRASS[5]) c:px(23, 25, BRASS[6])
G.fin(c, "sundial")
