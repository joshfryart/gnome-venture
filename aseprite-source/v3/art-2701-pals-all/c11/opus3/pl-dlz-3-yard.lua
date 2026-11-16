-- Tail Tick (pl-dlz-3), yard sprite 64x64. Opus richness pass (c11/opus3), built on c11/opus2.
-- Seedkeeper, common, Dragonlizard Den. "Ticks its tail against every rock on the path just to hear it."
-- Leopard gecko, low and wide on a flat stone, broad smiling head turned to us, round sticky toe pads, fat banded tail.
-- opus3: the flat golden body is now a 6-tone ramp from plum shadow to butter light (lower ambient, so the form turns),
-- a cream belly band, raised tubercle beads (lit dot + lower-right shade), leopard rosettes (dark ring, warm core),
-- brow ridges, a bounce line along the belly, lichen on the slab and a contact shadow under the gecko.
-- quirk: the tail swung up and over, its tip knocking a pebble, "tick" marks where it lands.
-- closer look: the pebble has a pale worn dent right where the tail always hits, and a little seed (seedkeeper)
-- sits tucked against the stone.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-dlz-3-yard", 64)

local GECK = { "#4c2234", "#86422c", "#bc7228", "#e2a236", "#f6ca58", "#fdea98" }
local BELY = { "#b07a52", "#dcb07a", "#f4dcaa" }
local SPOT = { "#4e2230", "#7a3a2c", "#a85e2c" }
local BAND = { "#3e1e2e", "#5e2e2c", "#82462e", "#a8663a", "#c88a4a" }
local STON = { "#2a2638", "#443c52", "#625a6e", "#847a8c", "#a8a0ae", "#cac4c6" }
local LICH = { "#7a8a3e", "#b0bc5a" }
local PEBL = { "#3e2e3a", "#625050", "#8c7468", "#b49c8a", "#d6c2ac" }
local BNC = "#5a6a9a"

c:groundShadow(30, 58, 25, 2.5)

-- flat stone slab under the gecko
local slab = c:poly{ { 6, 52 }, { 10, 47 }, { 38, 46 }, { 44, 50 }, { 42, 56 }, { 8, 57 } }
local sI, sT = O.shade(c, slab, STON, { R = 3, amb = .22, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
O.tex(c, sI, sT, STON, function(x, y, i) if H(x, y, 3) > .86 then return -1 end if y >= 53 and (x + y * 3) % 9 == 0 then return -1 end end)
O.dots(c, { { 14, 53 }, { 15, 54 }, { 16, 54 }, { 17, 55 }, { 30, 52 }, { 31, 53 }, { 32, 53 } }, STON[2]) -- cracks
O.dots(c, { { 15, 53 }, { 31, 52 } }, STON[5]) -- lit lip of the crack
-- lichen crust on the slab front
O.dots(c, { { 36, 53 }, { 37, 53 }, { 37, 54 }, { 38, 52 }, { 10, 55 }, { 11, 55 } }, LICH[1])
O.dots(c, { { 37, 52 }, { 11, 54 } }, LICH[2])

-- pebble the tail is knocking (with a worn pale dent on top)
local peb = c:ellipse(55, 55, 4, 3)
O.shade(c, peb, PEBL, { sphere = { 53, 53, 5 }, amb = .2, wrap = .4, cuts = { .22, .42, .62, .82 }, rim = true, bounce = BNC, bmax = 2 })
O.dots(c, { { 56, 52 }, { 57, 52 } }, PEBL[5]) O.dot(c, 57, 53, PEBL[2])
-- a seed tucked by the slab
O.flat(c, c:ellipse(46.5, 56, 1.5, 1), "#8a5a2e", "seed") O.dot(c, 46, 55, "#c89a5a")

-- fat banded tail: up and over, tip coming down on the pebble
local tail, tn, TT = O.tube({ { 36, 41 }, { 42, 10 }, { 63, 16 }, { 55, 51 } }, function(t) return 5.2 * (1 - .72 * t) + .6 end)
local tI, tT = O.shadeN(c, tail, tn, GECK, { amb = .22, wrap = .42, rim = true, bounce = BNC, bmax = 2, sep = GECK[1] })
O.bumps(c, tI, tT, GECK, 21, .9, 3)
tail:each(function(x, y)
  local t = TT[K(x, y)] local q = y * c.w + x
  if t and c.own[q] == tT and t > .12 then
    local f = (t * 9) % 1
    if f < .32 then c.pix[q] = BAND[math.max(1, math.min(5, (tI[K(x, y)] or 3) - 1))]
    elseif f < .4 and (tI[K(x, y)] or 1) >= 3 then c.pix[q] = GECK[6] end -- lit lip after each band
  end
end)

-- body, low and wide
local body = c:ellipse(26, 41, 13, 7.5)
local bI, bT = O.shade(c, body, GECK, { sphere = { 22, 33, 22 }, amb = .34, wrap = .46, rim = true, bounce = BNC, bmax = 2, sep = GECK[1] })
O.bumps(c, bI, bT, GECK, 7, .91, 3)
-- cream belly band along the lower flank
body:each(function(x, y)
  local q = y * c.w + x
  if c.own[q] == bT and y >= 46 and body:has(x, y + 1) then c.pix[q] = (y == 46 and BELY[3] or BELY[2]) end
end)
-- leopard rosettes: dark ring, warm core
for _, q in ipairs({ { 20, 37 }, { 28, 37 }, { 35, 40 }, { 24, 42 }, { 31, 43 } }) do
  O.mark(c, { { q[1], q[2] }, { q[1] + 1, q[2] }, { q[1] - 1, q[2] + 1 }, { q[1] + 2, q[2] + 1 }, { q[1], q[2] + 2 }, { q[1] + 1, q[2] + 2 } }, SPOT[1])
  O.mark(c, { { q[1], q[2] + 1 }, { q[1] + 1, q[2] + 1 } }, SPOT[3])
end
-- legs splayed, sticky round toe pads
for _, L in ipairs({ { 15, 45, 9, 49 }, { 22, 47, 20, 51 }, { 33, 46, 37, 50 }, { 37, 44, 42, 47 } }) do
  local m, n = O.tube({ { L[1], L[2] }, { (L[1] + L[3]) / 2, L[2] + 1 }, { L[3], L[4] - 1 }, { L[3], L[4] } }, function(t) return 1.7 - .3 * t end)
  O.shadeN(c, m, n, GECK, { amb = .26, wrap = .42, rim = true, sep = GECK[1] })
  for _, d in ipairs({ { -2, 1 }, { 0, 2 }, { 2, 1 } }) do
    O.flat(c, c:rect(L[3] + d[1], L[4] + d[2], L[3] + d[1], L[4] + d[2]), GECK[5], "toe")
  end
end

-- head, broad and turned to us
local head = c:ellipse(16, 31, 11, 8.5)
local hI, hT = O.shade(c, head, GECK, { sphere = { 11, 24, 17 }, amb = .26, wrap = .44, rim = true, bounce = BNC, bmax = 2, sep = GECK[1] })
O.bumps(c, hI, hT, GECK, 5, .93, 3)
-- head spots (small, so the face stays clear)
O.mark(c, { { 15, 24 }, { 16, 24 }, { 25, 30 }, { 25, 31 }, { 6, 30 } }, SPOT[2])
-- pale lip line and throat
O.dots(c, { { 10, 36 }, { 11, 36 }, { 12, 37 }, { 13, 37 }, { 19, 37 }, { 20, 37 }, { 21, 36 }, { 22, 36 } }, BELY[2])
O.dots(c, { { 14, 37 }, { 15, 37 }, { 16, 37 }, { 17, 37 }, { 18, 37 } }, BELY[3])
-- wide gecko smile
for x = 9, 23 do O.dot(c, x, 35 + ((x == 9 or x == 23) and -1 or 0), P.ink) end
O.dots(c, { { 14, 31 }, { 18, 31 } }, GECK[1]) -- nostrils
-- brow ridges above the eyes (a lit bead row)
O.dots(c, { { 8, 23 }, { 9, 22 }, { 10, 22 }, { 11, 22 }, { 20, 22 }, { 21, 22 }, { 22, 22 }, { 23, 23 } }, GECK[6])
c:eyeLocked(8, 24)
c:eyeLocked(20, 24)
c:cheek(6, 32) c:cheek(25, 32)

O.done(c, "pl-dlz-3-yard", function(c)
  -- "tick!" marks round the pebble
  for _, p in ipairs({ { 50, 50 }, { 49, 49 }, { 61, 49 }, { 62, 48 }, { 61, 53 }, { 62, 53 }, { 58, 46 }, { 58, 45 } }) do c:put(p[1], p[2], "#f6ca58") end
end)
