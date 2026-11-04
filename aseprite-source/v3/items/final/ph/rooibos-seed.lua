-- rooibos-seed (first draft, Sonnet). Six tiny glossy red-brown rooibos seeds (bean-shaped, hilum dot) on a
-- slim green leaf scrap; the right seed has sprouted into a thin stem with whorls of needle leaves.
-- quirk: the seedling wears its split seed coat as a tiny hat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rooibos-seed")
local floor = math.floor
local LF = A.R("#5c9a52")
A.scrap(c, 4, 57, 56, 47, 8, LF, { 5, 9, 13, 17, 21, 25, 29, 33 })
local sd = A.R("#7a2e22")
for _, s in ipairs{ { 12, 53, .5 }, { 18, 55, -.2 }, { 23, 51, .8 }, { 29, 54, 0 }, { 35, 50, .3 }, { 44, 48, -.3 } } do
  A.seed(c, s[1], s[2], 2.4, 1.6, s[3], sd, LF[1], "#ffc4a0")
  c:px(floor(s[1] + 1), floor(s[2]), "#2b1c26")
end
A.rod(c, 44, 46, 44, 16, 0.9, "#a8c890", { amb = .15 })
for i = 0, 5 do
  local y = 42 - i * 5 local L = 8 - i * .6
  for k = -2, 2 do A.needle(c, 44, y, -1.57 + k * .6 + (i % 2) * .2, L * (k == 0 and .7 or 1), (k % 2 == 0) and "#5c9a52" or "#3f7a44", "#9bd070") end
end
-- seed-coat hat
A.seed(c, 44, 14, 2.6, 1.6, -.2, sd, LF[1], "#ffc4a0")
c:px(46, 15, "#2b1c26") c:px(42, 15, "#c8602e")
A.fin()
