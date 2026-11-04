-- sea-glass (first draft, Sonnet). A little pile of frosted tumbled glass: one big rounded irregular seafoam-green
-- shard in front, a smaller cobalt-blue nugget and a milky white sliver behind, on a drift of sand with grains.
-- quirk: the green shard has a trapped air bubble ring in its middle.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("sea-glass")
local floor = math.floor
-- sand
local sand = c:ellipse(32, 51, 26, 7)
A.lit(c, sand, A.R("#e8c88a"), 3, { amb = .06 })
A.speck(c, sand, { "#fff4d6", "#c9a060", "#b8864a" }, .2, 12)
-- white sliver
local ws = c:poly{ { 38, 18 }, { 52, 22 }, { 55, 36 }, { 46, 40 }, { 36, 30 } }
A.lit(c, ws, A.R("#e4eef0"), 3, { amb = .1 })
-- blue nugget
local bn = c:poly{ { 8, 30 }, { 16, 22 }, { 25, 28 }, { 26, 38 }, { 16, 43 }, { 9, 39 } }
A.lit(c, bn, A.R("#3a66c0"), 4, { amb = .1 })
-- green shard
local gs = c:poly{ { 18, 28 }, { 30, 14 }, { 44, 22 }, { 49, 38 }, { 40, 51 }, { 24, 50 }, { 15, 40 } }
A.lit(c, gs, A.R("#5fc4a8"), 6, { amb = .1, wrap = .3 })
-- frosting speckle
A.speck(c, gs, { "#b6f0e0", "#3a8a82" }, .1, 5)
A.speck(c, bn, { "#7a9ae0", "#2a4a8a" }, .1, 6)
A.speck(c, ws, { "#fff4d6", "#b8c8d0" }, .1, 7)
-- bright rim along upper-left edge of green shard
gs:each(function(x, y) if not gs:has(x - 1, y) or not gs:has(x, y - 1) then c:px(x, y, "#d8fff0") end end)
-- trapped bubble
c:fillMask(c:ellipse(32, 33, 3.2, 3.2):cut(c:ellipse(32, 33, 1.4, 1.4)), "#d8fff0")
c:px(31, 32, "#ffffe0")
-- pop
c:px(25, 24, "#ffffe0") c:px(26, 24, "#ffffe0")
A.fin()
