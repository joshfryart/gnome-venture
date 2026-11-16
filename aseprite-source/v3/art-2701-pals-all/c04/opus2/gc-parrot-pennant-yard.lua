-- Parrot Pennant (gc-parrot-pennant), yard sprite 64x64. Opus second pass (art-2701-pals-all/c04/opus2), from the Haiku pass.
-- Thornblade, rare, Great Canopy. "Repeats everything the rain says, then shouts it louder."
-- A scarlet macaw sitting front-on on a thorny branch: round red head with the locked eyes, a big pale hooked
-- beak open mid-shout, blue wings with a yellow shoulder band, grey gripping toes, and a long tail that is a
-- striped swallow-tail pennant (red, yellow, blue) hanging below the branch.
-- Fixed from Haiku: the side-on red gourd with a green belly patch and a loose blue flag read as a bowling pin;
-- now the bird is front-on with a parrot beak, macaw colours, and the pennant is its tail.
-- quirk: mid-shout, three sound arcs growing bigger beside a single small rain drop (what the rain said, louder).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("gc-parrot-pennant-yard", 64)

local RED  = { "#3e1424", "#6e1a2a", "#a82632", "#d8402e", "#f0703e", "#fba868" }
local BLUE = { "#1a2448", "#24407a", "#2f63a8", "#4a8fd0", "#7cbde8" }
local YEL  = { "#8a5a1a", "#c98a22", "#f0be38", "#fbe07a" }
local BEAK = { "#3a3442", "#6a6476", "#bcb6c4", "#e4e0ea" }
local BARK = { "#2e1e1c", "#4a3026", "#6e4a32", "#94683e", "#b88c56" }
local DROP = { "#2f8a9a", "#5fc4c8", "#b6f0e0" }

-- tail pennant (behind branch)
local pen = c:poly{ { 26, 44 }, { 34, 44 }, { 44, 62 }, { 39, 58 }, { 35, 62 } }
local pv = {}
pen:each(function(x, y) pv[K(x, y)] = .5 end)
pen:each(function(x, y)
  local t = (y - 44) / 18
  local band = math.floor(t * 6) % 3
  local R = (band == 0) and RED or ((band == 1) and YEL or BLUE)
  local lit = (x - 30 - t * 9) < 0
  local col = (band == 0) and (lit and RED[4] or RED[3]) or ((band == 1) and (lit and YEL[3] or YEL[2]) or (lit and BLUE[4] or BLUE[3]))
  c:put(x, y, col, { r = { name = "pennant" } })
end)

-- branch with thorns
local br, bn = O.tube({ { 5, 49 }, { 20, 46 }, { 42, 47 }, { 58, 45 } }, function() return 2.2 end)
local bI, bT = O.shadeN(c, br, bn, BARK, { amb = .25, wrap = .4, sep = BARK[1], cuts = { .25, .45, .65, .85 } })
O.tex(c, bI, bT, BARK, function(x, y, i) if (x + y) % 7 == 0 and i >= 3 then return -1 end end)
for _, t in ipairs({ { 8, 45, -1 }, { 16, 50, 1 }, { 47, 43, -1 }, { 54, 48, 1 }, { 55, 43, -1 } }) do
  O.flat(c, c:rect(t[1], t[2], t[1] + 1, t[2]), BARK[4], "thorn")
  O.dot(c, t[1] + (t[3] < 0 and 1 or 0), t[2] + t[3], BARK[5])
end

-- wings (behind body)
for _, w in ipairs({ { 18.5, -1 }, { 41.5, 1 } }) do
  local wing = c:ellipse(w[1], 36, 5, 10)
  local wI, wT = O.shade(c, wing, BLUE, { sphere = { w[1] - 2, 31, 11 }, amb = .2, wrap = .4, sep = BLUE[1], cuts = { .2, .4, .6, .8 } })
  -- yellow shoulder band and feather tips
  wing:each(function(x, y)
    if y >= 27 and y <= 30 then c:put(x, y, (x + y) % 3 == 0 and YEL[2] or YEL[3], wT) end
    if y >= 40 and (x + y) % 3 == 0 then c:put(x, y, BLUE[2], wT) end
  end)
end

-- body
local body = c:ellipse(30, 36, 10, 11)
local bdI, bdT = O.shade(c, body, RED, { sphere = { 26, 31, 17 }, amb = .3, wrap = .5, rim = true, bounce = "#7a4a9a", bmax = 2, sep = RED[1] })
O.tex(c, bdI, bdT, RED, function(x, y, i) if y > 32 and (y % 3 == 0) and ((x + math.floor(y / 3)) % 4 == 0) and i >= 3 then return -1 end end) -- scalloped breast

-- toes gripping the branch
for _, fx in ipairs({ 25, 33 }) do
  O.flat(c, c:rect(fx, 45, fx + 3, 46), BEAK[2], "toe") O.dot(c, fx, 45, BEAK[3]) O.dot(c, fx + 3, 47, BEAK[1])
end

-- head
local head = c:ellipse(30, 18, 10.5, 10)
O.shade(c, head, RED, { sphere = { 26, 13, 17 }, amb = .3, wrap = .5, rim = true, sep = RED[1] })

-- big hooked beak, open mid-shout: pale upper mandible curling down to a dark hook tip, dark lower mandible
local up = c:poly{ { 25, 20 }, { 35, 20 }, { 35, 24 }, { 33, 28 }, { 31, 31 }, { 30, 29 }, { 29, 25 }, { 26, 23 } }
local uI, uT = O.shade(c, up, BEAK, { sphere = { 28, 19, 9 }, amb = .4, wrap = .5, sep = BEAK[1], cuts = { .3, .55, .8 } })
O.dots(c, { { 31, 30 }, { 31, 31 }, { 32, 29 } }, BEAK[1]) -- hook tip
O.dots(c, { { 33, 22 }, { 33, 23 }, { 32, 25 } }, BEAK[2]) -- curve line
local mouth = c:poly{ { 25, 24 }, { 28, 25 }, { 29, 28 }, { 26, 28 } }
O.flat(c, mouth, "#5a1e2a", "mouth") O.dots(c, { { 26, 26 }, { 27, 26 }, { 27, 27 } }, "#e86a6a")
local lo = c:poly{ { 25, 28 }, { 30, 28 }, { 29, 31 }, { 26, 30 } }
O.flat(c, lo, BEAK[2], "lowerbeak") O.dots(c, { { 26, 29 }, { 27, 29 } }, BEAK[3])
-- crest feathers
O.flat(c, c:rect(28, 7, 29, 8), RED[5], "crest") O.dot(c, 30, 7, RED[4])

-- face
c:eyeLocked(21, 15)
c:eyeLocked(35, 15)
O.dots(c, { { 21, 21 }, { 22, 21 } }, "#f5809f") O.dots(c, { { 38, 21 }, { 39, 21 } }, "#f5809f")
O.dots(c, { { 20, 13 }, { 21, 13 }, { 22, 13 }, { 38, 13 }, { 39, 13 }, { 40, 13 } }, RED[2]) -- brows lifted mid-shout

O.shift(c, 0, -1)
O.done(c, "gc-parrot-pennant-yard", function(c)
  -- the rain's small word, then the shout (not outlined)
  c:put(10, 20, DROP[3]) c:put(10, 21, DROP[2]) c:put(9, 22, DROP[2]) c:put(10, 22, DROP[1]) c:put(11, 22, DROP[2]) c:put(10, 23, DROP[1])
  local function arc(cx, r, col)
    local px
    for dy = -r, r do
      local dx = math.floor(math.sqrt(math.max(0, r * r - dy * dy)) * .55 + .5)
      if px then for x = math.min(px, dx), math.max(px, dx) do if x ~= dx then c:put(cx + x, 25 + dy - (x < dx and 0 or 0), col) end end end
      c:put(cx + dx, 25 + dy, col) px = dx
    end
  end
  arc(44, 3, "#fbe07a") arc(47, 5, "#fbe07a") arc(50, 8, "#f8ecd0")
end)
