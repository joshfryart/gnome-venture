-- rose-of-sharon-seed (first draft, Sonnet). Four small kidney-shaped grey-brown seeds fringed with fine silky
-- hairs on a broad toothed leaf scrap; the right seed has sprouted: pale stem, two round cotyledons and the first
-- three-lobed true leaf.
-- quirk: a fluff of silky seed hair has drifted loose beside the leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rose-of-sharon-seed")
local floor = math.floor
local LF = A.R("#5aa050")
A.scrap(c, 59, 56, 6, 45, 10, LF, { 6, 10, 14, 18, 22, 26, 30, 34, 38 })
local sd = A.R("#8a6a4a")
for _, s in ipairs{ { 52, 52, -.4 }, { 44, 53, .3 }, { 35, 51, -.2 }, { 26, 49, .4 } } do
  A.seed(c, s[1], s[2], 3.2, 2.2, s[3], sd, LF[1], "#e8dcc0")
  for k = 0, 5 do c:px(floor(s[1] - 3 + k * 1.2), floor(s[2] + 3 - (k % 2)), "#f0e6cc") end
  c:px(floor(s[1]), floor(s[2] - 3), "#f0e6cc")
end
A.rod(c, 26, 47, 26, 28, .9, "#b8d890", { amb = .15 })
A.sph(c, 21, 33, 3, "#7cc35a", { nospec = true }) A.sph(c, 31, 33, 3, "#7cc35a", { nospec = true })
A.blade(c, 26, 28, 26, 10, 3.4, LF, { veins = { 3, 6, 9 }, slant = 2 })
A.blade(c, 26, 28, 17, 18, 2.6, LF, { veins = { 3, 6 }, slant = 2 })
A.blade(c, 26, 28, 35, 18, 2.6, LF, { veins = { 3, 6 }, slant = 2 })
-- loose fluff
for _, p in ipairs{ { 12, 56 }, { 14, 55 }, { 11, 54 }, { 15, 57 }, { 13, 57 } } do c:px(p[1], p[2], "#fff4d6") end
c:px(10, 56, "#e8dcc0")
A.fin()
