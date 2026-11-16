-- Dewweb Eye (pl-sbs-5), perch sprite 36x36. Opus richness pass (c13/opus3), hand-built at this size.
-- opus3: hue-shifted silk ramp with a warm morning-pearl top, scalloped outer edge between spokes, warm caustic on
-- each bead, the petal given a lit tip.
-- A silk web wreath with a see-through gap set high, bright spokes and rings over dusky gaps, a dense silk pad on
-- the lower band holding the 2x3 pill eyes, six dew beads ringing the gap, two anchor threads up.
-- quirk: one dew bead flashes a star glint.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-sbs-5-perch", 36)

local SILK = { "#352e52", "#555484", "#7d86b2", "#a8b8d6", "#d2e0ee", "#f4f2e6" }
local DEW  = { "#1d4a6e", "#2a78a8", "#45aad6", "#84d4f0", "#c2eefa", "#ecfbff" }
local PET  = { "#9a3a5a", "#d8668a", "#f4a0b8", "#ffd2de" }

local HX, HY = 18, 13
for _, t in ipairs({ { { 9, 9 }, { 7, 6 }, { 5, 3 }, { 4, 0 } }, { { 27, 9 }, { 29, 6 }, { 31, 3 }, { 32, 0 } } }) do
  O.flat(c, (O.tube(t, function() return .5 end)), SILK[4], "thread")
end
local ring = HP.mask()
for y = 3, 33 do for x = 3, 33 do
  local a = math.atan(y - HY, x - HX)
  local sag = math.abs(math.sin((a - math.pi / 6) * 3)) * .9
  if (x - 18) ^ 2 + (y - 18) ^ 2 <= (14.3 - sag) ^ 2 then ring:set(x, y) end
end end
ring:cut(c:ellipse(HX, HY, 5, 5))
local rI, rT = O.shade(c, ring, SILK, { sphere = { 13, 12, 19 }, amb = .3, wrap = .5, rim = true, bounce = "#6c88b0", bmax = 3 })
O.tex(c, rI, rT, SILK, function(x, y, i)
  local dx, dy = x - HX, y - HY
  local r = math.sqrt(dx * dx + dy * dy)
  for k = 0, 5 do
    local a = k * math.pi / 3 + math.pi / 6
    local ux, uy = math.cos(a), math.sin(a)
    if dx * ux + dy * uy > 0 and math.abs(-dx * uy + dy * ux) < .55 then return 1 end
  end
  if math.abs(((r - 6.5) % 3) - 1.5) > 1 then return 1 end
  return -2
end)
local pad = c:ellipse(18, 25, 9.5, 6)
pad:clip(ring)
O.shade(c, pad, SILK, { sphere = { 15, 22, 11 }, amb = .35, wrap = .5, sep = SILK[2] })
for k = 0, 5 do
  local a = k * math.pi / 3 + math.pi / 6
  local bx, by = math.floor(HX + math.cos(a) * 7.3 + .5), math.floor(HY + math.sin(a) * 7.3 + .5)
  O.flat(c, c:ellipse(bx, by, 1, 1), DEW[3], "dew")
  O.dot(c, bx, by, DEW[4]) O.dot(c, bx - 1, by, DEW[5]) O.dot(c, bx, by - 1, DEW[6]) O.dot(c, bx + 1, by, DEW[2]) O.dot(c, bx, by + 1, "#f2e6a8")
end
O.dots(c, { { 28, 25 }, { 29, 24 }, { 29, 25 } }, PET[3]) O.dot(c, 28, 26, PET[2]) O.dot(c, 29, 24, PET[4])

c:eyeSmall(13, 21)
c:eyeSmall(21, 21)
O.dot(c, 11, 25, P.petal.base) O.dot(c, 25, 25, P.petal.base)
O.dots(c, { { 16, 26 }, { 17, 27 }, { 18, 27 }, { 19, 26 } }, P.ink)

O.done(c, "pl-sbs-5-perch", function(c)
  local gx, gy = 11, 9
  for d = 1, 2 do c:put(gx - d, gy, "#fff6d6") c:put(gx + d, gy, "#fff6d6") c:put(gx, gy - d, "#fff6d6") c:put(gx, gy + d, "#fff6d6") end
  c:put(gx, gy, "#fffbe8")
end)
