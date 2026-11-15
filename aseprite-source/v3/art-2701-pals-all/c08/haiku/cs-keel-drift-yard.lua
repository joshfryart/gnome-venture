-- Keel Drift (cs-keel-drift), yard sprite 64x64. Haiku pass, c08.
-- Rare, thornblade. An old green sea turtle with a gold-trimmed shell, barnacles and a slow wink.
-- quirk: the wink, and the gleam on its very old shell.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-keel-drift-yard", 64)

c:groundShadow(32, 56, 22, 3)
-- flippers and tail
c:part(c:ellipse(20, 46, 5, 4), "moss")
c:part(c:ellipse(44, 46, 5, 4), "moss")
c:part(c:poly{ { 12, 36 }, { 6, 38 }, { 12, 42 } }, "moss")
-- head
c:part(c:ellipse(54, 31, 7, 6), "moss")
-- shell with gold rim and X-scute pattern
local shell = c:ellipse(30, 32, 21, 14)
c:part(shell, "moss", { band = 3 })
c:fillMask(shell:edge(), P.gold.base)
c:fillMask(c:line({ { 20, 22 }, { 30, 32 }, { 40, 22 } }, 1), P.moss.deep)
c:fillMask(c:line({ { 20, 42 }, { 30, 32 }, { 40, 42 } }, 1), P.moss.deep)
-- barnacles and the gleam
c:px(18, 28, P.cream)
c:px(43, 38, P.cream)
c:px(35, 21, P.cream)
c:sparkle(58, 18)
-- eye and wink
c:eyeLocked(49, 27)
c:fillMask(c:line({ { 56, 30 }, { 58, 28 }, { 60, 30 } }, 1), P.ink)
c:fillMask(c:line({ { 50, 37 }, { 54, 38 }, { 58, 36 } }, 1), P.ink)

H.done(c, "cs-keel-drift-yard")
