-- Golden Ring (mh-golden-ring), yard sprite 64x64. Opus richness pass (c00/opus3), built on c00/opus2.
-- Rootwarden, uncommon, Maizehollow. "A hole shaped like a good harvest."
-- A harvest-braid hoop standing on its edge. The opus2 rope noise (26 thin strands) is now 13 broad plaited
-- strands, each with a dark seam, a lit shoulder and a shaded back, so the twist reads at 1x and stays calm at 4x.
-- The braid fades to smooth straw over the lower band, which carries the face. Rim light upper-left, plum bounce.
-- The sheaf in the hole is one bow-tie bundle (vertical stalk grooves) instead of loose sticks, and its five ears
-- fan out with clear gaps over the top of the hoop (they no longer merge into a crown).
-- quirk: a tiny ladybird has climbed the braid to the top right, and one ripe grain has dropped by its feet.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mh-golden-ring-yard", 64)

local GOLD = { "#6a2e1c", "#a4521e", "#d4801f", "#f2aa2e", "#ffd25a", "#fff09e" }
local WHT  = { "#74401f", "#a86f2c", "#d39d40", "#efc463", "#fbe194" }
local STLK = { "#6e4a26", "#9c7438", "#c69c52", "#e6c47c", "#f6e0a2" }
local RIB  = { "#5e1c36", "#a42a40", "#e0473b", "#ff8a5c" }

c:groundShadow(32, 57, 19, 2.5)

-- five wheat ears fanned over the top (stalks hidden behind the hoop); drawn first so the hoop overlaps their bases
local ears = {
  { { 24, 18 }, { 21, 14 }, { 17, 10 }, { 13, 6 } },
  { { 28, 16 }, { 26, 11 }, { 24, 6 }, { 22, 2 } },
  { { 32, 16 }, { 32, 10 }, { 32, 5 }, { 32, 1 } },
  { { 36, 16 }, { 38, 11 }, { 40, 6 }, { 42, 2 } },
  { { 40, 18 }, { 43, 14 }, { 47, 10 }, { 51, 6 } },
}
for e, p in ipairs(ears) do
  local m, n, T, S = O.tube(p, function(t) if t < .4 then return .5 end return 2.2 - math.max(0, t - .82) * 7 end)
  local I, tok = O.shadeN(c, m, n, WHT, { amb = .3, wrap = .45, cuts = { .25, .45, .65, .85 }, sep = WHT[1], rim = true })
  -- plump grains: rows along the ear, a dark notch between rows, left-hand grains catch the light
  O.tex(c, I, tok, WHT, function(x, y, i)
    local t, s = T[K(x, y)], S[K(x, y)]
    if not t or t < .45 then return 0 end
    if math.abs(s) < .18 and t < .93 then return -1 end         -- centre split: left and right grains
    local row = (t - .45) * 7 - math.abs(s) * .7                 -- chevron rows
    if row % 1 < .26 then return -1 end
    if s < -.25 and i >= 3 and row % 1 > .5 then return 1 end
  end)
  -- awns: a 2-3 px whisker off the tip, leaning with the ear
  local tx, ty = p[4][1], p[4][2]
  local dx = (tx - 32) > 0 and 1 or (tx - 32) < 0 and -1 or 0
  for q = 1, 2 do if ty - q >= 0 then O.dot(c, tx + dx * q, ty - q, WHT[4 - q]) end end
  if dx ~= 0 then O.dot(c, tx - dx, ty - 1, WHT[3]) end
end

-- the sheaf bundle filling the hole: bow-tie shape, pinched at the tie
local sheaf = c:poly{ { 25, 17 }, { 39, 17 }, { 35, 30 }, { 35, 33 }, { 40, 41 }, { 24, 41 }, { 29, 33 }, { 29, 30 } }
local sI, sT = O.shade(c, sheaf, STLK, { R = 3, amb = .28, wrap = .4, cuts = { .25, .45, .65, .85 } })
O.tex(c, sI, sT, STLK, function(x, y, i)
  -- stalk grooves follow the fan: column measured from the waist
  local fx = 32 + (x - 32) * (6 / math.max(3, math.abs(y - 31.5) + 3))
  if math.floor(fx + .5) % 2 == 0 then return -1 end
  if H(x, y, 3) > .9 and i >= 3 then return 1 end
end)

-- ember tie: band with a bow (two loops, two tails)
O.shade(c, c:rect(28, 30, 36, 32), RIB, { R = 1, amb = .35, cuts = { .3, .6, .8 }, sep = RIB[1] })
O.shade(c, c:poly{ { 36, 29 }, { 40, 27 }, { 41, 30 }, { 37, 31 } }, RIB, { R = 1, amb = .4, cuts = { .3, .6, .8 }, sep = RIB[1] })
O.shade(c, c:poly{ { 36, 32 }, { 39, 37 }, { 37, 38 }, { 35, 33 } }, RIB, { R = 1, amb = .4, cuts = { .3, .6, .8 }, sep = RIB[1] })
O.dot(c, 36, 31, RIB[2])

-- the hoop
local hoop = c:ellipse(32, 33, 22, 22)
local hole = c:ellipse(32, 28.5, 11, 11)
hoop:cut(hole)
local hI, hT = O.shade(c, hoop, GOLD, { R = 6, amb = .12, wrap = .3, rim = true, bounce = "#9c5478", bmax = 2 })
-- plaited straw: 13 broad strands; seam (-2), shaded back (-1), lit shoulder (+1)
local function faceFade(x, y)
  if y >= 46 and x >= 18 and x <= 46 then return 0 end
  if y >= 42 and x >= 16 and x <= 48 then return .5 end
  return 1
end
O.tex(c, hI, hT, GOLD, function(x, y, i)
  local f = faceFade(x, y)
  if f == 0 then
    -- smooth band: only a few long straw fibres
    if (x * 3 + y) % 11 == 0 and i >= 4 and H(x, y, 9) > .5 then return -1 end
    return 0
  end
  local a = math.atan(y - 33, x - 32)
  local r = math.sqrt((x - 32)^2 + (y - 33)^2)
  local v = (a / (2 * math.pi) * 13 + (r - 11) * .085) % 1
  if v < .1 then return (f < 1) and -1 or -2 end
  if f < 1 then return 0 end
  if v > .72 then return -1 end
  if v > .14 and v < .34 and i >= 3 and i <= 5 then return 1 end
end)
-- a few loose straw ends sticking out of the braid (outer right and left)
O.dots(c, { { 54, 26 }, { 55, 25 } }, GOLD[4])
O.dots(c, { { 10, 38 }, { 9, 39 } }, GOLD[3])

-- quirk: ladybird on the braid, top right
O.dots(c, { { 48, 21 }, { 49, 21 }, { 48, 22 }, { 49, 22 }, { 50, 22 }, { 49, 23 } }, "#d8333d")
O.dots(c, { { 47, 20 }, { 47, 21 } }, P.ink)
O.dot(c, 48, 21, "#ff7a6a")
O.dots(c, { { 49, 22 }, { 50, 21 } }, P.ink)
-- quirk: a ripe grain dropped by its base
O.shade(c, c:ellipse(46, 56, 1.5, 1), WHT, { R = 1, amb = .4, cuts = { .25, .45, .65, .85 } })

-- face on the lower band
c:eyeLocked(24, 42)
c:eyeLocked(35, 42)
c:cheek(21, 48) c:cheek(41, 48)
O.dots(c, { { 29, 49 }, { 30, 50 }, { 31, 50 }, { 32, 50 }, { 33, 50 }, { 34, 49 } }, P.ink)
O.dots(c, { { 31, 51 }, { 32, 51 } }, "#d8484a")
c:sparkle(12, 16)

O.done(c, "mh-golden-ring-yard")
