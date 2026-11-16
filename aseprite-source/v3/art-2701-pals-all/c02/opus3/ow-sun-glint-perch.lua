-- Sun Glint (ow-sun-glint), perch sprite 36x36. Opus richness pass (c02/opus3), built on opus2, hand-built at this size.
-- Richness (opus3): two-facet rays (lit upper-left half), teal sea bounce on the disc's lower-right rim, a few
-- lit flare dots on the disc, sea crests with lit tops; the face and wink stay bold.
-- Gold sun disc dipping into a strip of sea, crown of three fat cream-tipped rays (tri knob) plus four side rays,
-- gold reflection on the water.
-- Fix vs Haiku: thin rays and flat colour; now fat rays in their own amber ramp with a dark seam at the disc,
-- a 6-tone disc, and the wink is a clear closed arc with a sparkle beside the pill eye.
-- quirk: the wink, with a cream sparkle popping off it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-sun-glint-perch", 36)

local SUN = { "#9a4a1c", "#c86a22", "#e8902c", "#f6b440", "#fcd662", "#fff0a6" }
local RAY = { "#7a2a1a", "#a8401c", "#d05e22", "#ec8430", "#f6ac48", "#fcd890" }
local SEA = { "#1d3f6a", "#245e8e", "#2f84ac", "#48a8c0", "#7ccbd2", "#b9e8e4" }
local CX, CY, R = 18, 18, 9

local function ray(a, len, half, tip)
  local r0 = R - 1
  local p1 = { CX + math.cos(math.rad(a - half)) * r0, CY + math.sin(math.rad(a - half)) * r0 }
  local p2 = { CX + math.cos(math.rad(a + half)) * r0, CY + math.sin(math.rad(a + half)) * r0 }
  local m = c:poly{ p1, { CX + math.cos(math.rad(a)) * len, CY + math.sin(math.rad(a)) * len }, p2 }
  local rb = {}
  local ca, sa = math.cos(math.rad(a)), math.sin(math.rad(a))
  m:each(function(x, y)
    local s = ((x - CX) * (-sa) + (y - CY) * ca) * (sa - ca)
    local b = (s > .4 and 1) or (s < -.4 and -1) or 0
    if math.sqrt((x - CX) ^ 2 + (y - CY) ^ 2) > len - 1.6 then b = b + tip end
    rb[K(x, y)] = b
  end)
  O.shade(c, m, RAY, { R = 1, bias = rb, amb = .3, wrap = .4 })
end
ray(-90, 16, 20, 2) ray(-132, 14.5, 18, 2) ray(-48, 14.5, 18, 2)
for _, a in ipairs({ -8, 188 }) do ray(a, 13.5, 18, 1) end

local disc = c:ellipse(CX, CY, R, R)
O.shade(c, disc, SUN, { sphere = { CX - 3, CY - 4, R + 3 }, amb = .25, wrap = .35, rim = true, sep = "#a8401c", bounce = "#7aa49a", bmax = 2 })
O.dots(c, { { 11, 15 }, { 16, 11 }, { 19, 11 } }, SUN[5])
O.dots(c, { { 13, 13 }, { 14, 13 } }, SUN[6])

-- face
c:eyeSmall(14, 16)
O.dots(c, { { 20, 18 }, { 21, 17 }, { 22, 17 }, { 23, 18 } }, P.ink) -- wink
O.dot(c, 12, 20, "#f5809f") O.dot(c, 24, 20, "#f5809f")
O.dots(c, { { 15, 21 }, { 16, 22 }, { 17, 22 }, { 18, 22 }, { 19, 22 }, { 20, 21 } }, P.ink)
O.dots(c, { { 16, 21 }, { 17, 21 }, { 18, 21 }, { 19, 21 } }, "#7a2c34")

-- sea in front
local sea = HP.mask()
for x = 4, 32 do
  local top = math.floor(26.5 + .8 * math.sin(x * .6) + .5)
  for y = top, 31 do sea:set(x, y) end
end
local sb = {}
sea:each(function(x, y) sb[K(x, y)] = -1 end)
local sI, sT = O.shade(c, sea, SEA, { R = 1.5, bias = sb, amb = .3, wrap = .4, rim = true })
O.retone(c, sI, sT, { SUN[4], SUN[5], SUN[5], SUN[6], SUN[6], SUN[6] }, function(x, y, i)
  return math.abs(x - CX) <= 4 - (y - 28) and (y + x) % 2 == 0 and y >= 28
end)
O.tex(c, sI, sT, SEA, function(x, y, i)
  if math.abs(x - CX) <= 4 then return end
  if y == 30 and x % 5 < 2 then return -1 end
  if y == 29 and x % 5 >= 2 and x % 5 < 4 then return 1 end
end)

O.done(c, "ow-sun-glint-perch", function(c)
  for _, d in ipairs({ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
    c:put(25 + d[1], 16 + d[2], d[1] == 0 and d[2] == 0 and "#fff6c8" or "#fde49a", { r = { name = "spark" } })
  end
end)
