-- Oasis Hoop (dw-oasis-hoop), yard sprite 64x64. Opus second pass (art-2701-pals-all/c04/opus2), from the Haiku pass.
-- Seedkeeper, uncommon, Dunewhisper. "Floats in the oasis pool and keeps a date for every friend."
-- A plump hoop of bound palm straw floating in a teal oasis pool: the face sits on the thick lower band just above
-- the waterline, radial straw bindings round the rest of the ring, two palm leaflets tucked in at the top.
-- Fixed from Haiku: the two dates in the hole read as a second pair of eyes; the face was half under water;
-- the gold knob bumps read as ears. Now the dates hang as a cluster on a string, clearly fruit.
-- quirk: a little sprig of dates hanging inside the hoop, one date for every friend.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("dw-oasis-hoop-yard", 64)

local STRAW = { "#4a2a1e", "#7a4a26", "#a8702e", "#d09a3e", "#ecc062", "#f8e0a0" }
local WATER = { "#1e3a4e", "#25607a", "#2f8a9a", "#4fb4b4", "#86d6c8", "#c4eedd" }
local DATE  = { "#3a1a1e", "#6a2a24", "#9a4428", "#c86a34", "#e8a05a" }
local LEAF  = { "#1f4a3c", "#2f6b46", "#4a8f4e", "#72b35a", "#a2d070" }

-- pool (drawn first, the hoop sits in it)
local pool = c:ellipse(32, 52, 28, 6)
local pv = {}
pool:each(function(x, y)
  local dx, dy = (x - 32) / 28, (y - 52) / 6
  pv[K(x, y)] = .35 + .4 * (1 - (dx * dx + dy * dy)) - (y - 52) * .04
end)
local poolI, poolT = X.tone(c, pool, pv, WATER, { cuts = { .2, .35, .5, .62, .8 } })

-- hoop: torus seen face-on, hole set a little high so the lower band is thick enough for the face
local CX, CY, RO, RI, HY = 32, 31, 20, 8, 28
local hoop, hn = HP.mask(), {}
for y = CY - RO - 1, CY + RO + 1 do for x = CX - RO - 1, CX + RO + 1 do
  local dx, dy = x + .5 - CX - .5, y - CY
  local d = math.sqrt(dx * dx + dy * dy)
  local hdx, hdy = dx, y - HY
  local dh = math.sqrt(hdx * hdx + (hdy * 1.1) ^ 2)
  if d <= RO and dh > RI then
    hoop:set(x, y)
    -- tube centre between hole edge and outer edge along this ray
    local inner = RI + (HY - CY) * (dy / math.max(d, .01)) * -1
    local mid = (RO + inner) / 2
    local half = (RO - inner) / 2
    local s = math.max(-.95, math.min(.95, (d - mid) / (half + .6)))
    local ux, uy = dx / math.max(d, .01), dy / math.max(d, .01)
    hn[K(x, y)] = { ux * s, uy * s, math.sqrt(1 - s * s) }
  end
end end
local hI, hT = O.shadeN(c, hoop, hn, STRAW, { amb = .1, wrap = .3, rim = true, bounce = "#4f8a8a", bmax = 2, sep = STRAW[1] })
-- straw bindings: radial wraps every ~22 degrees, kept off the face band
O.tex(c, hI, hT, STRAW, function(x, y, i)
  local a = math.atan(y - CY, x - CX)
  local f = (a / (2 * math.pi) * 16) % 1
  local face = y > 36 and math.abs(x - CX) < 13
  if not face and f < .2 then return i >= 4 and -2 or -1 end
  if not face and f >= .2 and f < .3 then return 1 end
  if H(x, y, 5) > .95 and i >= 3 then return -1 end -- straw flecks
end)

-- palm leaflets tucked in at the top left
for _, L in ipairs({
  { { 26, 13 }, { 22, 7 }, { 17, 6 }, { 12, 8 } },
  { { 29, 12 }, { 28, 6 }, { 31, 2 }, { 35, 1 } } }) do
  local m, n, T, S = O.tube(L, function(t) return 2.2 * math.sin(math.min(1, t * 1.15) * math.pi) + .3 end)
  local lI, lT = O.shadeN(c, m, n, LEAF, { amb = .25, wrap = .4, sep = LEAF[1] })
  O.tex(c, lI, lT, LEAF, function(x, y, i) if math.abs(S[K(x, y)] or 1) < .2 then return -1 end end) -- midrib
end

-- quirk: a sprig of dates hanging in the hole
O.dots(c, { { 32, 21 }, { 32, 22 }, { 32, 23 } }, "#7a5a3a")
O.dots(c, { { 31, 24 }, { 33, 24 } }, "#7a5a3a")
for _, d in ipairs({ { 28.5, 27 }, { 35.5, 27 }, { 32, 30.5 } }) do
  local m = c:ellipse(d[1], d[2], 1.7, 2.5)
  O.shade(c, m, DATE, { sphere = { d[1] - 1, d[2] - 2, 3.5 }, amb = .3, wrap = .4, sep = DATE[1], cuts = { .2, .4, .6, .82 } })
  O.dot(c, math.floor(d[1] - .5), math.floor(d[2] - 1.5), "#f5c890")
end
O.dots(c, { { 30, 25 }, { 29, 25 }, { 34, 25 }, { 35, 25 } }, "#7a5a3a")

-- water laps over the bottom of the hoop
local lap = HP.mask()
hoop:each(function(x, y) if y >= 50 then lap:set(x, y) end end)
lap:each(function(x, y) c:put(x, y, y == 50 and WATER[5] or WATER[3], poolT) end)
-- foam ring where the hoop meets the water
for x = 9, 55 do if not hoop:has(x, 50) and (x < 13 or x > 51) then end end
O.dots(c, { { 10, 50 }, { 11, 50 }, { 12, 51 }, { 52, 51 }, { 53, 50 }, { 54, 50 } }, WATER[6])
-- ripple rings and glints on the pool
O.dots(c, { { 7, 52 }, { 8, 52 }, { 9, 52 }, { 54, 52 }, { 55, 52 }, { 56, 52 }, { 57, 52 } }, WATER[5])
O.dots(c, { { 10, 55 }, { 11, 55 }, { 12, 56 }, { 50, 56 }, { 51, 55 }, { 52, 55 } }, WATER[2])
O.dots(c, { { 15, 48 }, { 16, 48 }, { 47, 48 }, { 48, 48 } }, WATER[6])
O.dots(c, { { 24, 54 }, { 25, 54 }, { 26, 54 }, { 38, 54 }, { 39, 54 } }, WATER[4])

-- face on the thick lower band
c:eyeLocked(21, 38)
c:eyeLocked(38, 38)
c:cheek(18, 44) c:cheek(44, 44)
O.dots(c, { { 29, 44 }, { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 45 }, { 34, 44 } }, P.ink)
O.dots(c, { { 31, 46 }, { 32, 46 } }, "#c85a4a")

O.shift(c, 0, 2)
O.done(c, "dw-oasis-hoop-yard")
