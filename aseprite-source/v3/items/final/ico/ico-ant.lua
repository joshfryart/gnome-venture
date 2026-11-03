local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-ant: bold three-part red-brown ant seen from above, big abdomen, thick legs and curled antennae.
-- quirk: it carries a green leaf crumb on its back like a tiny sail.
local c = D.new("ico-ant")
local ANT = { "#2a1218", "#4a2024", "#7a3028", "#a0432e", "#c8603a", "#e8885a" }
local LEG = { hi = ANT[5], base = ANT[3], shade = ANT[2], deep = ANT[1] }
-- legs (3 px) both sides
for _, l in ipairs{
  { {26, 34}, {16, 28}, {10, 36} }, { {30, 38}, {22, 46}, {14, 54} }, { {34, 40}, {38, 50}, {34, 57} },
  { {26, 30}, {20, 20}, {10, 20} }, { {30, 28}, {38, 22}, {46, 24} }, { {36, 34}, {46, 34}, {52, 42} } } do
  c:part(c:line(l, 3), LEG, { band = 1, nopop = true, noshade = true })
end
-- antennae
c:part(c:line({ {12, 30}, {6, 24}, {4, 17} }, 2), LEG, { noshade = true, nopop = true })
c:part(c:line({ {16, 26}, {14, 18}, {8, 14} }, 2), LEG, { noshade = true, nopop = true })
-- body parts
local ab = D.ell(44, 40, 11, 8, -0.5)
D.lit(c, ab, ANT, 6)
local th = c:ellipse(30, 34, 6, 5)
D.lit(c, th, ANT, 4)
D.seam(c, ab, th, ANT[1])
local hd = c:ellipse(18, 30, 7, 6)
D.lit(c, hd, ANT, 4)
D.seam(c, th, hd, ANT[1])
c:fillMask(c:rect(12, 28, 13, 29), INK) c:px(12, 28, CREAM)
c:fillMask(c:rect(11, 33, 14, 34), "#2a1218")  -- mandibles
-- leaf on back
D.leaf(c, 30, 31, 46, 12, 6, "moss", { 4, 9 })
D.fin()
