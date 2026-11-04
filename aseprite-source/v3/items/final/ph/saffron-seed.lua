-- saffron-seed (first draft, Sonnet). Saffron crocus is sterile and grown from corms, so the 'seed' is three
-- papery brown corms with a net of fibres on a grass-like leaf scrap with a pale stripe; the right corm has sprouted
-- a pointed shoot with two white-striped blades and a closed violet bud.
-- quirk: the violet bud peeks out already, long before it is time.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("saffron-seed")
local floor = math.floor
local LF = A.R("#5ab050")
A.blade(c, 3, 57, 59, 46, 6, LF, { veins = {}, slant = 2 })
A.ln(c, 5, 56, 57, 47, "#c4e07a")
local sd = A.R("#a8774a")
for _, s in ipairs{ { 14, 52, 5.2, 3.8, .2 }, { 27, 53, 5.2, 3.8, -.15 }, { 41, 49, 5.4, 4.2, .1 } } do
  local m = A.seed(c, s[1], s[2], s[3], s[4], s[5], sd, LF[1], "#e0c090")
  A.ln(c, s[1] - 2, s[2] - 3, s[1] + 4, s[2] + 3, "#6e4a2a", m) A.ln(c, s[1] + 3, s[2] - 3, s[1] - 3, s[2] + 3, "#6e4a2a", m)
  A.ln(c, s[1], s[2] - 4, s[1], s[2] - 6, "#e0c090")
  for k = -2, 2 do c:px(s[1] + k * 2, s[2] + s[4] + 1, "#e0c090") end
end
A.rod(c, 41, 45, 41, 28, .9, "#d8e8b0", { amb = .15 })
A.blade(c, 41, 44, 28, 14, 2.2, "#5ab050", { veins = {}, slant = 2 })
A.blade(c, 41, 44, 53, 16, 2.2, "#4a9a48", { veins = {}, slant = 2 })
A.ln(c, 40, 40, 31, 22, "#c4e07a") A.ln(c, 42, 40, 51, 22, "#c4e07a")
A.ell(41, 25, 3, 5, 0)
A.lit(c, A.ell(41, 24, 2.8, 5.4, 0), "#8a6fd0", 1.8)
c:px(40, 22, "#c9b2f0") c:px(41, 29, "#35295f")
A.fin()
