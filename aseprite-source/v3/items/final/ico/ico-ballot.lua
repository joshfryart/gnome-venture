local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-ballot: wooden ballot box with a dark slot, a cream paper bearing a green tick dropping in.
-- quirk: the box is locked with a chunky gold padlock on its front.
local c = D.new("ico-ballot")
c:groundShadow(32, 58, 24, 2)
-- paper
local paper = c:rrect(21, 6, 43, 36, 2)
D.lit(c, paper, { "#8a8aa8", "#b8b8d0", "#d8d8e8", "#eceaf0", "#f6f4f6", "#fffafa" }, 2)
c:fillMask(c:poly{ {24, 21}, {28, 25}, {37, 13}, {39, 15}, {28, 29}, {22, 23} }, "#3f9150")
c:fillMask(c:poly{ {25, 21}, {28, 24}, {36, 14}, {37, 15}, {28, 27}, {23, 22} }, "#7cc35a")
-- box
c:part(c:rect(8, 34, 55, 57), "wood", { band = 3 })
c:part(c:rect(8, 34, 55, 41), "wood", { band = 1, noshade = true, nopop = true })
c:fillMask(c:rect(9, 35, 54, 35), "#e8b982")
c:fillMask(c:rect(17, 37, 46, 40), "#2b1c26")
c:fillMask(c:rect(17, 37, 46, 37), "#51302b")
for x = 14, 50, 12 do c:fillMask(c:rect(x, 44, x, 55), "#864c33") end
-- padlock
c:part(c:rrect(27, 46, 37, 55, 2), "gold", { band = 2 })
c:fillMask(c:rect(31, 49, 32, 52), "#8f4a1f")
D.polyline(c, { {29, 46}, {29, 43}, {31, 42}, {33, 42}, {35, 43}, {35, 46} }, "#d9d3dc")
D.fin()
