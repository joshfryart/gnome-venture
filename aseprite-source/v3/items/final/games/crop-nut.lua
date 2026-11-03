local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- crop-nut: golden-brown acorn, scaly crosshatched cap with a lip, pointed nut tip, glossy streak.
-- quirk: it has already sprouted: a tiny two-leaf seedling grows from the cap.
local c = D.new("crop-nut")
local NUT = { "#51302b", "#7a4a32", "#9a6238", "#b97a4a", "#d49a62", "#eab882" }
local CAP = { "#3a2220", "#51302b", "#6e4430", "#8a5a38", "#a8764a", "#c89868" }
c:groundShadow(32, 58, 11, 2)
local nut = c:ellipse(32, 42, 12, 13):add(c:poly{ {28, 52}, {32, 58}, {36, 52} })
D.lit(c, nut, NUT, 7)
local cap = c:ellipse(32, 31, 15, 10):clip(c:rect(0, 0, 63, 33))
D.lit(c, cap, CAP, 5, { amb = 0.1 })
cap:each(function(x, y)
  if y < 32 and ((x + y) % 4 == 0 or (x - y) % 4 == 0) then D.shift(c, x, y, CAP, -2)
  elseif y < 32 and (x + y) % 4 == 2 and (x - y) % 4 == 2 then D.shift(c, x, y, CAP, 1) end
end)
for x = 17, 47 do if cap:has(x, 33) then c:px(x, 33, CAP[1]) end end
-- stem nub
c:part(c:rect(31, 21, 33, 24), "wood", { band = 1 })
-- seedling
c:part(c:line({ {32, 22}, {32, 17}, {33, 14} }, 1), "moss", { noshade = true, nopop = true })
D.leaf(c, 33, 15, 45, 9, 3.2, "moss", { 3 })
D.leaf(c, 32, 16, 20, 11, 3.2, "moss", { 3 })
for _, p in ipairs{ {23, 40}, {23, 41}, {24, 39}, {24, 38} } do c:px(p[1], p[2], "#ffe3b0") end
c:px(23, 40, CREAM)
D.fin()
