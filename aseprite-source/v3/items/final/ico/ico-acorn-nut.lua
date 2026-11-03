local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-acorn-nut: bold chocolate acorn icon, smooth cap with a row of round scale studs, fat 3px stem, big glossy streak.
-- quirk: the cap sits a little crooked, with a small leaf tucked under the rim.
local c = D.new("ico-acorn-nut")
local NUT = { "#3a1e20", "#5e3226", "#7e4630", "#9c5e3a", "#bc7c4c", "#dca070" }
local CAP = { "#4a2a2a", "#6e3a34", "#8e4c3a", "#aa6444", "#c8845a", "#e8a878" }
c:groundShadow(32, 57, 12, 2)
local nut = c:ellipse(32, 41, 13, 14):add(c:poly{ {27, 53}, {32, 58}, {37, 53} })
D.lit(c, nut, NUT, 8, { amb = 0.05 })
D.leaf(c, 20, 31, 11, 25, 4, "moss", { 3 })
local cap = c:ellipse(32, 30, 17, 11):clip(c:rect(0, 0, 63, 33))
D.lit(c, cap, CAP, 6, { amb = 0.1 })
for _, p in ipairs{ {21, 26}, {27, 24}, {33, 24}, {39, 25}, {44, 28}, {24, 30}, {30, 29}, {36, 29}, {42, 31} } do
  c:fillMask(c:rect(p[1], p[2], p[1] + 2, p[2] + 1), CAP[2])
  c:px(p[1], p[2], CAP[5])
end
for x = 16, 48 do if cap:has(x, 33) then c:px(x, 33, CAP[1]) end end
c:part(c:rect(31, 17, 34, 23), "wood", { band = 1 })
c:fillMask(c:rect(23, 38, 24, 43), "#e8b890") c:px(24, 37, CREAM)
D.fin()
