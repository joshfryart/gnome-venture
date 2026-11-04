-- harissa (dC11 first draft): squat terracotta jar, cloth cover tied with twine, red paste drip, small chili label.
-- quirk: a drip of red paste has run over the cloth and down the jar, with a thumbprint at its end.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("harissa")
local P = D.P
c:groundShadow(32, 56, 17, 3)
local TERRA = D.r4("#f5b57a", "#d9743f", "#a64a35", "#5e2a2e")
local CLOTH = D.r4("#fffaf0", "#f4e3b8", "#d6b98a", "#8f6e55")
local body = D.ell(32, 42, 15, 12)
D.part(c, body, TERRA, 5)
-- clay glaze lip line + grain flecks
for _, p in ipairs{ {22,38},{40,47},{26,49},{37,36} } do c:px(p[1], p[2], "#8f3d33") end
local neck = c:rrect(23, 27, 41, 33, 1)
D.part(c, neck, TERRA, 2)
-- cloth cover with gathered bottom
local cloth = c:rrect(20, 20, 44, 29, 4)
D.part(c, cloth, CLOTH, 3)
for x = 23, 41, 4 do c:px(x, 26, CLOTH[2]) c:px(x, 27, CLOTH[2]) c:px(x + 1, 28, CLOTH[3]) end
for x = 22, 42, 3 do c:px(x, 23, CLOTH[5]) end
-- twine
for x = 22, 42 do c:px(x, 30, (x % 3 == 0) and P.gold.shade or P.gold.base) end
for x = 22, 42 do c:px(x, 31, P.gold.deep) end
c:px(32, 31, P.gold.hi) c:px(34, 32, P.gold.shade) c:px(35, 33, P.gold.shade) c:px(30, 32, P.gold.shade) c:px(29, 33, P.gold.shade)
-- label
local lab = c:rrect(24, 38, 40, 48, 2)
D.part(c, lab, CLOTH, 2)
c:paint({
  "...e..",
  "..eEe.",
  ".eEEe.",
  "eEEe..",
  ".ee...",
}, 28, 40, { e = "ember.base", E = "ember.hi" })
c:px(27, 40, "#3f9150") c:px(28, 39, "#3f9150")
-- paste drip over cloth and jar
local drip = c:rrect(38, 22, 40, 36, 1):add(c:ellipse(39, 37, 2, 2))
D.part(c, drip, "ember", 1)
c:px(38, 22, P.ember.hi) c:px(38, 37, P.ember.hi) c:px(39, 38, P.ember.deep)
-- red lip on the cloth top
c:fillMask(c:rrect(37, 20, 41, 22, 1), P.ember.base) c:px(37, 20, P.ember.hi)
D.fin()
