-- Dragon Dart (br-dragon-dart), yard 64x64. Haiku first pass, c07. Thornblade, rare, Blossomreach.
-- A sea-blue dragonfly on four petal and sky paper wings. Rare, so a sparkle.
-- quirk: a cream wink sparkle beside one eye (it winks at the Long Wall).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("br-dragon-dart-yard", 64)

-- upper wings
local wL = c:poly{ { 30, 30 }, { 14, 12 }, { 6, 18 }, { 10, 28 }, { 28, 36 } }
local wR = c:poly{ { 34, 30 }, { 50, 12 }, { 58, 18 }, { 54, 28 }, { 36, 36 } }
c:part(wL, "petal")
c:part(wR, "petal")
c:fillMask(c:line({ { 29, 31 }, { 12, 18 } }, 1), P.petal.deep)
c:fillMask(c:line({ { 35, 31 }, { 52, 18 } }, 1), P.petal.deep)
-- lower wings
c:part(c:poly{ { 30, 36 }, { 16, 36 }, { 14, 46 }, { 28, 44 } }, "sky")
c:part(c:poly{ { 34, 36 }, { 48, 36 }, { 50, 46 }, { 36, 44 } }, "sky")
-- tail, then body with segment bands
c:part(c:poly{ { 31, 52 }, { 33, 52 }, { 32, 60 } }, "sea")
c:part(c:rect(30, 27, 34, 53), "sea", { band = 1 })
c:fillMask(c:line({ { 29, 36 }, { 35, 36 } }, 1), P.sea.deep)
c:fillMask(c:line({ { 29, 43 }, { 35, 43 } }, 1), P.sea.deep)
c:fillMask(c:line({ { 29, 50 }, { 35, 50 } }, 1), P.sea.deep)
-- head
c:part(c:ellipse(32, 22, 6, 5), "moss", { band = 2 })
c:eyeLocked(26, 19)
c:eyeLocked(33, 19)
c:px(30, 24, P.ink) c:px(31, 25, P.ink) c:px(32, 25, P.ink) c:px(33, 24, P.ink)
-- wink sparkle (quirk) and a rare sparkle on the wing tip
c:sparkle(41, 14)
c:sparkle(12, 40)

M.done(c, "br-dragon-dart-yard")
