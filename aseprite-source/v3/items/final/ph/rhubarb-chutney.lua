-- rhubarb-chutney (final draft D12, Sonnet). Squat round-bellied jar of dark rhubarb-red chutney, topped with a cloth
-- cover tied with twine, small rhubarb label. quirk: a dribble of chutney has run down the glass from under the cloth.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rhubarb-chutney")
D.shadow(c, 32, 57, 18, 3)
local body = c:ellipse(32, 42, 16.5, 13)
local glass = D.lit(c, body, D.R.glass, 8, { wrap = 0.2 })
local fill = body:shrink(2)
local ci = D.lit(c, fill, { "#2a1020", "#4a1a2a", "#6e2a30", "#8f4030", "#b05a3a", "#d08050" }, 8, { wrap = 0.2 })
-- chunky bits
D.scatter(fill, 12, 9, function(x, y) c:px(x, y, "#d08050") end, c:ellipse(32, 46, 11, 6))
-- glass glint
for y = 34, 38 do c:px(20, y, "#f0fcff") end c:px(21, 33, "#f0fcff")
-- label
local lab = c:rrect(24, 40, 40, 51, 1)
D.lit(c, lab, D.R.cream, 2, {})
c:fillMask(c:rect(28, 44, 32, 46), "#d04060") c:fillMask(c:rect(31, 42, 33, 43), "#45954c") c:px(29, 44, "#ffd0d8")
for x = 26, 38, 2 do c:px(x, 49, "#b58d70") end
-- cloth cover
local cloth = HP.mask()
cloth:add(c:poly{ {22,22},{42,22},{47,33},{17,33} }):add(c:ellipse(32, 21, 11, 4))
local cl = D.lit(c, cloth, D.R.cream, 3, {})
-- scalloped hem: cut little notches, then gingham
for x = 18, 46, 4 do cloth:cut(c:rect(x, 34, x + 1, 34)) end
for y = 18, 33 do for x = 16, 48 do if cloth:has(x, y) and ((floor(x / 3) + floor(y / 3)) % 2 == 0) then c:px(x, y, "#e8493b") end end end
D.lit(c, c:ellipse(32, 20, 8, 3):clip(cloth), { "#b52e3f", "#d04a3c", "#e8493b", "#ee7a5a", "#ff8a5c", "#ffb08a" }, 2)
-- twine
for x = 20, 44 do local d = abs(x - 32) local y = 28 + floor(d / 8) if cloth:has(x, y) then c:px(x, y, (x % 2 == 0) and "#8a6a44" or "#c4a070") end end
-- dribble
c:px(40, 34, "#6e2a30") c:px(40, 35, "#6e2a30") c:px(40, 36, "#8f4030") c:px(40, 37, "#8f4030") c:px(40, 38, "#b05a3a") c:px(41, 38, "#6e2a30")
c:px(40, 39, "#6e2a30")
D.fin()
