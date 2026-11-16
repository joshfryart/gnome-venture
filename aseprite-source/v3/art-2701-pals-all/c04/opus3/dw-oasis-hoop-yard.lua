-- Oasis Hoop (dw-oasis-hoop), yard sprite 64x64. Opus richness pass (c04/opus3), built on c04/opus2.
-- Richness pass: plaited straw strands twisting round the tube, dyed palm-fibre cord bindings (own ramp), straw
-- flecks, hue-shifted ramps, a wobbly reflection of the hoop in the pool with ripple rings, wrinkled glossy dates on a
-- forked stalk, leaflet veins. Closer look: one date has floated off into the pool (saved for a late friend), with its
-- own ripple ring, and a tiny dragonfly rests on the tip of a leaflet.
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

local STRAW = { "#45222c", "#7a4428", "#a8702e", "#d29c40", "#edc466", "#fae6aa" }
local CORD  = { "#3a1a26", "#5e2a2a", "#8a3e2c", "#b25a34", "#d27e48", "#e8a464" }
local WATER = { "#1c3450", "#235a7a", "#2c8496", "#4cb0b2", "#84d4c6", "#c6eedc" }
local DATE  = { "#361626", "#64242a", "#94402c", "#c46834", "#e8a05a" }
local LEAF  = { "#1c443e", "#2b6648", "#478c4e", "#70b25a", "#a6d274" }

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
-- plaited straw: strands twist round the tube (diagonal grooves), flecks; quieter on the face band
O.tex(c, hI, hT, STRAW, function(x, y, i)
  local a = math.atan(y - CY, x - CX)
  local d = math.sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
  local face = y > 35 and math.abs(x - CX) < 14
  local tw = (a / (2 * math.pi) * 24 + d * .25) % 1
  if not face and tw < .14 and i >= 3 then return -1 end
  if face and tw < .08 and i >= 4 then return -1 end
  if H(x, y, 5) > .95 and i >= 3 then return -1 end -- straw flecks
end)
-- dyed palm-fibre cord bindings, two turns wide, every 1/8 of the ring, skipping the face band
local BINDS = { -2.6, -1.85, -1.0, -.25, .4, 2.98 } -- radians, upper and side arcs only (off the face band)
O.tex2(c, hI, hT, CORD, function(x, y, i)
  local dx, dy = x - CX, y - CY
  for _, th in ipairs(BINDS) do
    local ux, uy = math.cos(th), math.sin(th)
    local along = dx * ux + dy * uy
    local across = math.abs(-dx * uy + dy * ux)
    if along > 0 and across < 1.6 then
      if math.floor(along) % 2 == 0 then return 0 end
      return -1
    end
  end
end)

-- palm leaflets tucked in at the top left
for _, L in ipairs({
  { { 26, 13 }, { 22, 7 }, { 17, 6 }, { 12, 8 } },
  { { 29, 12 }, { 28, 6 }, { 31, 2 }, { 35, 1 } } }) do
  local m, n, T, S = O.tube(L, function(t) return 2.2 * math.sin(math.min(1, t * 1.15) * math.pi) + .3 end)
  local lI, lT = O.shadeN(c, m, n, LEAF, { amb = .25, wrap = .4, sep = LEAF[1] })
  O.tex(c, lI, lT, LEAF, function(x, y, i)
    local sv = S[K(x, y)] or 1
    if math.abs(sv) < .2 then return -1 end -- midrib
    if math.abs(sv) > .45 and (x + y) % 3 == 0 and i >= 3 then return -1 end -- side veins
  end)
end

-- quirk: a sprig of dates hanging in the hole
O.dots(c, { { 32, 21 }, { 32, 22 }, { 32, 23 } }, "#7a5a3a")
O.dots(c, { { 31, 24 }, { 33, 24 } }, "#7a5a3a")
for _, d in ipairs({ { 28.5, 27 }, { 35.5, 27 }, { 32, 30.5 } }) do
  local m = c:ellipse(d[1], d[2], 1.7, 2.5)
  local dI, dT = O.shade(c, m, DATE, { sphere = { d[1] - 1, d[2] - 2, 3.5 }, amb = .3, wrap = .4, sep = DATE[1], cuts = { .2, .4, .6, .82 } })
  O.tex(c, dI, dT, DATE, function(x, y, i) if y == math.floor(d[2] + 1) and i >= 3 then return -1 end end) -- wrinkle
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

-- reflection of the hoop under the waterline: broken straw-coloured strips
for _, r in ipairs({ { 15, 53, 6 }, { 24, 53, 4 }, { 36, 53, 5 }, { 45, 53, 5 }, { 18, 55, 4 }, { 30, 55, 5 }, { 42, 55, 3 } }) do
  for x = r[1], r[1] + r[3] - 1 do if pool:has(x, r[2]) then c:put(x, r[2], r[2] == 53 and "#6fa68e" or "#5a8e86", poolT) end end
end
-- ripple rings around the hoop
O.dots(c, { { 6, 50 }, { 7, 49 }, { 57, 49 }, { 58, 50 }, { 13, 57 }, { 14, 57 }, { 15, 57 }, { 48, 57 }, { 49, 57 } }, WATER[5])
-- closer look: a date that floated off, with its own little ripple
local fd = c:ellipse(52, 53, 1.5, 1)
O.shade(c, fd, DATE, { sphere = { 51, 52, 2.5 }, amb = .35, wrap = .4, cuts = { .2, .4, .6, .82 } })
O.dot(c, 51, 52, "#f5c890")
O.dots(c, { { 49, 53 }, { 55, 53 }, { 50, 55 }, { 51, 55 }, { 52, 55 }, { 53, 55 }, { 54, 55 } }, WATER[6])
-- closer look: a tiny dragonfly resting on the leaflet tip (teal body, pale wings)
O.dots(c, { { 13, 6 }, { 12, 6 }, { 11, 6 }, { 10, 6 } }, "#2c8496")
O.dot(c, 14, 6, "#1c3450")
O.dots(c, { { 12, 5 }, { 13, 4 }, { 11, 5 }, { 12, 7 }, { 11, 7 } }, "#c6eedc")

-- face on the thick lower band
c:eyeLocked(21, 38)
c:eyeLocked(38, 38)
c:cheek(18, 44) c:cheek(44, 44)
O.dots(c, { { 29, 44 }, { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 45 }, { 34, 44 } }, P.ink)
O.dots(c, { { 31, 46 }, { 32, 46 } }, "#c85a4a")

O.shift(c, 0, 2)
O.done(c, "dw-oasis-hoop-yard")
