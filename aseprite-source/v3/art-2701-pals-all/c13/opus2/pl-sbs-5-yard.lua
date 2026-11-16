-- Dewweb Eye (pl-sbs-5), yard sprite 64x64. Opus second pass (c13/opus2), built on c13/haiku.
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

local SILK = { "#3c3658", "#5c5a86", "#8689b4", "#b0b6d6", "#d6dcef", "#eef1fa" }
local DEW  = { "#1d4a6e", "#2a78a8", "#45aad6", "#84d4f0", "#c2eefa", "#ecfbff" }
local PET  = { "#9a3a5a", "#d8668a", "#f4a0b8", "#ffd2de" }

local CX, CY, HX, HY = 32, 33, 32, 25
-- anchor threads up to the branch (thin silk, outlined)
for _, t in ipairs({ { { 16, 18 }, { 12, 12 }, { 9, 6 }, { 7, 0 } }, { { 48, 18 }, { 52, 12 }, { 55, 6 }, { 57, 0 } } }) do
  local m, n = O.tube(t, function() return .6 end)
  O.flat(c, m, SILK[4], "thread")
end
-- the wreath of web, gap set high so the lower band holds the face
local ring = c:ellipse(CX, CY, 22, 22)
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
-- the dense silk pad on the lower band that holds the face
local pad = c:ellipse(32, 44, 14, 8.5)
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
end
-- a few small beads strung along the anchor threads
for _, b in ipairs({ { 11, 9 }, { 53, 9 } }) do
  O.shade(c, c:ellipse(b[1], b[2], 1, 1), DEW, { sphere = { b[1] - 1, b[2] - 1, 2 }, amb = .4, wrap = .5 })
end
-- closer-look: a pink petal snagged in the silk (lower right)
local pet = c:poly{ { 46, 44 }, { 50, 41 }, { 52, 44 }, { 49, 47 } }
O.shade(c, pet, PET, { R = 1, amb = .4, cuts = { .25, .55, .8 }, sep = SILK[2] })
O.dots(c, { { 48, 44 }, { 49, 43 } }, PET[1])

-- face on the lower band
c:eyeLocked(24, 38)
c:eyeLocked(35, 38)
c:cheek(22, 45) c:cheek(40, 45)
O.dots(c, { { 29, 46 }, { 30, 47 }, { 31, 47 }, { 32, 47 }, { 33, 47 }, { 34, 46 } }, P.ink)
O.dots(c, { { 31, 48 }, { 32, 48 } }, PET[2])

O.shift(c, 0, 0)
O.done(c, "pl-sbs-5-yard", function(c)
  -- quirk: the top-left bead flashes a big star glint
  local gx, gy = 22, 15
  for d = 1, 3 do c:put(gx - d, gy, DEW[6]) c:put(gx + d, gy, DEW[6]) c:put(gx, gy - d, DEW[6]) c:put(gx, gy + d, DEW[6]) end
  c:put(gx, gy, "#fffbe8")
  c:sparkle(58, 30)
  c:sparkle(6, 40)
end)
