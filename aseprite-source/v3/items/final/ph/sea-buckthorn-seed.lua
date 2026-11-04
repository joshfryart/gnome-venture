-- sea-buckthorn-seed (first draft, Sonnet). Five small glossy dark-brown flat seeds (central groove, pale tip) on a
-- narrow silver-green lanceolate leaf scrap; right seed sprouted: red-brown thorny stem, silvery narrow leaves.
-- quirk: a bit of orange berry skin still clings to one seed.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("sea-buckthorn-seed")
local floor = math.floor
local LF = A.R("#9ab88a")
A.scrap(c, 3, 55, 57, 44, 6.4, LF, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 })
local sd = A.R("#4a2e24")
local list = { { 10, 53, -.35 }, { 17, 51, -.4 }, { 24, 50, -.1 }, { 32, 48, -.3 }, { 41, 45, -.2 } }
for _, s in ipairs(list) do
  A.seed(c, s[1], s[2], 3.0, 1.9, s[3], sd, LF[1], "#ffd8a0")
  c:px(s[1] + 1, s[2], sd[1])
end
A.sprout(c, { { 41, 43 }, { 40, 36 }, { 41, 28 }, { 40, 20 } }, "#b5654a", {
  { 40, 36, 29, 32, 1.8, "#a8c09a", {} }, { 40, 36, 52, 31, 1.8, "#a8c09a", {} },
  { 41, 27, 30, 22, 1.8, "#b8d0a8", {} }, { 41, 27, 51, 21, 1.8, "#b8d0a8", {} },
  { 40, 20, 40, 8, 1.8, "#c8dcb8", {} } })
-- thorns
c:px(42, 33, "#6e2038") c:px(43, 32, "#6e2038") c:px(38, 25, "#6e2038") c:px(37, 24, "#6e2038")
-- orange berry skin on seed 2
for _, p in ipairs{ { 16, 49 }, { 17, 49 }, { 18, 49 }, { 17, 48 } } do c:px(p[1], p[2], "#f5a02e") end
c:px(16, 49, "#ffd070")
A.fin()
