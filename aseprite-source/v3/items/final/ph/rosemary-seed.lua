-- rosemary-seed (first draft, Sonnet). Five tiny speckled tan rosemary nutlets on a leaf scrap made of two
-- crossed needle-like leaves; one nutlet has sprouted: thin stem with opposite pairs of needle leaves.
-- quirk: a tiny pale rootlet has crept out of a nutlet and curls across the leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rosemary-seed")
local LF = A.R("#2f6a4a")
A.blade(c, 4, 56, 58, 44, 4.2, LF, { veins = {}, slant = 2 })
A.blade(c, 6, 46, 56, 56, 3.6, "#3f7a54", { veins = {}, slant = 2 })
local sd = A.R("#b08a5a")
for _, s in ipairs{ { 13, 52, .3 }, { 20, 53, -.4 }, { 28, 52, .5 }, { 36, 50, 0 }, { 45, 50, -.3 } } do
  A.seed(c, s[1], s[2], 2.6, 2.0, s[3], sd, LF[1], "#f0e0b8")
  c:px(s[1] + 1, s[2], "#5a3a2a") c:px(s[1] - 1, s[2] + 1, "#6a4a30")
end
A.rod(c, 45, 48, 45, 14, .9, "#a8c890", { amb = .15 })
for i = 0, 5 do
  local y = 44 - i * 5
  A.needle(c, 45, y, 3.14 + .5, 7, "#3f7a54", "#8fc0a8") A.needle(c, 45, y, -.5, 7, "#2f6a4a", "#8fc0a8")
end
A.needle(c, 45, 14, -1.57, 5, "#3f7a54", "#8fc0a8")
-- rootlet
for _, p in ipairs{ { 29, 55 }, { 30, 56 }, { 31, 56 }, { 32, 55 }, { 33, 54 } } do c:px(p[1], p[2], "#fff4d6") end
A.fin()
