-- ico-notepad first draft (Sonnet). quirk: a pencil is tucked into the spiral and a doodled heart sits on the page
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-notepad")
c:groundShadow(30, 58, 19, 2)
local pad = c:rrect(14, 12, 48, 56, 3)
D.lit(pad, { "#c9a028", "#e0b838", "#f5d058", "#ffe27a", "#fff0a0", "#fff8c8" }, 3, { amb = .12 })
-- header band
D.fill(c:rect(14, 12, 48, 21), "#d4403a") D.fill(c:rect(14, 12, 48, 13), "#ee6a50") D.fill(c:rect(14, 21, 48, 21), "#7a2036")
-- ruled lines
for _, y in ipairs{ 28, 34, 40, 46, 52 } do D.fill(c:rect(17, y, 45, y), "#8bc4ea") end
D.fill(c:rect(19, 22, 19, 55), "#ee6a50")
-- doodle heart
D.fill(D.heart(36, 40, 5), "#d4403a") D.fill(c:rect(33, 37, 34, 37), "#ff9a78")
-- spiral rings
for x = 17, 45, 7 do
  D.fill(c:rect(x, 7, x + 2, 16), "#4d5275") D.fill(c:rect(x, 7, x, 16), "#9ea2bf") D.fill(c:rect(x + 1, 9, x + 1, 9), "#f0f1fa")
end
-- pencil
local pen = c:line({ {54, 24}, {40, 58} }, 5)
local pb = c:line({ {54, 24}, {41, 55} }, 5)
D.lit(pb, D.ORG, 2)
D.fill(c:poly{ {38, 56}, {43, 55}, {40, 62} }, "#f6e6bf") D.fill(c:poly{ {39, 59}, {41, 58}, {40, 62} }, "#2b1c26")
D.fill(c:poly{ {52, 20}, {57, 22}, {56, 27}, {51, 25} }, "#ee6a50")
D.fin()
