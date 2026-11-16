-- Lantern Lark (dw-lantern-lark), perch sprite 36x36. Opus second pass, hand-built at this size.
-- The lark sits on the sagging lantern string: big head with pill eyes, crest, open orange beak, cream breast,
-- a wing with one pale feather row, a glowing lantern each side. quirk: the violet note it sings.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("dw-lantern-lark-perch", 36)

local LRK  = { "#3e2618", "#62402a", "#8a5e3a", "#b08050", "#d2a874", "#ecd0a4" }
local BRS  = { "#9a7a5a", "#ceb48c", "#efdfbe" }
local LAN  = { "#7a1e2a", "#c0402e", "#ec7a3a", "#fbb860", "#fde4a0" }
local VIO  = { "#3e2a6a", "#6a4aa8", "#a07ad8", "#d0b4f4" }
local STR  = "#6a5450"

local strP = { { 2, 18 }, { 11, 25 }, { 24, 25 }, { 33, 18 } }
local str = HP.mask()
for i = 0, 60 do local x, y = O.bez(strP, i / 60) str:set(math.floor(x + .5), math.floor(y + .5)) end
O.flat(c, str, STR, "string")
for _, L in ipairs({ { 5, 21 }, { 30, 21 } }) do
  local m = c:ellipse(L[1], L[2] + 4, 2.5, 3)
  O.shade(c, m, LAN, { R = 1, amb = .45, wrap = .5, cuts = { .25, .5, .72, .9 }, sep = LAN[1] })
  O.flat(c, c:rect(L[1] - 1, L[2] + 8, L[1] + 1, L[2] + 8), "#5e4848", "cap")
  O.flat(c, c:rect(L[1], L[2] + 9, L[1], L[2] + 10), LAN[2], "tassel")
end
O.shade(c, c:poly{ { 12, 20 }, { 7, 26 }, { 9, 27 }, { 14, 22 } }, LRK, { R = 1, amb = .3, sep = LRK[1] })
O.shade(c, c:ellipse(17, 19, 6, 5), LRK, { sphere = { 15, 17, 7 }, amb = .2, wrap = .4, sep = LRK[1], rim = true, bounce = "#7a6aa8", bmax = 2 })
O.shade(c, c:ellipse(20, 20, 3, 3.5), BRS, { R = 1, amb = .4, cuts = { .35, .7 } })
O.dots(c, { { 19, 19 }, { 21, 21 } }, LRK[3])
O.shade(c, c:poly{ { 12, 17 }, { 17, 16 }, { 18, 20 }, { 11, 22 } }, LRK, { R = 1, amb = .25, sep = LRK[1] })
O.dots(c, { { 13, 19 }, { 15, 18 }, { 17, 18 } }, LRK[6])
O.shade(c, c:ellipse(20, 10, 5.5, 4.5), LRK, { sphere = { 18, 8, 6 }, amb = .25, wrap = .4, sep = LRK[1], rim = true })
O.shade(c, c:poly{ { 16, 7 }, { 13, 2 }, { 15, 3 }, { 19, 6 } }, LRK, { R = 1, amb = .3, sep = LRK[1] })
O.flat(c, c:rect(25, 9, 27, 9), LAN[3], "beak") O.dot(c, 28, 9, LAN[3]) O.dots(c, { { 25, 11 }, { 26, 11 }, { 27, 12 } }, LAN[2])
O.flat(c, c:ellipse(19.5, 10.5, 4, 2.5), BRS[3], "face") O.dots(c, { { 16, 12 }, { 23, 12 }, { 17, 13 }, { 22, 13 } }, BRS[2]) -- pale face mask
c:eyeSmall(17, 9) c:eyeSmall(21, 9)
O.dot(c, 16, 12, "#f5809f") O.dot(c, 23, 12, "#f5809f")
local note = c:rect(29, 5, 30, 6) note:add(c:rect(30, 1, 30, 4)) note:add(c:rect(31, 1, 32, 1))
O.shade(c, note, VIO, { R = 1, amb = .45, cuts = { .3, .55, .8 } })
O.shift(c, 0, 1)
O.done(c, "dw-lantern-lark-perch")
