local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-heart-red: glossy red heart with a big gloss. quirk: a sticking plaster across the lower left.
local c = D.new("ico-heart-red")
local R = { "#5a1530", "#8a2038", "#c5303c", "#e8473c", "#ff6a50", "#ffa890" }
local h = D.heart(32, 31, 21)
D.lit(h, R, 10, { amb = 0.05 })
D.fill(D.ell(21, 21, 4, 3, -.6):clip(h), R[6]) D.px(15, 25, R[6])
D.fill(D.ell(34, 17, 2, 1):clip(h), R[5])
-- plaster
local pl = D.rot(D.rect(17, 36, 36, 42), 26, 39, 0.7):clip(h)
D.lit(pl, D.CREAM, 2, { amb = 0.2 })
D.fill(D.rot(D.rect(24, 36, 29, 42), 26, 39, 0.7):clip(h), "#d9b48a")
D.px(26, 38, "#b88a62") D.px(27, 40, "#b88a62")
D.fin()
