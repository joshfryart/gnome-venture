local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- envelope: cream paper envelope with a pointed flap, fold creases and a red wax seal.
-- quirk: the letter inside is so full of news it peeks out of the top, with a pressed leaf sprout tucked in.
local c = D.new("envelope")
local PAP = { "#a8804e", "#cfa470", "#e8c488", "#f4dca0", "#fce8b4", "#fff4d6" }
-- letter peeking out
local letter = c:rrect(14, 9, 49, 24, 2)
D.lit(c, letter, { "#8a8aa8", "#b8b8d0", "#d8d8e8", "#eceaf0", "#f6f4f6", "#fffafa" }, 2)
for x = 19, 38 do c:px(x, 14, "#7a8ab0") end
for x = 19, 31 do c:px(x, 18, "#7a8ab0") end
-- sprout
c:part(c:line({ {45, 14}, {46, 7} }, 1), "moss", { noshade = true, nopop = true })
D.leaf(c, 46, 8, 55, 3, 2.6, "moss", { 3 })
D.leaf(c, 46, 9, 40, 4, 2.6, "moss", { 3 })
-- body
local body = c:rrect(8, 20, 55, 51, 3)
D.lit(c, body, PAP, 3, { amb = 0.15 })
-- flap
local flap = c:poly{ {8, 20}, {55, 20}, {32, 40} }
D.lit(c, flap, { "#b48c5a", "#d8b078", "#ecc890", "#f8e0a8", "#fff0c0", "#fff8dc" }, 2)
D.polyline(c, { {9, 21}, {32, 40}, {54, 21} }, PAP[2])
D.polyline(c, { {9, 50}, {27, 35} }, PAP[2])
D.polyline(c, { {54, 50}, {37, 35} }, PAP[2])
for x = 12, 51 do D.shift(c, x, 20, PAP, 1) end
-- seal
local seal = c:ellipse(32, 38, 5, 5)
D.lit(c, seal, "ember", 4)
c:px(32, 36, "#ff9a70") c:px(32, 38, "#6e2038") c:px(31, 39, "#6e2038") c:px(33, 39, "#6e2038") c:px(32, 40, "#6e2038")
c:px(29, 36, "#ffd0a8")
D.move(c, 0, 4)
D.fin()
