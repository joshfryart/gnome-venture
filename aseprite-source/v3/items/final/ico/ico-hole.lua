local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-hole: round burrow hole in a grassy mound. quirk: two small eyes peer out of the dark.
local c = D.new("ico-hole")
local DIRT = D.BRN
c:groundShadow(32, 54, 24, 3)
D.lit(D.ell(32, 40, 25, 15), D.GREEN, 12, { amb = 0.1 })
for _, p in ipairs({ { 12, 32 }, { 20, 27 }, { 46, 28 }, { 53, 36 }, { 15, 45 }, { 49, 47 } }) do D.fill(D.rect(p[1], p[2], p[1] + 1, p[2] + 2), D.GREEN[5]) D.px(p[1], p[2] + 2, D.GREEN[2]) end
D.lit(D.ell(32, 42, 18, 10), DIRT, 6, { amb = 0.1 })
local hole = D.ell(32, 41, 15, 8)
D.fill(hole, "#1e1020") D.fill(D.ell(32, 43, 12, 5):clip(hole), "#2a1830")
-- lower dirt lip highlight
D.fill(D.sub(D.ell(32, 42, 16, 9), D.ell(32, 41, 15, 8)):clip(D.rect(0, 45, 63, 63)), DIRT[5])
-- eyes
D.fill(D.rect(26, 40, 28, 42), D.CR) D.fill(D.rect(36, 40, 38, 42), D.CR)
D.px(27, 41, D.INK) D.px(37, 41, D.INK) D.px(28, 41, D.INK) D.px(38, 41, D.INK)
-- pebble
D.lit(D.ell(50, 52, 3, 2), D.STEEL, 2)
D.fin()
