-- Stilt Stoop (mt-stilt-stoop), yard 64x64. Haiku first pass, c07. Seedkeeper, common, Monsoontangle.
-- A round gold creature on two tall wood stilts, in a moss hat, standing over a canal ripple.
-- quirk: one skinA arm raised in a wave.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-stilt-stoop-yard", 64)

-- canal ripple under the stilts
c:part(c:ellipse(31, 61, 15, 2), "sea", { noshade = true })
-- stilts
c:part(c:line({ { 25, 40 }, { 22, 60 } }, 2), "wood")
c:part(c:line({ { 37, 40 }, { 40, 60 } }, 2), "wood")
-- arms (behind the body): waving arm and resting arm
c:part(c:line({ { 42, 30 }, { 51, 17 } }, 2), "skinA")
c:part(c:ellipse(52, 14, 3, 3), "skinA")
c:part(c:line({ { 20, 36 }, { 15, 42 } }, 2), "skinA")
-- body
c:part(c:ellipse(31, 30, 13, 12), "gold", { band = 3 })
-- moss hat
c:part(c:ellipse(31, 18, 7, 7), "moss", { band = 2 })
c:part(c:rect(18, 20, 44, 21), "moss")
-- face
c:eyeLocked(24, 27)
c:eyeLocked(34, 27)
c:cheek(21, 33) c:cheek(38, 33)
c:px(29, 34, P.ink) c:px(30, 35, P.ink) c:px(31, 35, P.ink) c:px(32, 34, P.ink)

M.done(c, "mt-stilt-stoop-yard")
