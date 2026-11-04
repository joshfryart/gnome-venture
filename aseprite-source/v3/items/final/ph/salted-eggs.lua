-- salted-eggs (first draft, Sonnet). Two whole blue-grey duck eggs in salt-crust dusting leaning on a cut half whose
-- glossy orange yolk glows in white; all on a small stone saucer heaped with coarse salt.
-- quirk: a cream salt-crystal sparkle sits on the yolk.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("salted-eggs")
local floor = math.floor
c:groundShadow(32, 55, 22, 4)
-- saucer
local sau = c:ellipse(32, 49, 24, 8)
A.lit(c, sau, A.R("#8a9ab8"), 3, { amb = .08 })
c:fillMask(c:ellipse(32, 48, 20, 5.5), "#c8d2e0")
-- salt heap
local heap = c:ellipse(32, 49, 18, 5)
A.lit(c, heap, A.R("#f4f0ec"), 3, { amb = .1 })
A.speck(c, heap, { "#ffffff" == nil and "#fff4d6" or "#fff4d6", "#c8d2e0", "#aaa9b8" }, .2, 5)
-- whole eggs (blue-grey)
local e1 = A.egg(c, 21, 32, 8, 11, "#a9b8c4", {})
local e2 = A.egg(c, 40, 29, 8.5, 12, "#9fb2bf", {})
A.speck(c, e1, { "#fff4d6", "#d6e0e8" }, .06, 3)
A.speck(c, e2, { "#fff4d6", "#d6e0e8" }, .06, 9)
-- cut half in front
local half = A.eggM(31, 42, 11, 8, .1)
half:clip(c:rect(0, 34, 63, 51))
local wh = A.R("#f4efe0")
A.lit(c, half, wh, 4, { amb = .1 })
local yolk = c:ellipse(31, 43, 5.5, 4.5)
A.lit(c, yolk, A.R("#f08a28"), 3.5, { amb = .1 })
c:px(28, 41, "#ffe38a") c:px(29, 41, "#ffe38a")
c:px(33, 40, "#fff4d6") c:px(34, 39, "#fff4d6") c:px(32, 39, "#fff4d6") c:px(33, 38, "#fff4d6") c:px(33, 41, "#fff4d6") -- sparkle
A.fin()
