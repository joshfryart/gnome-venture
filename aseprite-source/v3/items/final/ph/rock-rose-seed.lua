-- rock-rose-seed (first draft, Sonnet). Four tiny angular dark-brown rock-rose seeds on a wrinkled grey-green leaf
-- scrap; the right seed has sprouted: slim stem, two opposite ovate grey-green leaves, a second smaller pair and a
-- crumpled pink bud. quirk: one crumpled pink petal still clings to a seed.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rock-rose-seed")
local LF = A.R("#78967a")
A.scrap(c, 5, 57, 55, 42, 9.5, LF, { 6, 10, 14, 18, 22, 26, 30, 34 })
local sd = A.R("#5a3a2a")
for _, s in ipairs{ { 15, 52, 2.8, 2.0, .6 }, { 23, 53, -.3 }, { 31, 49, .4 }, { 42, 45, -.2 } } do
  A.seed(c, s[1], s[2], s[3] or 2.4, s[4] or 1.8, s[5] or s[3], sd, LF[1], "#d8b890")
end
A.sprout(c, { { 42, 43 }, { 43, 36 }, { 43, 28 }, { 44, 20 } }, "#a8b890", {
  { 43, 38, 31, 33, 3, LF, { 3, 6 } },
  { 43, 38, 55, 33, 3, LF, { 3, 6 } },
  { 44, 27, 36, 22, 2.6, "#8fae8a", { 3 } },
  { 44, 27, 52, 22, 2.6, "#8fae8a", { 3 } } })
-- crumpled bud on top
A.sph(c, 44, 15, 3, "#f5809f", {})
c:px(44, 15, "#ffe38a") c:px(43, 14, "#ffc4d8") c:px(46, 16, "#c94f84")
-- petal on a seed
c:px(25, 51, "#ffc4d8") c:px(26, 51, "#f5809f") c:px(26, 52, "#c94f84")
A.fin()
