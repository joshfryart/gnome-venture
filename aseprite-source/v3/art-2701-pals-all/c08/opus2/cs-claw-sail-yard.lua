-- Claw Sail (cs-claw-sail), yard sprite 64x64. Opus second pass (art-2701-pals-all/c08/opus2), redrawn from ../haiku.
-- Uncommon, rootwarden. "Sails the outrigger with a crab-claw sail and a very large grin."
-- A red shore crab riding in a slim wooden outrigger canoe: eyes on stalks, one claw on the gunwale, the other
-- hauling the sheet line of a real crab-claw sail (two curved spars in a V, sky-blue cloth with cream panels).
-- Fixes: the Haiku flag on a pole is now a true crab-claw sail; the crab sits in its canoe (outrigger float and
-- booms behind) on a strip of lapping sea instead of standing on spindly legs; the grin is open and huge.
-- quirk: the very large grin, so big it shows a row of cream teeth.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-claw-sail-yard", 64)

local RED  = { "#5a1830", "#94263a", "#c83a3a", "#e8603e", "#ff9268", "#ffc4a0" }
local WOOD = { "#3e2420", "#5e3428", "#864c33", "#b97a4a", "#d89a62", "#f0c48c" }
local SAIL = { "#3a5a9a", "#5f9ad0", "#8bc4ea", "#b9e2f5", "#e4f6ff" }
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
  end)
  -- spars (wood) along both edges
  local sp1 = O.tube({ { ax, ay }, { ax - 3, 30 }, { ax - 8, 16 }, { 34, 6 } }, function() return .9 end)
  local sp2 = O.tube({ { ax, ay }, { ax + 7, 30 }, { ax + 15, 18 }, { 61, 10 } }, function() return .9 end)
  O.flat(c, sp1, WOOD[3], "spar") O.flat(c, sp2, WOOD[3], "spar")
  O.mark(c, { { 35, 8 }, { 36, 10 }, { 59, 11 }, { 57, 13 } }, WOOD[5])
end

-- outrigger float + booms, behind the hull
local float = c:ellipse(12, 43, 7, 1.6)
O.shade(c, float, WOOD, { R = 1, amb = .25, sep = WOOD[1] })
O.flat(c, c:line({ { 11, 44 }, { 18, 47 } }, 1), WOOD[2], "boom")
O.flat(c, c:line({ { 15, 42 }, { 22, 46 } }, 1), WOOD[3], "boom")

-- crab body (sits in the hull)
local body = c:ellipse(25, 40, 12, 7.5)
local bI, bT = O.shade(c, body, RED, { sphere = { 21, 35, 14 }, amb = .25, wrap = .4, sep = RED[1], rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, RED, function(x, y, i) if y < 38 and O.H(x, y, 21) > .93 and i >= 3 then return 1 end end)
-- eye stalks
for _, ex in ipairs({ 19, 30 }) do
  O.shade(c, c:rect(ex, 29, ex + 1, 34), RED, { R = 1, amb = .35, sep = RED[1] })
end

-- left claw resting on the gunwale (open pincer)
do
  local m, n = O.tube({ { 15, 42 }, { 10, 41 }, { 8, 38 }, { 8, 35 } }, function() return 1.8 end)
  O.shadeN(c, m, n, RED, { amb = .3, sep = RED[1] })
  local palm = c:ellipse(8, 32, 3.5, 3)
  O.shade(c, palm, RED, { sphere = { 7, 30, 4 }, amb = .3, wrap = .4, sep = RED[1] })
  O.shade(c, c:poly{ { 5, 30 }, { 4, 25 }, { 7, 29 } }, RED, { R = 1, amb = .4, sep = RED[1] })
  O.shade(c, c:poly{ { 9, 30 }, { 12, 26 }, { 11, 31 } }, RED, { R = 1, amb = .4, sep = RED[1] })
end

-- hull
do
  local hull = c:poly{ { 4, 44 }, { 8, 47 }, { 56, 47 }, { 60, 43 }, { 58, 49 }, { 52, 54 }, { 12, 54 }, { 6, 49 } }
  local hI, hT = O.shade(c, hull, WOOD, { R = 3, amb = .25, wrap = .35, sep = WOOD[1], rim = true })
  O.tex(c, hI, hT, WOOD, function(x, y, i) if y == 50 and O.H(x, y, 4) > .2 then return -1 end if O.H(x, y, 8) > .93 then return 1 end end)
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
  O.shade(c, palm, RED, { sphere = { 41, 29, 4 }, amb = .3, wrap = .4, sep = RED[1] })
  O.shade(c, c:poly{ { 40, 29 }, { 41, 24 }, { 43, 28 } }, RED, { R = 1, amb = .4, sep = RED[1] })
  -- sheet line from claw up to the right spar
  O.flat(c, c:line({ { 44, 28 }, { 47, 24 }, { 50, 21 } }, 1), "#e8d4a8", "rope")
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
  O.tex(c, wI, wT, SEA, function(x, y, i) if y == 56 and x % 7 < 3 then return -1 end end)
end

O.shift(c, 0, -1)
O.done(c, "cs-claw-sail-yard", function(c)
  -- foam flecks at the bow
  c:put(60, 51, "#b6f0e0") c:put(61, 50, "#e4f6ff") c:put(3, 51, "#b6f0e0")
end)
