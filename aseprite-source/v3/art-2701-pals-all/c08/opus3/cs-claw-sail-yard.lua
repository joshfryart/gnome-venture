-- Claw Sail (cs-claw-sail), yard sprite 64x64. Opus second pass (art-2701-pals-all/c08/opus2), redrawn from ../haiku.
-- Uncommon, rootwarden. "Sails the outrigger with a crab-claw sail and a very large grin."
-- A red shore crab riding in a slim wooden outrigger canoe: eyes on stalks, one claw on the gunwale, the other
-- hauling the sheet line of a real crab-claw sail (two curved spars in a V, sky-blue cloth with cream panels).
-- Fixes: the Haiku flag on a pole is now a true crab-claw sail; the crab sits in its canoe (outrigger float and
-- booms behind) on a strip of lapping sea instead of standing on spindly legs; the grin is open and huge.
-- Richness: hue-shifted ramps; carapace with lit granules, a darker spot pattern and a brow ridge; claws with dark
-- tips and lit knuckles; sail cloth with a faint diagonal weave and seams; spars with lit edges; hull with plank
-- grain, a plank seam and lit end grain; rope lashings on the booms; twisted sheet line; foam on the sea.
-- closer look: a tan patch stitched onto the sail with brown thread (the one repair on an old sail).
-- quirk: the very large grin, so big it shows a row of cream teeth.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-claw-sail-yard", 64)

local RED  = { "#4e1834", "#8c2440", "#c43a3c", "#e8623e", "#ff9466", "#ffcc9a" }
local WOOD = { "#3a2224", "#5a3228", "#864c33", "#b47848", "#d89e64", "#f2c88e" }
local SAIL = { "#36528e", "#5a94cc", "#88c0e8", "#b8e0f4", "#e4f6fc" }
local ROPE = { "#a88a5e", "#e8d4a8", "#fff0c8" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local BNC = "#5a6ab0"

c:groundShadow(31, 59, 23, 2)

-- crab-claw sail (behind everything): apex low at the mast foot, two curved spars, concave top edge
do
  local ax, ay = 42, 44
  local sail = HP.mask()
  for y = 4, 44 do for x = 30, 62 do
    -- inside the V between the spars and below the concave top arc
    local t = (ay - y) / 40
    local lx = ax - 8 * t - 2 * math.sin(t * math.pi)       -- left spar
    local rx = ax + 18 * t + 3 * math.sin(t * math.pi)      -- right spar
    local top = 6 + 9 * math.max(0, 1 - ((x - 47.5) / 13.5) ^ 2) -- concave bite
    if x >= lx and x <= rx and y >= top and y <= ay then sail:set(x, y) end
  end end
  local sI, sT = O.shade(c, sail, SAIL, { R = 5, amb = .2, wrap = .4, cuts = { .25, .45, .65, .85 } })
  -- cream panel stripes running out from the apex
  O.tex(c, sI, sT, SAIL, function(x, y, i)
    local t = (ay - y) / 40
    local lx = ax - 8 * t - 2 * math.sin(t * math.pi)
    local rx = ax + 18 * t + 3 * math.sin(t * math.pi)
    if rx - lx < 3 then return end
    local f = (x - lx) / (rx - lx)
    if math.abs(f - .36) < .045 or math.abs(f - .68) < .04 then return -2 end
    if math.abs(f - .40) < .04 and i <= 4 then return 1 end
    if (x + y) % 4 == 0 and i >= 3 and O.H(x, y, 2) > .45 then return -1 end -- diagonal weave
  end)
  -- closer look: a cream patch with gold stitches
  local patch = c:rect(44, 20, 49, 24) patch:clip(sail)
  O.flat(c, patch, "#eccf98", "patch")
  O.dots(c, { { 45, 21 }, { 46, 21 } }, "#fff0c8") O.dots(c, { { 48, 23 }, { 47, 23 } }, "#d4b07a")
  -- brown thread stitches round the edge (every other pixel)
  local st = {}
  patch:each(function(x, y) if (x == 44 or x == 49 or y == 20 or y == 24) and (x + y) % 2 == 0 then st[#st+1] = { x, y } end end)
  O.mark(c, st, "#8a6440")
  -- spars (wood) along both edges
  local sp1 = O.tube({ { ax, ay }, { ax - 3, 30 }, { ax - 8, 16 }, { 34, 6 } }, function() return .9 end)
  local sp2 = O.tube({ { ax, ay }, { ax + 7, 30 }, { ax + 15, 18 }, { 61, 10 } }, function() return .9 end)
  O.flat(c, sp1, WOOD[3], "spar") O.flat(c, sp2, WOOD[3], "spar")
  -- lit upper-left edge on both spars (only on spar pixels)
  for _, sp in ipairs({ sp1, sp2 }) do
    local l = {}
    sp:each(function(x, y) if not sp:has(x - 1, y) and y % 3 ~= 0 then l[#l+1] = { x, y } end end)
    O.mark(c, l, WOOD[5])
  end
end

-- outrigger float + booms, behind the hull
local float = c:ellipse(12, 43, 7, 1.6)
O.shade(c, float, WOOD, { R = 1, amb = .25, sep = WOOD[1] })
O.flat(c, c:line({ { 11, 44 }, { 18, 47 } }, 1), WOOD[2], "boom")
O.flat(c, c:line({ { 15, 42 }, { 22, 46 } }, 1), WOOD[3], "boom")
O.dots(c, { { 12, 44 }, { 16, 42 } }, ROPE[2]) O.dots(c, { { 12, 43 }, { 15, 41 } }, ROPE[1])
O.mark(c, { { 7, 42 }, { 8, 42 }, { 9, 42 } }, WOOD[5])

-- crab body (sits in the hull)
local body = c:ellipse(25, 40, 12, 7.5)
local bI, bT = O.shade(c, body, RED, { sphere = { 21, 35, 14 }, amb = .25, wrap = .4, sep = RED[1], rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, RED, function(x, y, i)
  if y < 38 and O.H(x, y, 21) > .9 and i >= 3 then return 1 end              -- lit granules
  if y < 37 and O.H(x // 2, y // 2, 6) > .87 and i >= 3 then return -1 end   -- darker mottled spots
end)
-- brow ridge arcs over the stalks
O.mark(c, { { 16, 34 }, { 17, 33 }, { 18, 33 }, { 31, 33 }, { 32, 33 }, { 33, 34 } }, RED[3])
O.mark(c, { { 17, 32 }, { 32, 32 } }, RED[5])
-- eye stalks
for _, ex in ipairs({ 19, 30 }) do
  O.shade(c, c:rect(ex, 29, ex + 1, 34), RED, { R = 1, amb = .35, sep = RED[1], rim = true })
  O.mark(c, { { ex, 31 }, { ex + 1, 31 } }, RED[3]) -- stalk joint
end

-- left claw resting on the gunwale (open pincer)
do
  local m, n = O.tube({ { 15, 42 }, { 10, 41 }, { 8, 38 }, { 8, 35 } }, function() return 1.8 end)
  O.shadeN(c, m, n, RED, { amb = .3, sep = RED[1] })
  local palm = c:ellipse(8, 32, 3.5, 3)
  O.shade(c, palm, RED, { sphere = { 7, 30, 4 }, amb = .3, wrap = .4, sep = RED[1], rim = true })
  O.shade(c, c:poly{ { 5, 30 }, { 4, 25 }, { 7, 29 } }, RED, { R = 1, amb = .4, sep = RED[1] })
  O.shade(c, c:poly{ { 9, 30 }, { 12, 26 }, { 11, 31 } }, RED, { R = 1, amb = .4, sep = RED[1] })
  O.mark(c, { { 4, 25 }, { 4, 26 }, { 12, 26 }, { 11, 27 } }, "#4a2a36")
  O.mark(c, { { 6, 31 }, { 7, 31 } }, RED[6])
end

-- hull
do
  local hull = c:poly{ { 4, 44 }, { 8, 47 }, { 56, 47 }, { 60, 43 }, { 58, 49 }, { 52, 54 }, { 12, 54 }, { 6, 49 } }
  local hI, hT = O.shade(c, hull, WOOD, { R = 3, amb = .25, wrap = .35, sep = WOOD[1], rim = true })
  O.tex(c, hI, hT, WOOD, function(x, y, i)
    if y == 50 and O.H(x, y, 4) > .2 then return -1 end                       -- plank seam
    if (y == 52 or y == 48) and O.H(x // 3, y, 5) > .55 then return -1 end      -- grain streaks
    if O.H(x // 2, y, 8) > .9 then return 1 end                               -- lit grain flecks
  end)
  O.mark(c, { { 57, 48 }, { 58, 47 }, { 5, 45 } }, WOOD[6]) -- lit end grain at bow and stern
  -- gunwale strip
  O.flat(c, c:rect(8, 47, 55, 47), WOOD[5], "gunwale")
  -- carved cream triangles band
  for x = 14, 50, 6 do O.dots(c, { { x, 49 }, { x + 1, 48 }, { x + 2, 49 } }, "#fff4d6") end
end

-- right claw hauling the sheet line
do
  local m, n = O.tube({ { 35, 41 }, { 39, 40 }, { 41, 37 }, { 42, 34 } }, function() return 1.8 end)
  O.shadeN(c, m, n, RED, { amb = .3, sep = RED[1] })
  local palm = c:ellipse(42, 31, 3, 3)
  O.shade(c, palm, RED, { sphere = { 41, 29, 4 }, amb = .3, wrap = .4, sep = RED[1], rim = true })
  O.shade(c, c:poly{ { 40, 29 }, { 41, 24 }, { 43, 28 } }, RED, { R = 1, amb = .4, sep = RED[1] })
  O.mark(c, { { 41, 24 }, { 41, 25 } }, "#4a2a36")
  -- sheet line from claw up to the right spar
  local rope = c:line({ { 44, 28 }, { 47, 24 }, { 50, 21 } }, 1)
  O.flat(c, rope, ROPE[2], "rope")
  local k = 0
  rope:each(function(x, y) k = k + 1 if (x + y) % 2 == 0 then O.mark(c, { { x, y } }, ROPE[1]) end end)
end

-- face
c:eyeLocked(17, 24)
c:eyeLocked(28, 24)
c:cheek(15, 39) c:cheek(34, 39)
-- very large grin: ink rim, dark mouth, cream teeth row
local grin = c:poly{ { 17, 38 }, { 33, 38 }, { 30, 43 }, { 20, 43 } }
O.flat(c, grin, P.ink, "mouth")
O.flat(c, c:rect(19, 39, 31, 41), "#6e2038", "mouthin")
O.flat(c, c:rect(19, 39, 31, 39), "#fff4d6", "teeth")
O.dots(c, { { 22, 39 }, { 26, 39 }, { 30, 39 } }, "#e2d4c4")
O.flat(c, c:rect(23, 41, 27, 42), "#f5809f", "tongue")

-- sea along the hull foot
do
  local sea = HP.mask()
  for x = 0, 63 do
    local top = 53 + math.floor(math.sin(x / 3.2) * 1.2 + .5)
    for y = top, 57 do if x >= 2 and x <= 61 then sea:set(x, y) end end
  end
  sea:cut(c:rect(0, 57, 63, 63))
  local wI, wT = O.shade(c, sea, SEA, { R = 2, amb = .4, cuts = { .3, .55, .8 } })
  O.tex(c, wI, wT, SEA, function(x, y, i)
    if y == 56 and x % 7 < 3 then return -1 end
    if y == 55 and (x + 3) % 9 < 2 then return 1 end
  end)
end

O.shift(c, 0, -1)
O.done(c, "cs-claw-sail-yard", function(c)
  -- foam flecks at the bow
  c:put(60, 51, "#b6f0e0") c:put(61, 50, "#e4f6ff") c:put(3, 51, "#b6f0e0")
end)
