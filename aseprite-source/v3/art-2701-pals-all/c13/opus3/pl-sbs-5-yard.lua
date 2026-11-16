-- Dewweb Eye (pl-sbs-5), yard sprite 64x64. Opus richness pass (c13/opus3), built on c13/opus2.
-- opus3: hue-shifted silk ramp (dusk violet to a warm morning-pearl top), outer edge sagging into scallops between
-- the spokes (a web, not a donut), tiny dew seeds where spokes cross the rings, a warm caustic on each bead's
-- shaded side, a fat drop hanging off the bottom about to fall, and a tiny spiderling abseiling down the right
-- anchor thread (closer look, kin of the Silverback).
-- Bloomcaller, uncommon, Hollow of the Silverback Spider. "A round gap in the web, ringed with morning dew that sparkles."
-- Haiku weakness fixed: the face sat on a purple blob inside the hole, so the gap no longer read as a gap and the
-- disc read as a porthole. Now the pal IS the web: a thick silk wreath with a real see-through gap set high, radial
-- spokes and spiral threads woven into the silk, two anchor threads up to the branch, and the face on the wide
-- lower band. Eight round dew beads ring the gap (bigger, lit spheres, so they hold at 25%).
-- quirk: the dew sparkles: one bead flashes a big star glint. closer-look: a pink petal caught in the silk
-- (a bloomcaller's catch).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-sbs-5-yard", 64)

local SILK = { "#352e52", "#555484", "#7d86b2", "#a8b8d6", "#d2e0ee", "#f4f2e6" }
local DEW  = { "#1d4a6e", "#2a78a8", "#45aad6", "#84d4f0", "#c2eefa", "#ecfbff" }
local PET  = { "#9a3a5a", "#d8668a", "#f4a0b8", "#ffd2de" }

local CX, CY, HX, HY = 32, 33, 32, 25
-- anchor threads up to the branch (thin silk, outlined)
for _, t in ipairs({ { { 16, 18 }, { 12, 12 }, { 9, 6 }, { 7, 0 } }, { { 48, 18 }, { 52, 12 }, { 55, 6 }, { 57, 0 } } }) do
  local m, n = O.tube(t, function() return .6 end)
  O.flat(c, m, SILK[4], "thread")
end
-- the wreath of web, gap set high so the lower band holds the face
local ring = HP.mask()
for y = CY - 23, CY + 23 do for x = CX - 23, CX + 23 do
  local dx, dy = x - CX, y - CY
  local a = math.atan(y - HY, x - HX)
  -- sag between the 8 spokes: radius dips by up to 1.8 px midway between them
  local sag = math.abs(math.sin((a - math.pi / 8) * 4)) * 1.1
  if dx * dx + dy * dy <= (22.3 - sag) ^ 2 then ring:set(x, y) end
end end
ring:cut(c:ellipse(HX, HY, 8.5, 8.5))
local rI, rT = O.shade(c, ring, SILK, { sphere = { 24, 22, 30 }, amb = .3, wrap = .5, rim = true, bounce = "#6c88b0", bmax = 3 })
-- web: bright silk spokes and rings over dusky gaps between the threads
O.tex(c, rI, rT, SILK, function(x, y, i)
  local dx, dy = x - HX, y - HY
  local r = math.sqrt(dx * dx + dy * dy)
  -- 8 straight spokes: distance from each spoke line under 0.5 px
  for k = 0, 7 do
    local a = k * math.pi / 8 * 2 + math.pi / 8
    local ux, uy = math.cos(a), math.sin(a)
    if dx * ux + dy * uy > 0 and math.abs(-dx * uy + dy * ux) < .6 then return 1 end
  end
  if math.abs(((r - 10.5) % 3.6) - 1.8) > 1.3 then return 1 end
  return -2
end)
-- tiny dew seeds where the spokes cross the silk rings (upper half only, the pad hides the rest)
for k = 0, 7 do
  local a = k * math.pi / 4 + math.pi / 8
  for _, r in ipairs({ 14.1, 17.7 }) do
    local x, y = math.floor(HX + math.cos(a) * r + .5), math.floor(HY + math.sin(a) * r + .5)
    if ring:has(x, y) and y < 34 then O.dot(c, x, y, DEW[5]) end
  end
end
-- the dense silk pad on the lower band that holds the face
local pad = c:ellipse(32, 43, 14.5, 9.5)
pad:clip(ring)
local pI, pT = O.shade(c, pad, SILK, { sphere = { 27, 39, 17 }, amb = .35, wrap = .5, sep = SILK[2] })
O.tex(c, pI, pT, SILK, function(x, y, i) if (x * 3 + y * 5) % 11 == 0 and i >= 4 then return -1 end end)
-- dew beads ringing the gap
local beads = {}
for k = 0, 7 do
  local a = k * math.pi / 4 + math.pi / 8
  beads[#beads+1] = { HX + math.cos(a) * 11.6, HY + math.sin(a) * 11.6 }
end
for _, b in ipairs(beads) do
  local bx, by = math.floor(b[1] + .5), math.floor(b[2] + .5)
  O.shade(c, c:ellipse(bx, by, 2.6, 2.6), DEW, { sphere = { bx - 1, by - 1, 3.5 }, amb = .35, wrap = .5, sep = DEW[1] })
  O.dot(c, bx - 1, by - 1, DEW[6])
  O.dot(c, bx + 1, by + 1, "#f2e6a8") -- warm caustic: morning sun through the drop
end
-- a few small beads strung along the anchor threads
for _, b in ipairs({ { 11, 9 }, { 53, 9 } }) do
  O.shade(c, c:ellipse(b[1], b[2], 1, 1), DEW, { sphere = { b[1] - 1, b[2] - 1, 2 }, amb = .4, wrap = .5 })
end
-- closer-look: a pink petal snagged in the silk (lower right)
local pet = c:poly{ { 46, 44 }, { 50, 41 }, { 52, 44 }, { 49, 47 } }
O.shade(c, pet, PET, { R = 1, amb = .4, cuts = { .25, .55, .8 }, sep = SILK[2] })
O.dots(c, { { 48, 44 }, { 49, 43 } }, PET[1])

-- closer-look: a fat drop hanging off the bottom of the web, about to fall
O.flat(c, c:rect(32, 55, 32, 56), SILK[4], "thread")
local drop = c:ellipse(32, 59, 2, 2.2) drop:add(c:rect(32, 56, 32, 57))
O.shade(c, drop, DEW, { sphere = { 31, 58, 3 }, amb = .35, wrap = .5, sep = DEW[1] })
O.dot(c, 31, 58, DEW[6]) O.dot(c, 33, 60, "#f2e6a8")
-- closer-look: a tiny spiderling abseiling down the right anchor thread
O.flat(c, c:rect(55, 4, 57, 6), "#8e8aa2", "spiderling")
O.dot(c, 55, 4, "#c4c2d4") O.dot(c, 57, 6, "#5e5a72") O.dot(c, 56, 7, "#5e5a72")
O.dots(c, { { 54, 5 }, { 58, 5 }, { 54, 7 }, { 58, 7 } }, "#4a4458")

-- face on the lower band
c:eyeLocked(24, 38)
c:eyeLocked(35, 38)
c:cheek(22, 45) c:cheek(40, 45)
O.dots(c, { { 29, 46 }, { 30, 47 }, { 31, 47 }, { 32, 47 }, { 33, 47 }, { 34, 46 } }, P.ink)
O.dots(c, { { 31, 48 }, { 32, 48 } }, PET[2])

O.shift(c, 0, 0)
O.done(c, "pl-sbs-5-yard", function(c)
  -- quirk: the upper-left bead flashes a big star glint
  local gx, gy = 20, 20
  for d = 1, 4 do
    local col = d <= 2 and "#fff6d6" or DEW[5]
    c:put(gx - d, gy, col) c:put(gx + d, gy, col) c:put(gx, gy - d, col) c:put(gx, gy + d, col)
  end
  c:put(gx - 1, gy - 1, DEW[5]) c:put(gx + 1, gy + 1, DEW[5]) c:put(gx + 1, gy - 1, DEW[5]) c:put(gx - 1, gy + 1, DEW[5])
  c:put(gx, gy, "#fffbe8")
  c:sparkle(58, 30)
  c:sparkle(6, 40)
end)
