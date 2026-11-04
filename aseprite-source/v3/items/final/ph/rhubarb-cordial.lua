-- rhubarb-cordial (final draft D12, Sonnet). Tall slim glass bottle of pink rhubarb cordial with a cork, small cream label
-- and rising bubbles. quirk: a paper tag with a heart hangs from the neck on a string.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rhubarb-cordial")
D.shadow(c, 30, 58, 11, 2.5)
local body = c:rrect(20, 28, 40, 56, 5)
body:add(c:poly{ {20,32},{26,23},{34,23},{40,32} }):add(c:rrect(26, 10, 34, 25, 1))
D.lit(c, body, D.R.glass, 7, { wrap = 0.25 })
local liq = body:shrink(2)
liq:cut(c:rect(0, 0, 63, 27))
local li = D.lit(c, liq, D.R.pink, 7, { wrap = 0.25 })
for x = 22, 38 do if liq:has(x, 28) then c:px(x, 28, "#ffd0d8") end end
-- cork
local cork = c:rrect(25, 5, 35, 11, 1)
D.lit(c, cork, D.R.wood, 2, {})
for x = 27, 33, 3 do c:px(x, 8, "#51302b") end
-- label
local lab = c:rrect(23, 38, 37, 50, 1)
D.lit(c, lab, D.R.cream, 2, {})
c:fillMask(c:rect(28, 42, 32, 46), "#d04060") c:px(29, 42, "#ffd0d8") c:fillMask(c:rect(31, 40, 33, 41), "#45954c")
for x = 25, 35, 2 do c:px(x, 48, "#b58d70") end
-- glass glints, bubbles
for y = 33, 40 do c:px(22, y, "#f0fcff") end c:px(23, 31, "#f0fcff")
c:px(27, 30, "#ffd0d8") c:px(35, 33, "#ffd0d8") c:px(34, 52, "#ffd0d8") c:px(28, 53, "#a02a4a") c:px(36, 45, "#a02a4a")
-- tag on string
D.ln(c, 33, 21, 38, 21, "#8a6a44") D.ln(c, 38, 21, 43, 25, "#8a6a44")
local tag = c:poly{ {42,24},{48,24},{48,31},{42,31},{40,27} }
D.lit(c, tag, D.R.cream, 2, {})
c:px(43, 27, "#e8493b") c:px(45, 27, "#e8493b") c:px(44, 28, "#e8493b") c:px(43, 28, "#b52e3f") c:px(45, 28, "#b52e3f") c:px(44, 29, "#b52e3f") c:px(44, 27, "#ff8a5c")
c:px(43, 26, "#ff8a5c") c:px(45, 26, "#ff8a5c")
D.fin()
