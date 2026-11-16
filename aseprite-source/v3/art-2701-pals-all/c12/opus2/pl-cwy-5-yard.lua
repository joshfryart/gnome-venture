-- Ash Wreath (pl-cwy-5), yard sprite 64x64. Opus second pass (c12/opus2), built on c12/haiku.
-- Rootwarden, uncommon, Forge of the Cinder Wyrm. "A hollow wreath of cool grey ash that still hopes for a fire."
-- Haiku was a plain grey ring (read as a tyre) with the face floating in the hole. Now a wreath of twisted,
-- burnt-out twigs in cool blue-grey ash: diagonal twist grooves, pale ash flakes, charred twig ends poking
-- out, and a heavier lower rim that carries the face (the hollow stays empty, as the name says).
-- quirk: it hopes for a fire: an unlit matchstick tucked into the wreath top, held up like a candle.
-- closer look: one last tiny ember still glowing deep in the ash on the left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-5-yard", 64)

local ASH   = { "#2e2c44", "#48465e", "#68667e", "#8e8ca2", "#b8b6c6", "#dddbe5" }
local CHAR  = { "#2c1e28", "#3e2c34", "#584440" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }

c:groundShadow(32, 57, 17, 2)

-- charred twig ends poking out of the wreath (behind it)
for _, t in ipairs({ { { 13, 22 }, { 9, 19 }, { 7, 18 }, { 5, 16 } }, { { 51, 36 }, { 54, 38 }, { 56, 38 }, { 58, 37 } }, { { 19, 50 }, { 16, 53 }, { 14, 54 }, { 12, 54 } } }) do
  local m, n = O.tube(t, function(s) return 1.4 - .5 * s end)
  O.shadeN(c, m, n, { CHAR[1], CHAR[1], CHAR[2], CHAR[2], CHAR[3], CHAR[3] }, { amb = .2 })
end

-- the wreath: outer circle minus a hollow set high, so the lower rim is thick enough for the face
local ring = c:ellipse(32, 33, 21, 21)
ring:cut(c:ellipse(32, 28, 10, 9.5))
local n = X.pillow(ring, 5)
local rI, rT = O.shadeN(c, ring, n, ASH, { amb = .2, wrap = .4, rim = true, bounce = "#5a6a8e", bmax = 2 })
-- twist: diagonal grooves round the ring (angle-based), pale ash flakes on the lit side
O.tex(c, rI, rT, ASH, function(x, y, i)
  if y >= 39 and y <= 50 and x >= 22 and x <= 42 then return 0 end -- keep the face clean
  local a = math.atan(y - 31, x - 32)
  local d = math.sqrt((x - 32) ^ 2 + (y - 31) ^ 2)
  local w = (a * 22 / math.pi + d * .55) % 4
  if w < 1.1 then return -2 end
  if w < 1.9 then return -1 end
  if w > 3.3 and i >= 3 then return 1 end
  if i >= 4 and H(x, y, 5) > .92 then return 1 end
end)
-- soot gaps between the twisted strands at the inner edge
O.tex(c, rI, rT, ASH, function(x, y, i)
  if not ring:has(x, y - 1) and H(x, y, 2) > .55 then return -1 end
end)

-- closer look: one ember still glowing low in the ash
O.mark(c, { { 14, 38 }, { 15, 38 }, { 15, 37 } }, "#e8493b") O.mark(c, { { 14, 37 } }, "#ffb45a")

-- quirk: an unlit matchstick tucked in the top, held up like a candle
local stick = c:rect(43, 3, 44, 14)
O.shade(c, stick, { WOOD[1], WOOD[2], WOOD[2], WOOD[3], WOOD[4], WOOD[4] }, { R = 1, amb = .3, wrap = .4 })
local head = c:ellipse(43.5, 2.5, 1.5, 2)
O.shade(c, head, { "#6e2038", "#9a2a3c", "#b52e3f", "#e8493b", "#ff8a5c", "#ffb08a" }, { sphere = { 43, 1.5, 3 }, amb = .3, wrap = .4, sep = "#6e2038" })

-- face on the heavy lower rim
c:cheek(23, 46) c:cheek(39, 46)
O.dots(c, { { 30, 47 }, { 31, 48 }, { 32, 48 }, { 33, 48 }, { 34, 47 } }, P.ink)

O.shift(c, 0, 2)
O.done(c, "pl-cwy-5-yard", function(c)
  c:eyeLocked(25, 40 + 2)
  c:eyeLocked(34, 40 + 2)
end)
