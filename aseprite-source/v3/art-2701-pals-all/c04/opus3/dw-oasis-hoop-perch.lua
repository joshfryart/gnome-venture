-- Oasis Hoop (dw-oasis-hoop), perch sprite 36x36. Opus richness pass (c04/opus3), hand-built at this size.
-- Richness pass: hue-shifted ramps, three bold dyed-cord bindings, a few plait grooves, leaflet midrib, a ripple and
-- a floating date in the pool; the hole now holds only two small dates on a stalk, so it reads as a hole again
-- (opus2's three dates filled it). From opus2:
-- the straw hoop with fewer, bolder bindings, one palm leaflet, the face (2x3 pills, ink smile, cheeks) on the
-- thick lower band clear of the water, a short pool under it.
-- quirk: two dates on a forked stalk hanging high in the hole (never a second pair of eyes: stacked off-level, brown).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("dw-oasis-hoop-perch", 36)

local STRAW = { "#45222c", "#7a4428", "#a8702e", "#d29c40", "#edc466", "#fae6aa" }
local CORD  = { "#3a1a26", "#5e2a2a", "#8a3e2c", "#b25a34", "#d27e48", "#e8a464" }
local WATER = { "#1c3450", "#235a7a", "#2c8496", "#4cb0b2", "#84d4c6", "#c6eedc" }
local DATE  = { "#361626", "#64242a", "#94402c", "#c46834", "#e8a05a" }
local LEAF  = { "#1c443e", "#2b6648", "#478c4e", "#70b25a", "#a6d274" }

local pool = c:ellipse(18, 29, 15, 3.2)
local pv = {}
pool:each(function(x, y) local dx, dy = (x - 18) / 15, (y - 29) / 3.2 pv[K(x, y)] = .3 + .45 * (1 - dx * dx - dy * dy) end)
local _, poolT = X.tone(c, pool, pv, WATER, { cuts = { .2, .35, .5, .62, .8 } })

local CX, CY, RO, RI, HY = 18, 17, 12, 5.6, 13.8
local hoop, hn = HP.mask(), {}
for y = CY - RO - 1, CY + RO + 1 do for x = CX - RO - 1, CX + RO + 1 do
  local dx, dy = x + .5 - CX - .5, y - CY
  local d = math.sqrt(dx * dx + dy * dy)
  local dh = math.sqrt(dx * dx + ((y - HY) * 1.1) ^ 2)
  if d <= RO and dh > RI then
    hoop:set(x, y)
    local ux, uy = dx / math.max(d, .01), dy / math.max(d, .01)
    local inner = RI + (CY - HY) * uy
    local mid, half = (RO + inner) / 2, (RO - inner) / 2
    local s = math.max(-.95, math.min(.95, (d - mid) / (half + .6)))
    hn[K(x, y)] = { ux * s, uy * s, math.sqrt(1 - s * s) }
  end
end end
local hI, hT = O.shadeN(c, hoop, hn, STRAW, { amb = .1, wrap = .3, rim = true, bounce = "#4f8a8a", bmax = 2, sep = STRAW[1] })
O.tex(c, hI, hT, STRAW, function(x, y, i)
  local a = math.atan(y - CY, x - CX)
  local d = math.sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
  if y > 19 and math.abs(x - CX) < 10 then return end
  if ((a / (2 * math.pi) * 14 + d * .3) % 1) < .14 and i >= 3 then return -1 end -- plait grooves
end)
O.tex2(c, hI, hT, CORD, function(x, y, i)
  local dx, dy = x - CX, y - CY
  for _, th in ipairs({ -2.35, -.8, 3.05, .1 }) do
    local ux, uy = math.cos(th), math.sin(th)
    local along, across = dx * ux + dy * uy, math.abs(-dx * uy + dy * ux)
    if along > 0 and across < 1.1 then return (math.floor(along) % 2 == 0) and 0 or -1 end
  end
end)

-- one palm leaflet
local m, n, T, S = O.tube({ { 16, 6 }, { 16, 3 }, { 19, 1 }, { 23, 1 } }, function(t) return 1.6 * math.sin(math.min(1, t * 1.15) * math.pi) + .3 end)
local lI, lT = O.shadeN(c, m, n, LEAF, { amb = .3, wrap = .4, sep = LEAF[1] })
O.tex(c, lI, lT, LEAF, function(x, y, i) if math.abs(S[K(x, y)] or 1) < .25 then return -1 end end)

-- quirk: two dates on a forked stalk, high in the hole
O.dots(c, { { 18, 9 }, { 18, 10 }, { 17, 11 }, { 19, 11 } }, "#7a5a3a")
O.flat(c, c:rect(15, 12, 16, 14), DATE[3], "date") O.dot(c, 15, 12, DATE[5]) O.dots(c, { { 16, 14 }, { 16, 13 } }, DATE[2])
O.flat(c, c:rect(19, 12, 20, 15), DATE[4], "date") O.dot(c, 19, 12, DATE[5]) O.dots(c, { { 20, 15 }, { 20, 14 } }, DATE[2]) O.dot(c, 19, 14, DATE[3])

-- water over the hoop foot
hoop:each(function(x, y) if y >= 28 then c:put(x, y, y == 28 and WATER[5] or WATER[3], poolT) end end)
O.dots(c, { { 4, 28 }, { 5, 28 }, { 31, 28 }, { 32, 28 } }, WATER[6])
O.dots(c, { { 9, 30 }, { 10, 30 }, { 11, 30 }, { 23, 30 }, { 24, 30 } }, WATER[5])
-- floating date with a ripple
O.flat(c, c:rect(28, 29, 29, 29), DATE[4], "fdate") O.dot(c, 28, 29, DATE[5])
O.dots(c, { { 27, 30 }, { 30, 30 } }, WATER[6])

-- face
c:eyeSmall(12, 21)
c:eyeSmall(22, 21)
O.dot(c, 10, 24, "#f5809f") O.dot(c, 26, 24, "#f5809f")
O.dots(c, { { 16, 24 }, { 17, 25 }, { 18, 25 }, { 19, 24 } }, P.ink)

O.shift(c, 0, 1)
O.done(c, "dw-oasis-hoop-perch")
