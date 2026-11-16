-- Popcorn Moon (mh-popcorn-moon), yard sprite 64x64. Opus second pass (c00/opus2), built from the Haiku first pass.
-- Brewroot, rare, Maizehollow. "Rises over the field and goes pop at midnight."
-- A plump butter-gold crescent moon, opening to the right, with soft craters and a rim light; the inner cut sits
-- further right than in the first pass so the face has a wide belly to sit on, away from the edge.
-- Rare, so a little fancier: three cream sparkles and a gloss streak along the outer curve.
-- quirk: it is going pop: cream popcorn (warm butter shadows, no blue) bursting off its upper horn, two pieces
-- flying off with pop ticks.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mh-popcorn-moon-yard", 64)

local MOON = { "#6e3a2a", "#a8622a", "#d99030", "#f5c048", "#ffe07a", "#fff3b8" }
local POP  = { "#8a6040", "#b88c5c", "#dcb98a", "#f0d9ae", "#fbeccb", "#fff6e0" }

local function popcorn(list)
  for _, q in ipairs(list) do
    O.shade(c, c:ellipse(q[1], q[2], q[3], q[4] or q[3]), POP, { sphere = { q[1] - 1, q[2] - 1, q[3] + 1.5 }, amb = .35, wrap = .5, sep = POP[3] })
  end
end

-- the crescent
local moon = c:ellipse(30, 34, 21, 21)
moon:cut(c:ellipse(43, 26, 17, 17))
local mI, mT = O.shade(c, moon, MOON, { sphere = { 22, 27, 28 }, amb = .3, wrap = .5, rim = true, bounce = "#9a5a7a", bmax = 2 })
-- craters: dark lip on the upper-left inside, lit on the lower-right
for _, cr in ipairs({ { 16, 45, 2 }, { 25, 50, 1.5 }, { 17, 21, 1.5 }, { 37, 49, 1.5 } }) do
  local m = c:ellipse(cr[1], cr[2], cr[3], cr[3])
  m:each(function(x, y)
    local p = y * c.w + x
    if c.own[p] == mT then
      local i = mI[K(x, y)] or 3
      local dx, dy = x - cr[1], y - cr[2]
      local d = dx + dy
      local r = math.sqrt(dx * dx + dy * dy)
      if r > cr[3] - 1 then c.pix[p] = MOON[math.max(1, math.min(6, i + (d < 0 and -1 or 1)))] end
    end
  end)
end
-- gloss streak along the outer curve
O.mark(c, { { 11, 32 }, { 11, 33 }, { 11, 34 }, { 12, 28 }, { 12, 29 }, { 13, 26 } }, MOON[6])

-- quirk: popcorn bursting off the upper horn
popcorn({ { 30, 10, 3 }, { 34, 8, 3 }, { 32, 5, 2.5 }, { 37, 11, 2.5 }, { 33, 12, 2.5 } })
popcorn({ { 44, 6, 2.2 }, { 46, 8, 1.8 } })
popcorn({ { 46, 16, 2 }, { 48, 17, 1.7 } })

-- face on the wide belly
c:eyeLocked(12, 31)
c:eyeLocked(20, 31)
c:cheek(10, 38) c:cheek(25, 38)
O.dots(c, { { 15, 39 }, { 16, 40 }, { 17, 40 }, { 18, 40 }, { 19, 39 } }, P.ink)
O.dots(c, { { 16, 41 }, { 17, 41 } }, MOON[2])

O.shift(c, 2, 2)
O.done(c, "mh-popcorn-moon-yard", function(c)
  c:sparkle(10, 9)
  c:sparkle(58, 33)
  c:sparkle(50, 56)
  -- pop ticks round the flying pieces (not outlined)
  for _, p in ipairs({ { 52, 5 }, { 53, 4 }, { 53, 9 }, { 54, 9 }, { 54, 18 }, { 55, 19 }, { 51, 22 } }) do c:put(p[1], p[2], P.ink) end
end)
