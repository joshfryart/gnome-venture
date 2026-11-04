-- root_cellar-lantern (first draft, Sonnet). A gently leaning mound at dusk: the door is ajar with warm light
-- spilling out, and an iron lantern glows on a hooked post beside it.
-- quirk: a little moth circles the lantern.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("root_cellar-lantern")
c:groundShadow(32, 58, 22, 3)
local m = A.mound(c, { cx = 30, yb = 54, rx = 24, ry = 27, ramp = "#4e9a5a", skew = -3 })
A.speck(c, m, { "#c4e07a", "#2c6a4a" }, .1, 2)
A.lit(c, c:rect(6, 54, 54, 56), "wood", 1.6)
local fr = A.archM(c, 28, 54, 9, 18)
A.lit(c, fr, "stone", 2.2)
local inner = A.archM(c, 28, 54, 7, 16)
c:fillMask(inner, "#8f4a1f")
inner:each(function(x, y) if x >= 29 or y > 48 then c:px(x, y, "#f5b82e") end end)
for y = 44, 54 do c:px(34, y, "#ffe38a") end
-- door leaf swung open (narrow)
local leaf = c:poly{ { 21, 53 }, { 25, 51 }, { 25, 40 }, { 21, 38 } }
A.lit(c, leaf, "wood", 1.3)
A.ln(c, 23, 40, 23, 51, "#51302b")
-- spill of light on the step
for x = 24, 38 do c:px(x, 55, "#ffe38a") end
-- post + lantern
A.rod(c, 50, 24, 50, 56, 1.0, "wood", { amb = .1 })
A.ln(c, 50, 24, 44, 24, "#8f4a1f") A.ln(c, 44, 24, 44, 26, "#444663")
local lan = c:rect(41, 27, 47, 36)
A.lit(c, c:rect(40, 25, 48, 27), "#444663", 1)
c:fillMask(lan, "#f5b82e")
for y = 28, 35 do c:px(41, y, "#444663") c:px(47, y, "#444663") end
c:fillMask(c:rect(43, 29, 45, 33), "#ffe38a") c:px(44, 31, "#fff4d6")
A.lit(c, c:rect(40, 36, 48, 37), "#444663", 1)
-- glow pixels
for _, p in ipairs{ { 39, 31 }, { 49, 30 }, { 44, 39 }, { 38, 28 } } do c:px(p[1], p[2], "#ffe38a") end
-- moth
c:px(37, 22, "#e2e0e6") c:px(36, 21, "#cfc8d8") c:px(38, 21, "#cfc8d8") c:px(37, 21, "#7a5a4a")
A.fin()
