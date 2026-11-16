-- Oasis Hoop (dw-oasis-hoop), perch sprite 36x36. Opus second pass (c04/opus2), hand-built at this size:
-- the straw hoop with fewer, bolder bindings, one palm leaflet, the face (2x3 pills, ink smile, cheeks) on the
-- thick lower band clear of the water, a short pool under it.
-- quirk: three dates on a string in the hole (a triangle cluster, so they never read as a second pair of eyes).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("dw-oasis-hoop-perch", 36)

local STRAW = { "#4a2a1e", "#7a4a26", "#a8702e", "#d09a3e", "#ecc062", "#f8e0a0" }
local WATER = { "#1e3a4e", "#25607a", "#2f8a9a", "#4fb4b4", "#86d6c8", "#c4eedd" }
local DATE  = { "#3a1a1e", "#6a2a24", "#9a4428", "#c86a34", "#e8a05a" }
local LEAF  = { "#1f4a3c", "#2f6b46", "#4a8f4e", "#72b35a", "#a2d070" }

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
  local f = (math.atan(y - CY, x - CX) / (2 * math.pi) * 8) % 1
  if y > 19 and math.abs(x - CX) < 9 then return end
  if f < .16 then return -1 end
end)

-- one palm leaflet
local m, n, T, S = O.tube({ { 16, 6 }, { 16, 3 }, { 19, 1 }, { 23, 1 } }, function(t) return 1.6 * math.sin(math.min(1, t * 1.15) * math.pi) + .3 end)
O.shadeN(c, m, n, LEAF, { amb = .3, wrap = .4, sep = LEAF[1] })

-- quirk: three dates on a string
O.dots(c, { { 18, 10 }, { 18, 11 } }, "#7a5a3a")
O.flat(c, c:rect(15, 12, 16, 14), DATE[3], "date") O.dot(c, 15, 12, DATE[5]) O.dot(c, 16, 14, DATE[2])
O.flat(c, c:rect(19, 12, 20, 14), DATE[3], "date") O.dot(c, 19, 12, DATE[5]) O.dot(c, 20, 14, DATE[2])
O.flat(c, c:rect(17, 15, 18, 17), DATE[4], "date") O.dot(c, 17, 15, DATE[5]) O.dot(c, 18, 17, DATE[2])
O.dots(c, { { 17, 12 }, { 18, 12 } }, "#7a5a3a")

-- water over the hoop foot
hoop:each(function(x, y) if y >= 28 then c:put(x, y, y == 28 and WATER[5] or WATER[3], poolT) end end)
O.dots(c, { { 4, 28 }, { 5, 28 }, { 31, 28 }, { 32, 28 } }, WATER[6])

-- face
c:eyeSmall(12, 21)
c:eyeSmall(22, 21)
O.dot(c, 10, 24, "#f5809f") O.dot(c, 26, 24, "#f5809f")
O.dots(c, { { 16, 24 }, { 17, 25 }, { 18, 25 }, { 19, 24 } }, P.ink)

O.shift(c, 0, 1)
O.done(c, "dw-oasis-hoop-perch")
