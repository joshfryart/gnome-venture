-- Gale Islander (pl-hcr-6), yard sprite 64x64. Opus third pass (c14/opus3, richness), built on c14/opus2.
-- opus3: dark-tipped claws with tubercles, pebbled shell bumps, rim light on claws and legs, a seam line under
-- the shell edge, a grass tuft on the dune, and a tiny message bottle washed up on the beach (closer look,
-- wayfinder).
-- Wayfinder, rare, Lair of the Hurricane Crab. "A pocket crab with a whole tiny island on its back, palm trees and all."
-- Haiku drew a red crab wearing a gold-and-green hat with two stick palms. Now a coral pocket crab (wide
-- carapace, two raised claws, three legs a side) carrying a real sand island: a domed mound with wet sand and a
-- ring of foam where the sea laps its edge, two palms with ringed, wind-bent trunks, fronds with leaflets all
-- streaming one way in the gale, coconuts under the crowns.
-- quirk: the island's palms are mid-gale: everything blows to the right and the crab braces under it.
-- closer look: a tiny starfish washed up on the island's beach.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_c14.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-hcr-6-yard", 64)

local CRAB = { "#5e1a34", "#94304a", "#c84e5a", "#e8766a", "#f6a088", "#fcccb0" }
local SAND = { "#7a5040", "#a87a52", "#d2a466", "#ecc884", "#f8e2a8", "#fdf2d0" }
local SEA  = { "#1e5a6e", "#2e8a92", "#52b8b0", "#94dccc", "#d8f4ec" }
local BARK = { "#3e2526", "#5e3a2c", "#86583a", "#b07e50", "#d4a874" }
local FRND = { "#1c4236", "#2a6640", "#3c8c4a", "#62ac50", "#9ccc68", "#d2e89a" }
local NUT  = { "#3e2526", "#6a4030", "#94603e", "#c08a58" }
local WIND = "#d8e8ee"

c:groundShadow(32, 58, 20, 2.5)

-- legs, three a side, braced wide
for _, L in ipairs({ { { 22, 48 }, { 17, 50 }, { 14, 53 }, { 13, 57 } }, { { 25, 50 }, { 21, 53 }, { 19, 55 }, { 19, 58 } }, { { 28, 51 }, { 26, 54 }, { 25, 56 }, { 25, 58 } },
                     { { 42, 48 }, { 47, 50 }, { 50, 53 }, { 51, 57 } }, { { 39, 50 }, { 43, 53 }, { 45, 55 }, { 45, 58 } }, { { 36, 51 }, { 38, 54 }, { 39, 56 }, { 39, 58 } } }) do
  local m, n, T = O.tube(L, function(t) return 1.5 - .5 * t end)
  local I, Tk = O.shadeN(c, m, n, CRAB, { amb = .3, wrap = .4, sep = CRAB[1], rim = true, bounce = "#7a5a8a", bmax = 2 })
  O.tex(c, I, Tk, CRAB, function(x, y, i) local t = T[K(x, y)] if t and math.abs(t - .45) < .05 then return -2 end end) -- knee joint
end

-- claws, raised
for _, d in ipairs({ -1, 1 }) do
  local arm, an = O.tube({ { 32 + d * 12, 45 }, { 32 + d * 17, 46 }, { 32 + d * 20, 43 }, { 32 + d * 21, 39 } }, function(t) return 2 end)
  O.shadeN(c, arm, an, CRAB, { amb = .3, wrap = .4, sep = CRAB[1] })
  local cl = c:ellipse(32 + d * 21, 35, 4, 4)
  cl:cut(c:poly{ { 32 + d * 21, 34 }, { 32 + d * 20, 29 }, { 32 + d * 23, 29 } }) -- pincer gap at the top
  local cI, cT = O.shade(c, cl, CRAB, { sphere = { 32 + d * 21 - 2, 33, 6 }, amb = .3, wrap = .45, rim = true, bounce = "#7a5a8a", bmax = 2, sep = CRAB[1] })
  -- dark claw tips on the two fingers, a tubercle on the palm
  O.tex(c, cI, cT, CRAB, function(x, y, i) if y <= 32 then return -(i - 1) elseif y == 33 then return -2 end end)
  O.bump(c, 32 + d * 21 - 1, 35, CRAB, 2)
end

-- carapace
local body = c:ellipse(32, 45, 14, 7.5)
local bI, bT = O.shade(c, body, CRAB, { sphere = { 28, 40, 16 }, amb = .3, wrap = .45, rim = true, bounce = "#7a5a8a", bmax = 2 })
O.tex(c, bI, bT, CRAB, function(x, y, i) if y > 47 and H(x, y, 5) > .85 then return 1 end end) -- pebbly lower shell
O.mark(c, { { 19, 44 }, { 45, 44 } }, CRAB[2]) -- carapace side notches
for _, b in ipairs({ { 21, 40 }, { 43, 40 }, { 19, 46 }, { 44, 47 }, { 27, 51 }, { 37, 51 } }) do O.bump(c, b[1], b[2], CRAB, 2) end
-- seam under the shell edge, lower right (cel shade)
c:ellipse(32, 45, 12.6, 6.2):edge():each(function(x, y) if y > 48 and x > 34 then O.nudge(c, { { x, y } }, -1, CRAB) end end)

-- the island: sand mound with a ring of sea lapping its edge (sits on the back of the shell)
local sea = c:ellipse(32, 36, 13, 2.5)
O.shade(c, sea, SEA, { R = 2, amb = .4, wrap = .5, cuts = { .25, .45, .65, .85 }, sep = CRAB[1] })
sea:each(function(x, y) if (x + y) % 4 == 0 then O.mark(c, { { x, y } }, SEA[5]) end end) -- foam flecks
local mound = c:ellipse(32, 34, 10, 5.5)
mound:cut(c:rect(0, 36, 63, 63))
local mI, mT = O.shade(c, mound, SAND, { sphere = { 29, 32, 11 }, amb = .35, wrap = .5, rim = true })
mound:each(function(x, y) if y == 35 then O.mark(c, { { x, y } }, SAND[2]) end end) -- wet sand line
O.tex(c, mI, mT, SAND, function(x, y, i) if H(x, y, 9) > .88 then return -1 end end) -- grains
-- tiny starfish on the beach
O.dots(c, { { 39, 33 }, { 38, 34 }, { 40, 34 }, { 39, 34 }, { 39, 32 } }, "#f07a6a") O.dot(c, 39, 33, "#fcb090")
-- message bottle washed up on the left beach (closer look): green glass, cork, rolled note inside
O.rows(c, 22, 34, { "cggG" }, { c = "#b07e50", g = "#5ab08a", G = "#2e7a62" }, "bottle")
O.dots(c, { { 24, 34 } }, "#f8f0d8")
-- grass tuft on the dune crest, blown right
O.dots(c, { { 31, 28 }, { 32, 27 }, { 33, 28 }, { 34, 27 } }, FRND[4])

-- palms: ringed trunks bending right in the wind
local crowns = {}
for _, tr in ipairs({ { { 28, 34 }, { 26, 26 }, { 28, 18 }, { 33, 13 }, 1.8 }, { { 36, 34 }, { 36, 30 }, { 38, 26 }, { 42, 23 }, 1.5 } }) do
  local m, n, T = O.tube({ tr[1], tr[2], tr[3], tr[4] }, function(t) return tr[5] * (1 - .35 * t) end)
  local I, Tk = O.shadeN(c, m, n, BARK, { amb = .35, wrap = .45, sep = BARK[1], cuts = { .25, .45, .65, .85 } })
  O.tex(c, I, Tk, BARK, function(x, y, i) local t = T[K(x, y)] if t and (t * 9) % 1 < .18 then return -1 end end) -- trunk rings
  crowns[#crowns+1] = tr[4]
end
-- coconuts under each crown
for _, cr in ipairs(crowns) do
  for _, o in ipairs({ { -1, 2 }, { 1.5, 2.5 } }) do
    local m = c:ellipse(cr[1] + o[1], cr[2] + o[2], 1.4, 1.4)
    O.shade(c, m, NUT, { sphere = { cr[1] + o[1] - 1, cr[2] + o[2] - 1, 2.5 }, amb = .35, cuts = { .3, .6, .85 }, sep = NUT[1] })
  end
end
-- fronds: leaf blades streaming right, two drooping, one tucked back left, with leaflet notches
for ci, cr in ipairs(crowns) do
  local s = ci == 1 and 1 or .7
  for _, f in ipairs({ { 10, -4, 15, -1 }, { 11, 2, 14, 6 }, { 7, 6, 9, 10 }, { -6, -2, -9, 2 }, { 4, -6, 9, -6 } }) do
    local a = { cr[1], cr[2] }
    local b = { cr[1] + f[1] * s * .5, cr[2] + f[2] * s * .5 - 2 * s }
    local e = { cr[1] + f[3] * s, cr[2] + f[4] * s }
    local m, n, T, S = O.tube({ a, b, b, e }, function(t) return (2.1 * math.sin(math.pi * math.min(1, t * 1.2)) + .4) * (s > .8 and 1 or .8) end)
    local I, Tk = O.shadeN(c, m, n, FRND, { amb = .22, wrap = .35, sep = FRND[1] })
    O.tex(c, I, Tk, FRND, function(x, y, i)
      local v, t = S[K(x, y)], T[K(x, y)]
      if v and math.abs(v) < .2 then return 1 end                       -- midrib
      if v and v > .5 and (x + y) % 2 == 0 then return -2 end            -- leaflet notches on the lower edge
      if t and t > .85 then return -1 end
    end)
  end
end

-- face on the carapace front
c:eyeLocked(24, 41)
c:eyeLocked(35, 41)
c:cheek(23, 46) c:cheek(39, 46)
O.dots(c, { { 29, 47 }, { 30, 48 }, { 31, 48 }, { 32, 48 }, { 33, 48 }, { 34, 47 } }, P.ink)

O.done(c, "pl-hcr-6-yard", function(c)
  for _, L in ipairs({ { { 53, 12 }, { 54, 12 }, { 55, 12 }, { 56, 13 } }, { { 50, 18 }, { 51, 18 }, { 52, 18 } }, { { 6, 22 }, { 7, 22 }, { 8, 21 }, { 9, 21 } } }) do
    for _, p in ipairs(L) do if not c:get(p[1], p[2]) then O.dot(c, p[1], p[2], WIND) end end
  end
end)
