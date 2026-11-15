-- Popcorn Moon (mh-popcorn-moon), perch 36x36, hand-built at size. Haiku first pass, c00. Rare.
-- quirk: popcorn puffs bursting off the rim, a cream sparkle for the midnight pop.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mh-popcorn-moon-perch", 36)

c:part(c:ellipse(7, 7, 2, 2):add(c:ellipse(4, 12, 2, 2)):add(c:ellipse(10, 3, 2, 2)), "sky")
local moon = c:ellipse(18, 18, 12, 12)
moon:cut(c:ellipse(23, 14, 9, 9))
c:part(moon, "gold", { band = 2 })
c:px(14, 24, P.gold.shade) c:px(12, 26, P.gold.shade)
c:eyeSmall(9, 17)
c:eyeSmall(13, 17)
c:px(12, 21, P.gold.hi) c:px(12, 22, P.gold.deep)
c:px(10, 22, P.ink) c:px(11, 23, P.ink) c:px(12, 23, P.ink)
c:sparkle(28, 6)

M.done(c, "mh-popcorn-moon-perch")
