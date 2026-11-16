-- Tail Tick (pl-dlz-3), perch sprite 36x36. Opus second pass (c11/opus2), hand-built at this size.
-- Golden leopard gecko on a flat stone: broad smiling head to us, brown spots, round toe pads, fat banded tail
-- arched up and over. 2x3 pill eyes. quirk: the tail tip knocking a pebble, with tick marks.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-dlz-3-perch", 36)

local GECK = { "#4a2a1c", "#7a4a1e", "#b07822", "#daa834", "#f0cc56", "#fbe892" }
local SPOT = "#6e4430"
local BAND = { "#3e2a2a", "#5e3e30", "#7e5636", "#a07440", "#c09454" }
local STON = { "#2c2838", "#463e52", "#625a6c", "#827a8a", "#a6a0aa", "#c8c2c4" }
local PEBL = { "#4a3a3a", "#6e5c56", "#968276", "#bca898" }

c:groundShadow(17, 33, 15, 1)
O.shade(c, c:poly{ { 3, 30 }, { 5, 27 }, { 21, 27 }, { 24, 29 }, { 23, 32 }, { 4, 32 } }, STON, { R = 2, amb = .3, wrap = .4, rim = true })
O.shade(c, c:ellipse(30, 30.5, 2.5, 1.5), PEBL, { sphere = { 29, 29, 3 }, amb = .3, wrap = .4, cuts = { .25, .5, .78 } })
local tail, tn, TT = O.tube({ { 20, 24 }, { 22, 8 }, { 33, 9 }, { 30, 27 } }, function(t) return 3 * (1 - .7 * t) + .4 end)
local tI, tT = O.shadeN(c, tail, tn, GECK, { amb = .35, wrap = .45, rim = true, sep = GECK[1] })
tail:each(function(x, y)
  local t = TT[K(x, y)] local q = y * c.w + x
  if t and c.own[q] == tT and (t * 7) % 1 < .3 and t > .12 then c.pix[q] = BAND[math.max(1, math.min(5, (tI[K(x, y)] or 3) - 1))] end
end)
local body = c:ellipse(14, 23, 7.5, 4.5)
O.shade(c, body, GECK, { sphere = { 12, 18, 12 }, amb = .36, wrap = .46, rim = true, sep = GECK[1] })
O.mark(c, { { 12, 21 }, { 16, 22 }, { 19, 21 }, { 14, 25 } }, SPOT)
for _, L in ipairs({ { 8, 26, 5, 28 }, { 18, 26, 20, 28 } }) do
  O.flat(c, c:rect(math.min(L[1], L[3]), L[2], math.max(L[1], L[3]), L[4] - 1), GECK[3], "leg")
  O.dots(c, { { L[3] - 1, L[4] }, { L[3] + 1, L[4] } }, GECK[5])
end
local head = c:ellipse(9, 17, 7, 5.5)
O.shade(c, head, GECK, { sphere = { 7, 13, 9 }, amb = .36, wrap = .46, rim = true, sep = GECK[1] })
O.mark(c, { { 9, 12 }, { 14, 16 } }, SPOT)
for x = 4, 14 do O.dot(c, x, 19 + ((x == 4 or x == 14) and -1 or 0), P.ink) end
c:eyeSmall(5, 14)
c:eyeSmall(12, 14)
O.dot(c, 3, 17, P.petal.base) O.dot(c, 15, 17, P.petal.base)

O.done(c, "pl-dlz-3-perch", function(c)
  for _, p in ipairs({ { 26, 28 }, { 33, 26 }, { 34, 29 } }) do c:put(p[1], p[2], GECK[5]) end
end)
