-- Lantern Lark (dw-lantern-lark), yard sprite 64x64. Opus second pass (art-2701-pals-all/c03/opus3), built on the
-- Haiku first pass. Common, seedkeeper, Dunewhisper. "Sings to the lantern strings until the sky turns violet."
-- A plump crested desert lark perched right on a sagging lantern string (the string is its perch now, the first
-- pass had a branch and one lantern hanging off its beak). Big 3/4 head so both locked eyes fit, open singing beak,
-- pointed crest, streaked cream breast, a folded wing with clear feather rows and pale edges (no longer a smear),
-- tail dipping behind the string. Two glowing paper lanterns hang from the string either side.
-- quirk: the note it sings is violet, the colour the sky is about to turn.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("dw-lantern-lark-yard", 64)

local LRK  = { "#3e2618", "#62402a", "#8a5e3a", "#b08050", "#d2a874", "#ecd0a4" }
local BRS  = { "#9a7a5a", "#ceb48c", "#efdfbe" }
local LAN  = { "#7a1e2a", "#c0402e", "#ec7a3a", "#fbb860", "#fde4a0" }
local CAPS = { "#3a2a2e", "#5e4848" }
local VIO  = { "#3e2a6a", "#6a4aa8", "#a07ad8", "#d0b4f4" }
local STR  = "#6a5450"

-- the lantern string, sagging across
local strP = { { 3, 30 }, { 20, 41 }, { 44, 41 }, { 60, 30 } }
local str = HP.mask()
for i = 0, 80 do local x, y = O.bez(strP, i / 80) str:set(math.floor(x + .5), math.floor(y + .5)) end
O.flat(c, str, STR, "string")
local function strY(x) local best, by = 1e9, 0 for i = 0, 80 do local bx, yy = O.bez(strP, i / 80) if math.abs(bx - x) < best then best, by = math.abs(bx - x), yy end end return math.floor(by + .5) end

-- paper lanterns hanging from the string
local function lantern(cx, top)
  O.flat(c, c:rect(cx, top, cx, top + 2), STR, "hang")
  O.flat(c, c:rect(cx - 2, top + 3, cx + 2, top + 3), CAPS[2], "cap")
  local m = c:ellipse(cx, top + 8.5, 4.5, 5)
  local idx, tok = O.shade(c, m, LAN, { sphere = { cx - 1, top + 7, 6 }, amb = .45, wrap = .5, cuts = { .25, .5, .72, .9 }, sep = LAN[1] })
  O.tex(c, idx, tok, LAN, function(x, y, i) if (y - top) % 3 == 0 and i >= 2 then return -1 end end) -- paper ribs
  O.flat(c, c:rect(cx - 2, top + 14, cx + 2, top + 14), CAPS[2], "cap")
  O.flat(c, c:rect(cx, top + 15, cx, top + 17), LAN[2], "tassel")
end
lantern(10, strY(10) + 1)
lantern(54, strY(54) + 1)

-- tail dipping behind the string
O.shade(c, c:poly{ { 23, 34 }, { 14, 44 }, { 17, 46 }, { 27, 38 } }, LRK, { R = 1, amb = .3, sep = LRK[1] })
O.dots(c, { { 17, 43 }, { 19, 41 }, { 21, 39 } }, LRK[1])

-- body
local body = c:ellipse(30, 32, 9.5, 8)
local bI, bT = O.shade(c, body, LRK, { sphere = { 27, 28, 12 }, amb = .2, wrap = .4, sep = LRK[1], rim = true, bounce = "#7a6aa8", bmax = 2 })
-- streaked cream breast
local brs = c:ellipse(34, 34, 5, 5.5)
local rI, rT = O.shade(c, brs, BRS, { R = 2, amb = .4, cuts = { .35, .7 } })
O.dots(c, { { 33, 31 }, { 35, 32 }, { 32, 34 }, { 34, 35 }, { 36, 34 }, { 33, 37 }, { 35, 38 } }, LRK[3])
-- folded wing with feather rows
local wing = c:poly{ { 21, 29 }, { 30, 27 }, { 32, 32 }, { 28, 37 }, { 19, 36 } }
local wI, wT = O.shade(c, wing, LRK, { R = 2, amb = .25, sep = LRK[1] })
for _, row in ipairs({ { { 23, 31 }, { 25, 30 }, { 27, 30 }, { 29, 30 } }, { { 21, 34 }, { 23, 33 }, { 25, 33 }, { 27, 33 }, { 29, 33 } } }) do
  O.mark(c, row, LRK[6])
end
O.mark(c, { { 22, 35 }, { 24, 35 }, { 26, 35 }, { 24, 32 }, { 26, 32 }, { 28, 32 } }, LRK[1])
-- claws gripping the string
O.dots(c, { { 28, strY(28) - 1 }, { 33, strY(33) - 1 } }, LRK[2])

-- head, 3/4 front, with crest and open singing beak
local hd = c:ellipse(35, 18, 7.5, 6.5)
local hI, hT = O.shade(c, hd, LRK, { sphere = { 32, 15, 9 }, amb = .25, wrap = .4, sep = LRK[1], rim = true })
O.tex(c, hI, hT, LRK, function(x, y, i) if y <= 14 and (x + y) % 3 == 0 and i >= 2 then return -1 end end) -- crown streaks
O.shade(c, c:poly{ { 30, 13 }, { 26, 5 }, { 29, 6 }, { 34, 12 } }, LRK, { R = 1, amb = .3, sep = LRK[1] }) -- crest
O.mark(c, { { 32, 20 }, { 33, 20 }, { 37, 20 }, { 38, 20 } }, BRS[3]) -- pale brow/cheek line
O.shade(c, c:poly{ { 42, 17 }, { 47, 16 }, { 42, 19 } }, LAN, { R = 1, amb = .4, cuts = { .25, .5, .72, .9 } }) -- upper beak
O.shade(c, c:poly{ { 42, 20 }, { 46, 22 }, { 42, 21 } }, LAN, { R = 1, amb = .4, cuts = { .25, .5, .72, .9 } }) -- lower beak
c:eyeLocked(30, 15) c:eyeLocked(37, 15)
c:cheek(29, 21) c:cheek(39, 21)

-- quirk: a violet music note
local note = c:ellipse(48.5, 10.5, 2, 1.5)
note:add(c:rect(50, 3, 50, 10)) note:add(c:rect(51, 3, 52, 4)) note:add(c:rect(52, 5, 53, 5))
O.shade(c, note, VIO, { R = 1, amb = .45, cuts = { .3, .55, .8 } })

O.shift(c, 0, 4)
O.done(c, "dw-lantern-lark-yard", function(c)
  c:put(45, 17, VIO[3]) c:put(56, 13, VIO[4])
end)
