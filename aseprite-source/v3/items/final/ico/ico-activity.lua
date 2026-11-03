local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-activity: a chunky gnome mid-sprint, red pointed hat, round skin face, white beard, green tunic, big boots.
-- quirk: his hat's bobble flies off behind with speed dashes.
local c = D.new("ico-activity")
-- speed dashes
for _, d in ipairs{ {4, 28, 12}, {6, 36, 8}, {2, 44, 12} } do c:fillMask(c:rect(d[1], d[2], d[1] + d[3], d[2] + 1), "#b6f0e0") end
-- back leg and front leg, arms
c:part(c:line({ {27, 38}, {20, 46}, {13, 48} }, 4), "wood")
c:part(c:poly{ {9, 46}, {17, 45}, {18, 52}, {9, 52} }, "wood", { band = 1 })
c:part(c:line({ {32, 40}, {38, 48}, {45, 50} }, 4), "wood")
c:part(c:poly{ {42, 47}, {54, 47}, {55, 53}, {42, 53} }, "ember")
-- torso
c:part(c:poly{ {24, 28}, {38, 28}, {40, 42}, {26, 42} }, "moss")
c:part(c:line({ {38, 31}, {46, 36}, {52, 34} }, 3), "skinA", { band = 1 })
c:part(c:line({ {25, 31}, {19, 37}, {14, 33} }, 3), "skinA", { band = 1 })
c:fillMask(c:rect(25, 39, 39, 40), "#24544a")
c:fillMask(c:rect(30, 39, 33, 40), "#f5b82e")
-- head
c:part(c:ellipse(32, 20, 8, 8), "skinA")
c:part(c:poly{ {22, 24}, {42, 24}, {38, 33}, {32, 36}, {26, 33} }:clip(c:rect(0, 24, 63, 40)), { hi = "#fffaf0", base = "#fff4d6", shade = "#d8d0c0", deep = "#9a90a0" }, { band = 1 })
c:part(c:ellipse(32, 23, 8, 8):clip(c:rect(0, 10, 63, 21)), "skinA", { noshade = true, nopop = true })
c:eyeSmall(28, 19) c:eyeSmall(34, 19)
c:part(c:ellipse(32, 23, 2, 1.5), "skinA", { noshade = true, nopop = true })
c:part(c:poly{ {22, 17}, {42, 17}, {36, 5}, {30, 1} }, "ember")
c:fillMask(c:rect(23, 15, 41, 17), "#6e2038")
c:part(c:ellipse(25, 3, 3, 3), "gold", { band = 1 })
D.move(c, 4, 5)
D.fin()
