-- Tail Tick (pl-dlz-3), perch sprite 36x36. Opus richness pass (c11/opus3), hand-built at this size.
-- Golden leopard gecko on a flat stone: broad smiling head to us, bold brown spots, round toe pads, fat banded tail
-- arched up and over. opus3: plum-to-butter 6-tone ramp with lower ambient (no longer flat), cream belly line, brow
-- beads, lit band lips on the tail, bounce on the lower edge. 2x3 pill eyes.
-- quirk: the tail tip knocking a pebble (pale worn dent) with tick marks.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-dlz-3-perch", 36)

local GECK = { "#4c2234", "#86422c", "#bc7228", "#e2a236", "#f6ca58", "#fdea98" }
local BELY = { "#dcb07a", "#f4dcaa" }
local SPOT = "#5e2a2c"
local BAND = { "#3e1e2e", "#5e2e2c", "#82462e", "#a8663a", "#c88a4a" }
local STON = { "#2a2638", "#443c52", "#625a6e", "#847a8c", "#a8a0ae", "#cac4c6" }
local PEBL = { "#3e2e3a", "#625050", "#8c7468", "#b49c8a", "#d6c2ac" }
local BNC = "#5a6a9a"

c:groundShadow(17, 33, 15, 1)
local sI, sT = O.shade(c, c:poly{ { 3, 30 }, { 5, 27 }, { 21, 27 }, { 24, 29 }, { 23, 32 }, { 4, 32 } }, STON, { R = 2, amb = .26, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
O.dots(c, { { 8, 31 }, { 9, 31 }, { 19, 30 } }, STON[2])
O.shade(c, c:ellipse(30, 30.5, 2.5, 1.5), PEBL, { sphere = { 29, 29, 3 }, amb = .25, wrap = .4, cuts = { .22, .42, .62, .82 } })
O.dot(c, 31, 29, PEBL[5])
local tail, tn, TT = O.tube({ { 20, 24 }, { 22, 8 }, { 33, 9 }, { 30, 27 } }, function(t) return 3 * (1 - .7 * t) + .4 end)
local tI, tT = O.shadeN(c, tail, tn, GECK, { amb = .24, wrap = .44, rim = true, bounce = BNC, bmax = 2, sep = GECK[1] })
tail:each(function(x, y)
  local t = TT[K(x, y)] local q = y * c.w + x
  if t and c.own[q] == tT and t > .12 then
    local f = (t * 7) % 1
    if f < .3 then c.pix[q] = BAND[math.max(1, math.min(5, (tI[K(x, y)] or 3) - 1))] end
  end
end)
local body = c:ellipse(14, 23, 7.5, 4.5)
local bI, bT = O.shade(c, body, GECK, { sphere = { 12, 19, 12 }, amb = .36, wrap = .46, rim = true, bounce = BNC, bmax = 2, sep = GECK[1] })
for x = 9, 19 do O.mark(c, { { x, 26 } }, BELY[1]) end
O.mark(c, { { 12, 21 }, { 13, 21 }, { 17, 22 }, { 18, 22 }, { 20, 21 } }, SPOT)
for _, L in ipairs({ { 8, 26, 5, 28 }, { 18, 26, 20, 28 } }) do
  O.flat(c, c:rect(math.min(L[1], L[3]), L[2], math.max(L[1], L[3]), L[4] - 1), GECK[3], "leg")
  O.dot(c, math.min(L[1], L[3]), L[2], GECK[4])
  O.dots(c, { { L[3] - 1, L[4] }, { L[3] + 1, L[4] } }, GECK[5])
end
local head = c:ellipse(9, 17, 7, 5.5)
O.shade(c, head, GECK, { sphere = { 6, 13, 9 }, amb = .3, wrap = .46, rim = true, bounce = BNC, bmax = 2, sep = GECK[1] })
O.mark(c, { { 9, 12 }, { 15, 16 } }, SPOT)
O.dots(c, { { 5, 20 }, { 6, 20 }, { 12, 20 }, { 13, 20 } }, BELY[1]) O.dots(c, { { 7, 20 }, { 8, 20 }, { 9, 20 }, { 10, 20 }, { 11, 20 } }, BELY[2])
for x = 4, 14 do O.dot(c, x, 19 + ((x == 4 or x == 14) and -1 or 0), P.ink) end
O.dots(c, { { 4, 13 }, { 5, 13 }, { 12, 13 }, { 13, 13 } }, GECK[6]) -- brow beads
c:eyeSmall(5, 14)
c:eyeSmall(12, 14)
O.dot(c, 3, 17, P.petal.base) O.dot(c, 15, 17, P.petal.base)

O.done(c, "pl-dlz-3-perch", function(c)
  for _, p in ipairs({ { 26, 28 }, { 33, 26 }, { 34, 29 } }) do c:put(p[1], p[2], GECK[5]) end
end)
