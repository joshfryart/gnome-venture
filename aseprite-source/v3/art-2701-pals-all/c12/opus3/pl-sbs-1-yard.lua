-- Silkthread Tuft (pl-sbs-1), yard sprite 64x64. Opus richness pass (c12/opus3), built on c12/opus2.
-- Seedkeeper, common, Hollow of the Silverback Spider. "Spun from the spider's worries and still a little bit sticky."
-- Haiku was a flat grey cloud with antennae (read as a bug or a cloud). Now a wide, fluffy tuft of cool
-- silver-lilac silk, its fluff spun in visible spiral strands, a loose loop of thread and a curled end on top and a
-- few at the edge, and a worried face (brows up in the middle, a wobbly mouth): it was spun from
-- worries.
-- quirk: still sticky: a little green leaf has stuck to its flank.
-- closer look: a sticky thread hangs from its underside with a glossy bead on the end; tiny glossy sticky
-- beads dot its fluff.
-- richness (opus3): the closed thread loop on top (opus2 weak spot: read as a bag handle) is now one open
-- strand springing up out of the fluff and curling over like a question mark: a worry-cowlick. The second
-- curl was dropped (it read as an ear).
-- Plum-to-pearl hue-shifted silk, finer spun fibres, a few stray wisps at the edge, cool bounce underneath.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-sbs-1-yard", 64)

local SILK = { "#463c66", "#6a6290", "#9890ba", "#c2bcda", "#e2def0", "#f6f2f8" }
local LEAF = { "#24544a", "#2f6e4e", "#3f9150", "#7cc35a", "#c4e07a", "#e2f0a8" }

c:groundShadow(31, 56, 17, 2)

-- an open worry-cowlick: one strand springs up out of the fluff and coils into a loose spiral (open end, so it
-- never closes into a handle); its root is buried in the fluff
local spiral = HP.mask()
local sn = {}
local function strand(pts, w)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local m, n = O.tube({ a, { a[1] + (b[1] - a[1]) / 3, a[2] + (b[2] - a[2]) / 3 }, { a[1] + (b[1] - a[1]) * 2 / 3, a[2] + (b[2] - a[2]) * 2 / 3 }, b }, function() return w end)
    spiral:add(m) for k, v in pairs(n) do sn[k] = v end
  end
end
local pts = {}
for i = 0, 40 do -- from the fluff (t=0) up and round into a spiral that tightens inward
  local t = i / 40
  local a = math.pi * .55 - t * math.pi * 2.6
  local r = 6.5 * (1 - t * .75)
  pts[#pts + 1] = { 29 + math.cos(a) * r - (1 - t) * 0, 18 - math.sin(a) * r + (1 - t) ^ 2 * 12 }
end
strand(pts, .9)
O.shadeN(c, spiral, sn, SILK, { amb = .35, wrap = .45 })

-- the fluff: a lumpy tuft (union of puffs), scalloped edge
local fluff = O.unionCircles({ { 31, 43, 18, 10 }, { 21, 36, 8 }, { 41, 36, 8.5 }, { 31, 32, 8 }, { 14, 45, 5.5 }, { 48, 45, 5.5 } })
local fI, fT = O.shade(c, fluff, SILK, { sphere = { 26, 30, 25 }, amb = .3, wrap = .45, rim = true, bounce = "#7a8ab8", bmax = 2 })
-- spun strands: spiral grooves round the centre, plus fine lit fibres between them
O.tex(c, fI, fT, SILK, function(x, y, i)
  if y >= 33 and y <= 47 and x >= 21 and x <= 42 then return 0 end -- face stays smooth
  local dx, dy = x - 31, y - 38
  local r = math.sqrt(dx * dx + dy * dy)
  local a = math.atan(dy, dx)
  local w = (r * .55 + a * 2.2) % 3.2
  if w < .8 then return -1 end
  if w > 2.7 and i >= 3 and i <= 5 then return 1 end
  if w > 1.6 and w < 1.9 and i >= 2 and H(x, y, 17) > .5 then return -1 end -- finer fibres
end)
-- tiny glossy sticky beads caught in the fluff (still a little bit sticky)
for _, b in ipairs({ { 16, 41 }, { 45, 47 }, { 27, 31 }, { 37, 50 } }) do
  O.mark(c, { { b[1], b[2] } }, "#dceef8") O.mark(c, { { b[1] + 1, b[2] + 1 } }, "#7f9cc8")
end
-- loose fibres poking off the edge (one-pixel curls, outlined)
O.dots(c, { { 13, 36 }, { 12, 35 }, { 50, 37 }, { 51, 36 }, { 52, 36 }, { 10, 49 }, { 9, 48 } }, SILK[4])

-- closer look: sticky thread from the underside with a glossy bead
for y = 53, 56 do O.dot(c, 22, y, SILK[3]) end
O.shade(c, c:ellipse(22, 58, 1.5, 1.5), { "#5f7fb8", "#8bb0dc", "#b9d6ef", "#dceef8", "#eef8fc" }, { sphere = { 21, 57, 2.5 }, amb = .4, cuts = { .3, .5, .7, .85 } })

-- quirk: a leaf stuck to the right flank
local leaf, ln, lT = O.tube({ { 47, 41 }, { 51, 38 }, { 55, 39 }, { 59, 42 } }, function(t) return 2.8 * math.sin(math.pi * t) + .3 end)
local lI, lT2 = O.shadeN(c, leaf, ln, LEAF, { amb = .3, wrap = .4, sep = LEAF[1] })
for _, p in ipairs({ { 49, 40 }, { 51, 40 }, { 53, 41 }, { 55, 42 } }) do O.mark(c, { p }, LEAF[2]) end -- midrib
O.mark(c, { { 50, 39 }, { 52, 39 } }, LEAF[5])
-- a few silk strands crossing over the leaf (it is stuck)
O.mark(c, { { 50, 41 }, { 51, 42 }, { 53, 39 } }, SILK[5])

-- face: worried
c:cheek(21, 43) c:cheek(39, 43)
O.dots(c, { { 29, 46 }, { 30, 45 }, { 31, 46 }, { 32, 45 }, { 33, 46 } }, P.ink)

O.done(c, "pl-sbs-1-yard", function(c)
  c:eyeLocked(23, 37)
  c:eyeLocked(34, 37)
  -- worried brows: low at the outside, raised toward the middle
  c:put(23, 35, P.ink) c:put(24, 34, P.ink) c:put(25, 34, P.ink) c:put(26, 33, P.ink)
  c:put(37, 33, P.ink) c:put(38, 34, P.ink) c:put(39, 34, P.ink) c:put(40, 35, P.ink)
end)
