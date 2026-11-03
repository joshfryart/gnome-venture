-- birdbath: a slim stone pedestal birdbath with a shallow bowl of rippling water. quirk: a tiny blue bird is bathing in it, flicking up a splash of droplets.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("birdbath")
local S = D.STN
D.sh(32, 57, 15, 3)
-- base
local base = c:poly{ {20,56}, {44,56}, {42,52}, {22,52} } D.lit(base, S, 2)
-- stem
local stem = c:poly{ {28,52}, {36,52}, {34,38}, {30,38} } D.vc(stem, S, 28, 36)
for y = 42, 49, 3 do for x = 29, 35 do if stem:has(x, y) then c:px(x, y, S[2]) end end end
-- bowl underside
local bowl = D.ell(32, 33, 20, 7, 0):add(c:rect(12, 30, 52, 33))
bowl:cut(c:rect(0, 0, 63, 27))
D.lit(bowl, S, 5, { wrap = .4 })
-- rim
local rim = D.ell(32, 29, 21, 6.5, 0)
D.lit(rim, { S[3], S[4], S[5], S[6], S[6], S[6] }, 2, { wrap = .5 })
local water = D.ell(32, 29.5, 18, 4.6, 0)
D.lit(water, D.GLS, 3, { wrap = .5 })
-- ripples
for a = 0, 6.28, .15 do local x, y = floor(32 + cos(a) * 12 + .5), floor(30 + sin(a) * 2.8 + .5) c:px(x, y, "#e4faf8") end
for a = 0, 6.28, .2 do local x, y = floor(32 + cos(a) * 15 + .5), floor(30 + sin(a) * 3.8 + .5) if a > 3 then c:px(x, y, "#5a9cc8") end end
-- bird
c:paint({ "..xxx.", ".xxxxx", "xxwwxx", ".xxxx." }, 28, 22, { x = "#4a82d0", w = "#fff4d6" })
c:px(29, 24, "#2b1c26") c:px(27, 25, "#f8a82e") c:px(32, 21, "#2c58a8") c:px(33, 22, "#2c58a8") c:px(34, 23, "#1c3a78") c:px(35, 24, "#1c3a78")
c:px(29, 22, "#6aa2e8") c:px(30, 22, "#6aa2e8")
-- splash
for _, p in ipairs{ {38,19}, {41,17}, {36,15}, {43,21}, {40,13} } do c:px(p[1], p[2], "#b6e8f0") end
c:px(38, 20, "#5a9cc8") c:px(41, 18, "#5a9cc8")
D.fin()
