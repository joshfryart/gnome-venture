-- Puddle Croak (pl-frt-2), yard sprite 64x64. Opus second pass (art-2701-pals-all/c08/opus2), redrawn from ../haiku.
-- Common, seedkeeper, from the Barrow of the Frost Toad. "Sits in a cold puddle and hums a lullaby for toads."
-- A squat, wide frost toad (a toad, not a frog: warty slate-green skin with frosted wart tips, big parotoid bumps,
-- heavy-lidded eyes) sitting low in a cold puddle with a crust of ice round its rim and ripple rings at its sides.
-- Fixes: the Haiku green gumdrop frog in a flat pond is now a warty toad with a body shape (head, parotoids,
-- planted forelegs) half sunk in an icy puddle; the notes are proper eighth notes, outlined.
-- quirk: humming with its mouth closed in a sleepy smile, a lullaby of gold notes drifting up.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("pl-frt-2-yard", 64)

local TOAD = { "#1c2a3a", "#2c4252", "#46646e", "#6a8a88", "#9ab4a6", "#cadcc8" }
local BELY = { "#8a9a8a", "#b4c2ae", "#d8e2cc", "#eef4e2" }
local POOL = { "#1e3466", "#2c5294", "#3a7ab0", "#5fa8cc", "#9ad2e4" }
local GOLD = { "#7a3a1c", "#b85c1f", "#e08a26", "#f5b82e", "#ffd970", "#fff0b0" }
local BNC = "#3a6a9a"

-- the cold puddle
local pool = c:ellipse(31, 52, 27, 6)
local pI, pT = O.shade(c, pool, POOL, { R = 3, amb = .35, wrap = .4, cuts = { .3, .5, .7, .86 }, name = "pool" })
-- ice crust on the rim: pale ring on the upper edge, flecks
local rimPx = {}
pool:edge():each(function(x, y) if y <= 52 then rimPx[#rimPx+1] = { x, y } end end)
O.mark(c, rimPx, "#d4eef8")
O.mark(c, { { 7, 53 }, { 8, 54 }, { 55, 54 }, { 54, 55 }, { 12, 56 } }, "#d4eef8")

-- body
local body = c:ellipse(31, 41, 17, 10)
body:add(c:ellipse(31, 32, 14, 9))
local hump = c:ellipse(22.5, 25, 5, 4.5):add(c:ellipse(39.5, 25, 5, 4.5)) -- eye bumps
body:add(hump)
-- parotoid glands behind the eyes
body:add(c:ellipse(15, 31, 4, 3)):add(c:ellipse(47, 31, 4, 3))
body:cut(c:rect(0, 51, 63, 63))
local bI, bT = O.shade(c, body, TOAD, { sphere = { 26, 25, 22 }, amb = .3, wrap = .4, sep = TOAD[1], rim = true, bounce = BNC, bmax = 2 })
-- warts: frosted tips upper-left, shadow pit lower-right
local warts = {}
for y = 22, 50 do for x = 12, 52 do
  if body:has(x, y) and O.H(x, y, 41) > .935 then warts[#warts+1] = { x, y } end
end end
for _, w in ipairs(warts) do
  local x, y = w[1], w[2]
  if not (y >= 21 and y <= 28 and ((x >= 20 and x <= 27) or (x >= 37 and x <= 44))) and not (y >= 31 and y <= 36 and x > 17 and x < 46) then
    O.mark(c, { { x, y } }, TOAD[6])
    if body:has(x + 1, y + 1) then O.mark(c, { { x + 1, y + 1 } }, TOAD[2]) end
  end
end
-- parotoid pores
O.mark(c, { { 14, 30 }, { 16, 31 }, { 46, 30 }, { 48, 31 } }, TOAD[3])

-- pale throat/belly showing above the water
local bel = c:ellipse(31, 46, 8, 4.5) bel:cut(c:rect(0, 50, 63, 63))
O.shade(c, bel, BELY, { R = 2, amb = .45, cuts = { .3, .6, .85 } })

-- forelegs planted in the water
for _, s in ipairs({ { 18, -1 }, { 44, 1 } }) do
  local m, n = O.tube({ { s[1] - s[2] * 2, 40 }, { s[1], 43 }, { s[1] + s[2], 46 }, { s[1] + s[2], 50 } }, function() return 2.2 end)
  O.shadeN(c, m, n, TOAD, { amb = .3, sep = TOAD[1] })
end

-- ripple rings either side, drawn over the pool
O.mark(c, { { 9, 50 }, { 10, 49 }, { 11, 49 }, { 12, 49 }, { 52, 49 }, { 53, 49 }, { 54, 49 }, { 55, 50 } }, POOL[5])
O.mark(c, { { 6, 54 }, { 7, 55 }, { 56, 55 }, { 57, 54 } }, POOL[4])
-- waterline across the body
O.flat(c, c:rect(13, 51, 49, 51), POOL[4], "waterline")
O.dots(c, { { 16, 51 }, { 17, 51 }, { 30, 51 }, { 31, 51 }, { 44, 51 } }, POOL[5])

-- face: heavy-lidded locked eyes, a long closed humming smile
c:eyeLocked(20, 23)
c:eyeLocked(37, 23)
O.dots(c, { { 20, 22 }, { 21, 21 }, { 22, 21 }, { 23, 21 }, { 24, 22 }, { 37, 22 }, { 38, 21 }, { 39, 21 }, { 40, 21 }, { 41, 22 } }, TOAD[1]) -- heavy lids
O.dots(c, { { 21, 22 }, { 22, 22 }, { 23, 22 }, { 38, 22 }, { 39, 22 }, { 40, 22 } }, TOAD[3])
O.dots(c, { { 28, 29 }, { 34, 29 } }, TOAD[1]) -- nostrils
c:cheek(17, 33) c:cheek(44, 33)
O.dots(c, { { 19, 33 }, { 20, 34 }, { 21, 35 }, { 22, 35 }, { 23, 36 }, { 24, 36 }, { 25, 36 }, { 26, 36 }, { 27, 36 }, { 28, 36 }, { 29, 36 },
            { 30, 36 }, { 31, 36 }, { 32, 36 }, { 33, 36 }, { 34, 36 }, { 35, 36 }, { 36, 36 }, { 37, 36 }, { 38, 36 }, { 39, 35 }, { 40, 35 },
            { 41, 34 }, { 42, 33 } }, P.ink)
O.dots(c, { { 25, 37 }, { 26, 37 }, { 36, 37 }, { 37, 37 } }, TOAD[3])

-- lullaby notes (outlined by finish)
local function note(x, y, two)
  O.shade(c, c:ellipse(x, y, 2, 1.5), GOLD, { R = 1, amb = .4, sep = GOLD[1] })
  O.flat(c, c:rect(x + 2, y - 7, x + 2, y), GOLD[3], "stem")
  if two then
    O.flat(c, c:rect(x + 9, y - 9, x + 9, y - 2), GOLD[3], "stem")
    O.shade(c, c:ellipse(x + 7, y - 2, 2, 1.5), GOLD, { R = 1, amb = .4, sep = GOLD[1] })
    O.flat(c, c:line({ { x + 2, y - 7 }, { x + 9, y - 9 } }, 2), GOLD[4], "beam")
  else
    O.flat(c, c:line({ { x + 3, y - 6 }, { x + 5, y - 4 }, { x + 5, y - 2 } }, 1), GOLD[4], "flag")
  end
end
note(47, 18, true)
note(8, 18, false)

O.shift(c, 0, 1)
O.done(c, "pl-frt-2-yard", function(c)
  c:put(44, 9, "#ffe38a") c:put(16, 9, "#ffe38a")
end)
