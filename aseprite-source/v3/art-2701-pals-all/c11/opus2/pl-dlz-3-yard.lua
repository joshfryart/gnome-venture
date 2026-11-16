-- Tail Tick (pl-dlz-3), yard sprite 64x64. Opus second pass (c11/opus2), built on c11/haiku.
-- Seedkeeper, common, Dragonlizard Den. "Ticks its tail against every rock on the path just to hear it."
-- haiku drew a blue bean with a hose for a tail. Now a leopard gecko: low and wide on a flat stone, broad smiling
-- head turned to us, round sticky toe pads, golden skin with brown leopard spots, and a fat banded tail.
-- quirk: the tail swung up and over, its tip knocking a pebble, with little "tick" marks where it lands.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-dlz-3-yard", 64)

local GECK = { "#4a2a1c", "#7a4a1e", "#b07822", "#daa834", "#f0cc56", "#fbe892" }
local SPOT = { "#4e2e24", "#6e4430" }
local BAND = { "#3e2a2a", "#5e3e30", "#7e5636", "#a07440", "#c09454" }
local STON = { "#2c2838", "#463e52", "#625a6c", "#827a8a", "#a6a0aa", "#c8c2c4" }
local PEBL = { "#4a3a3a", "#6e5c56", "#968276", "#bca898" }

c:groundShadow(30, 58, 25, 2.5)

-- flat stone slab under the gecko
local slab = c:poly{ { 6, 52 }, { 10, 47 }, { 38, 46 }, { 44, 50 }, { 42, 56 }, { 8, 57 } }
local sI, sT = O.shade(c, slab, STON, { R = 3, amb = .25, wrap = .4, rim = true })
O.tex(c, sI, sT, STON, function(x, y, i) if H(x, y, 3) > .86 then return -1 end if y >= 52 and (x + y * 3) % 9 == 0 then return -1 end end)
O.dots(c, { { 14, 53 }, { 15, 54 }, { 16, 54 }, { 30, 52 }, { 31, 53 } }, STON[2]) -- cracks

-- pebble the tail is knocking
local peb = c:ellipse(55, 55, 4, 3)
O.shade(c, peb, PEBL, { sphere = { 53, 53, 5 }, amb = .25, wrap = .4, cuts = { .25, .5, .78 }, rim = true })

-- fat banded tail: up and over, tip coming down on the pebble
local tail, tn, TT = O.tube({ { 36, 41 }, { 42, 10 }, { 63, 16 }, { 55, 51 } }, function(t) return 5.2 * (1 - .72 * t) + .6 end)
local tI, tT = O.shadeN(c, tail, tn, GECK, { amb = .32, wrap = .45, rim = true, bounce = "#5a6a9a", bmax = 2, sep = GECK[1] })
tail:each(function(x, y)
  local t = TT[K(x, y)] local q = y * c.w + x
  if t and c.own[q] == tT and (t * 9) % 1 < .32 and t > .12 then
    c.pix[q] = BAND[math.max(1, math.min(5, (tI[K(x, y)] or 3) - 1))]
  end
end)

-- body, low and wide
local body = c:ellipse(26, 41, 13, 7.5)
local bI, bT = O.shade(c, body, GECK, { sphere = { 22, 32, 22 }, amb = .36, wrap = .46, rim = true, bounce = "#5a6a9a", bmax = 2, sep = GECK[1] })
-- leopard spots
for _, q in ipairs({ { 22, 39 }, { 27, 38 }, { 32, 40 }, { 18, 43 }, { 25, 43 }, { 30, 45 }, { 35, 42 }, { 21, 46 } }) do
  O.mark(c, { { q[1], q[2] }, { q[1] + 1, q[2] } }, SPOT[2]) O.mark(c, { { q[1], q[2] + 1 } }, SPOT[1])
end
-- legs splayed, sticky round toe pads
for _, L in ipairs({ { 15, 45, 9, 49 }, { 22, 47, 20, 51 }, { 33, 46, 37, 50 }, { 37, 44, 42, 47 } }) do
  local m, n = O.tube({ { L[1], L[2] }, { (L[1] + L[3]) / 2, L[2] + 1 }, { L[3], L[4] - 1 }, { L[3], L[4] } }, function(t) return 1.7 - .3 * t end)
  O.shadeN(c, m, n, GECK, { amb = .3, wrap = .4, sep = GECK[1] })
  for _, d in ipairs({ { -2, 1 }, { 0, 2 }, { 2, 1 } }) do
    O.flat(c, c:rect(L[3] + d[1], L[4] + d[2], L[3] + d[1], L[4] + d[2]), GECK[5], "toe")
  end
end

-- head, broad and turned to us
local head = c:ellipse(16, 31, 11, 8.5)
local hI, hT = O.shade(c, head, GECK, { sphere = { 12, 25, 18 }, amb = .36, wrap = .46, rim = true, bounce = "#5a6a9a", bmax = 2, sep = GECK[1] })
O.mark(c, { { 15, 24 }, { 16, 24 }, { 13, 26 }, { 25, 30 }, { 24, 35 }, { 7, 31 } }, SPOT[2])
-- wide gecko smile
for x = 9, 23 do O.dot(c, x, 35 + ((x == 9 or x == 23) and -1 or 0), P.ink) end
O.dots(c, { { 10, 36 }, { 11, 36 }, { 21, 36 }, { 22, 36 } }, GECK[6])
O.dots(c, { { 14, 31 }, { 18, 31 } }, GECK[1]) -- nostrils
c:eyeLocked(8, 24)
c:eyeLocked(20, 24)
c:cheek(6, 32) c:cheek(25, 32)

O.done(c, "pl-dlz-3-yard", function(c)
  -- "tick!" marks round the pebble
  for _, p in ipairs({ { 50, 50 }, { 49, 49 }, { 61, 49 }, { 62, 48 }, { 60, 53 }, { 61, 53 }, { 58, 47 }, { 58, 46 } }) do c:put(p[1], p[2], "#f0cc56") end
end)
