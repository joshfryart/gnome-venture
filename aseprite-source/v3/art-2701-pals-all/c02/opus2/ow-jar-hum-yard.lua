-- Jar Hum (ow-jar-hum), yard sprite 64x64. Opus second pass (art-2701-pals-all/c02/opus2), built on the Haiku pass.
-- Brewroot, common, Olivewhistle. "Hums at the oil jars until they hum back."
-- A terracotta oil amphora: narrow neck with a rolled lip, two loop handles, a round belly and a small ring foot,
-- stoppered with a cork that has a wooden peg through it (peg knob). A cream painted band with a dark wave
-- pattern runs round the shoulder; the face sits on the belly below it, mouth a small round "o" mid-hum.
-- Fix vs Haiku: it read as a red potion flask with sparkle dots; now a true amphora (handles, foot, glaze band)
-- in fired-clay oranges, and the hum is two gold music notes instead of 2 px dots.
-- quirk: a tiny oil jar beside it is humming back, with its own small note.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-jar-hum-yard", 64)

local CLAY = { "#4a2026", "#7a3328", "#a8502e", "#cc7340", "#e69a5c", "#f6c48a" }
local SLIP = { "#7a5a48", "#a88a6c", "#cdb28a", "#e6d0a6", "#f4e4c0", "#fbf0d6" }
local CORK = { "#4e3424", "#7a5636", "#a37a4c", "#c89e66", "#e2c288" }
local PEG  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local GOLD = { "#8a5a1c", "#c98a26", "#f0b83a", "#fde08a" }

c:groundShadow(32, 57, 23, 2.5)

-- handles (behind the body): loops from neck to shoulder
for _, sd in ipairs({ -1, 1 }) do
  local hx = function(x) return 28 + sd * x end
  local h = O.tube({ { hx(3), 15 }, { hx(10), 12 }, { hx(9), 22 }, { hx(9), 28 } }, function(t) return 1.5 end)
  O.shade(c, h, CLAY, { R = 1, amb = .25, wrap = .35, rim = true })
end

-- body: belly + shoulders + neck + foot
local body = c:ellipse(28, 38, 15, 13.5)
body:add(c:ellipse(28, 29, 12, 5))
body:add(c:rect(25, 13, 31, 26))
body:add(c:poly{ { 21, 48 }, { 35, 48 }, { 32, 54 }, { 24, 54 } })
body:add(c:rect(23, 54, 33, 56))
local bb = {}
body:each(function(x, y)
  if y >= 54 then bb[K(x, y)] = -1 end
  if y == 53 then bb[K(x, y)] = -2 end -- foot groove
  if y == 24 or y == 25 then if x >= 25 and x <= 31 then bb[K(x, y)] = -1 end end -- neck join
end)
local bI, bT = O.shade(c, body, CLAY, { sphere = { 22, 30, 22 }, bias = bb, amb = .2, wrap = .35, rim = true, bounce = "#6a5a8a", bmax = 2 })
-- clay texture: faint wheel rings
O.tex(c, bI, bT, CLAY, function(x, y, i) if (y % 4 == 0) and H(x, y, 3) > .55 and i >= 3 and i <= 5 and y > 44 then return -1 end end)
-- painted shoulder band (cream slip) with a dark running-wave pattern
O.retone(c, bI, bT, SLIP, function(x, y, i) return y >= 27 and y <= 31 end)
local wave = { [0] = 31, 30, 29, 29, 30, 31 }
O.retone(c, bI, bT, { "#3a2026", "#4a2a2c", "#5a3430", "#6a3e34", "#6a3e34", "#6a3e34" }, function(x, y, i)
  return (y == 27) or (y == 31 and x % 2 == 0) or (y == wave[x % 6] and y >= 29) or (y == 28 and x % 6 == 3)
end)
-- rolled lip
local lip = c:ellipse(28, 13, 5.5, 1.6)
O.shade(c, lip, CLAY, { R = 1, amb = .35, sep = CLAY[2], rim = true })

-- cork + peg (peg knob)
local cork = c:rect(24, 7, 32, 11)
cork:cut(c:rect(24, 7, 24, 7)) cork:cut(c:rect(32, 7, 32, 7))
local kI, kT = O.shade(c, cork, CORK, { R = 2, amb = .25, wrap = .35, sep = CORK[1], cuts = { .25, .45, .65, .84 } })
O.tex(c, kI, kT, CORK, function(x, y, i) if H(x, y, 9) > .78 then return -1 end end) -- cork pores
local peg = c:rect(27, 3, 29, 6) peg:cut(c:rect(27, 3, 27, 3)) peg:cut(c:rect(29, 3, 29, 3))
O.shade(c, peg, PEG, { R = 1, amb = .3, sep = PEG[1], cuts = { .3, .55, .8 } })
O.dot(c, 27, 4, PEG[4])

-- face on the belly
c:eyeLocked(20, 35)
c:eyeLocked(31, 35)
O.dots(c, { { 18, 42 }, { 19, 42 } }, "#f5809f") O.dots(c, { { 37, 42 }, { 38, 42 } }, "#f5809f")
-- humming mouth: small "o"
O.dots(c, { { 27, 42 }, { 28, 42 }, { 26, 43 }, { 29, 43 }, { 27, 44 }, { 28, 44 } }, P.ink)
O.dots(c, { { 27, 43 }, { 28, 43 } }, "#7a2c34")
-- one bright glaze spec on the belly
O.dots(c, { { 17, 33 }, { 17, 34 } }, CLAY[6])

-- music notes (outlined parts so they read at 1x)
local function note(x, y, double)
  O.flat(c, c:rect(x, y + 4, x + 2, y + 5), GOLD[3], "note")
  O.dot(c, x, y + 4, GOLD[4])
  O.flat(c, c:rect(x + 2, y, x + 2, y + 3), GOLD[2], "note")
  if double then
    O.flat(c, c:rect(x + 5, y + 3, x + 7, y + 4), GOLD[3], "note")
    O.dot(c, x + 5, y + 3, GOLD[4])
    O.flat(c, c:rect(x + 7, y - 1, x + 7, y + 2), GOLD[2], "note")
    O.dots(c, { { x + 3, y }, { x + 4, y }, { x + 5, y - 1 }, { x + 6, y - 1 } }, GOLD[2])
  else
    O.dots(c, { { x + 3, y + 1 }, { x + 4, y + 2 } }, GOLD[2]) -- flag
  end
end
note(5, 26, true)
note(46, 10, false)

-- quirk: the tiny oil jar humming back
local tj = c:ellipse(53, 50, 5, 5)
tj:add(c:rect(51, 43, 55, 46))
tj:add(c:rect(51, 54, 55, 56))
local tI, tTk = O.shade(c, tj, CLAY, { sphere = { 50, 46, 9 }, amb = .2, wrap = .35, rim = true, bounce = "#6a5a8a", bmax = 2 })
O.retone(c, tI, tTk, SLIP, function(x, y, i) return y == 47 end)
O.shade(c, c:ellipse(53, 43, 3.5, 1), CLAY, { R = 1, amb = .35, sep = CLAY[2] })
O.flat(c, c:rect(52, 40, 54, 42), CORK[3], "cork")
O.dot(c, 52, 40, CORK[5])
O.dots(c, { { 51, 49 }, { 51, 50 }, { 55, 49 }, { 55, 50 } }, P.ink) -- tiny eyes
O.dots(c, { { 53, 52 }, { 53, 53 } }, P.ink) -- tiny "o"
O.dots(c, { { 50, 51 }, { 56, 51 } }, "#f5809f")
note(55, 32, false)

O.shift(c, 0, 1)
O.done(c, "ow-jar-hum-yard")
