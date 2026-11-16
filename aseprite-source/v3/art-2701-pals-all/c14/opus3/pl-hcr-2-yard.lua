-- Shell Splinter (pl-hcr-2), yard sprite 64x64. Opus third pass (c14/opus3, richness), built on c14/opus2.
-- opus3: a jittered field of granular carapace bumps breaks the diagonal shading steps, a curved groove
-- across the brow (the crab's gastric groove), growth lines in the pale fracture slab, and a tiny barnacle
-- riding on the rim (closer look).
-- Rootwarden, common, Lair of the Hurricane Crab. "A bit of orange shell that rattles whenever the wind blows."
-- Haiku drew a flat red pentagon with a peg; it now reads as a real broken piece of crab carapace: a domed
-- orange shard with the smooth rim of the old shell (tiny rim spines) on top and a jagged fracture along the
-- bottom that shows the pale shell thickness in cross-section. Pebbly tubercles and red speckles on the dome,
-- two stubby leg-bits underneath to stand on.
-- quirk: it is mid-rattle in a gust: shake ticks either side, chattering zigzag mouth, and a loose crumb of
-- its own shell hopping beside it.
-- closer look: one old pale scratch across the dome.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_c14.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-hcr-2-yard", 64)

local SHL  = { "#5a1c26", "#97302a", "#cc4e2c", "#ec7a34", "#f8a656", "#fdd396" }
local CORE = { "#a8705a", "#d8a87c", "#f2d4a6", "#fcecc8" }
local LEG  = { "#5a1c26", "#8a2c2c", "#b84630", "#e06e3a", "#f2984e" }
local WIND = "#cfe2ec"

c:groundShadow(32, 56, 17, 2.5)

-- stubby legs (behind)
for _, L in ipairs({ { { 25, 46 }, { 24, 50 }, { 22, 53 }, { 21, 55 } }, { { 39, 46 }, { 40, 50 }, { 42, 53 }, { 43, 55 } } }) do
  local m, n = O.tube(L, function(t) return 2 - .5 * t end)
  O.shadeN(c, m, n, LEG, { amb = .3, wrap = .4, sep = LEG[1], cuts = { .25, .45, .65, .85 } })
end
O.dots(c, { { 24, 51 }, { 41, 51 } }, LEG[1]) -- joints

-- the shard: smooth curved rim of the old shell on the upper left, straight broken facets everywhere else
local dome = c:poly{ { 10, 31 }, { 13, 23 }, { 20, 16 }, { 29, 13 }, { 36, 14 }, { 40, 20 }, { 46, 18 }, { 52, 26 }, { 49, 31 },
                     { 54, 38 }, { 47, 43 }, { 45, 49 }, { 37, 46 }, { 30, 50 }, { 23, 45 }, { 16, 47 }, { 12, 40 } }
local arc = c:ellipse(28, 32, 18, 18.5):clip(c:poly{ { 0, 0 }, { 37, 0 }, { 37, 14 }, { 12, 40 }, { 0, 40 } })
dome:add(arc)
dome:set(14, 22) dome:set(13, 21) dome:set(24, 14) dome:set(24, 13) -- two little rim spines
local dI, dT = O.radial(c, dome, SHL, 20, 19, 34, { top = .93, ef = .6, rim = true, bounce = "#8a5a7a", bmax = 2 })
-- the pale cross-section of the shell along the broken facets (lower right): a 2 px slab edge
local core = {}
dome:each(function(x, y)
  if x + y > 52 then
    if not dome:has(x + 1, y + 1) or not dome:has(x, y + 1) or not dome:has(x + 1, y) then core[#core+1] = { x, y, 2 }
    elseif not dome:has(x + 2, y + 2) then core[#core+1] = { x, y, 3 } end
  end
end)
for _, q in ipairs(core) do O.mark(c, { { q[1], q[2] } }, CORE[q[3]]) end
-- granular carapace: jittered bumps (lit top pixel, shaded pair under it) over the dome, off the face and slab
local face = c:rect(20, 27, 43, 40)
for gy = 15, 46, 6 do for gx = 10, 54, 6 do
  local x = gx + math.floor(H(gx, gy, 3) * 3) + ((gy // 6) % 2) * 3
  local y = gy + math.floor(H(gx, gy, 7) * 2)
  if dome:has(x, y) and dome:has(x + 2, y + 3) and dome:has(x - 1, y - 1) and not face:has(x, y) and x + y < 78 then
    O.bump(c, x, y, SHL, 2)
  end
end end
-- gastric groove: a shallow curve across the brow
O.nudge(c, { { 21, 24 }, { 22, 23 }, { 23, 23 }, { 24, 22 }, { 25, 22 }, { 26, 22 }, { 27, 22 }, { 28, 22 }, { 29, 22 }, { 30, 23 },
  { 31, 23 }, { 32, 24 }, { 27, 23 }, { 26, 24 }, { 28, 24 } }, -2, SHL)
-- growth lines in the fracture slab
O.mark(c, { { 47, 41 }, { 44, 46 }, { 39, 46 }, { 33, 48 } }, CORE[1])
-- carapace markings: a few dark red spot clusters and a pale ridge line
O.mark(c, { { 17, 26 }, { 18, 26 }, { 17, 27 }, { 44, 26 }, { 45, 26 }, { 45, 27 }, { 46, 34 }, { 47, 34 }, { 16, 37 }, { 17, 38 } }, SHL[2])
O.mark(c, { { 16, 25 }, { 43, 25 }, { 45, 33 } }, SHL[5])
O.mark(c, { { 20, 20 }, { 21, 19 }, { 22, 18 }, { 23, 18 }, { 24, 17 }, { 25, 17 }, { 26, 17 } }, SHL[6]) -- gloss along the rim
-- barnacle riding on the rim (closer look): pale cone with a dark mouth
O.rows(c, 31, 14, { ".ab.", "abbc" }, { a = CORE[4], b = CORE[3], c = CORE[1] }, "barnacle")
O.dots(c, { { 32, 14 }, { 33, 14 } }, CORE[1])
-- old scratch across the dome, upper right
O.mark(c, { { 38, 22 }, { 39, 22 }, { 40, 23 }, { 41, 23 }, { 42, 24 } }, SHL[6])
O.mark(c, { { 39, 23 }, { 40, 24 }, { 41, 24 } }, SHL[2])

-- face: wide eyes, chattering zigzag mouth
c:eyeLocked(23, 29)
c:eyeLocked(35, 29)
c:cheek(21, 36) c:cheek(41, 36)
O.dots(c, { { 27, 38 }, { 28, 37 }, { 29, 38 }, { 30, 37 }, { 31, 38 }, { 32, 37 }, { 33, 38 }, { 34, 37 }, { 35, 38 }, { 36, 37 } }, P.ink)

-- loose crumb of shell hopping beside it
local crumb = c:poly{ { 53, 45 }, { 57, 44 }, { 58, 47 }, { 55, 49 }, { 52, 48 } }
O.shade(c, crumb, SHL, { R = 1, amb = .35, wrap = .45 })
O.mark(c, { { 53, 48 }, { 54, 48 }, { 55, 48 } }, CORE[2])

O.done(c, "pl-hcr-2-yard", function(c)
  -- rattle ticks on both sides
  O.dots(c, { { 8, 33 }, { 7, 34 }, { 8, 37 }, { 7, 38 } }, P.ink)
  O.dots(c, { { 56, 30 }, { 57, 29 }, { 57, 34 }, { 58, 33 } }, P.ink)
  O.dots(c, { { 55, 41 }, { 56, 41 }, { 54, 51 }, { 57, 51 } }, P.ink)
  -- the gust: a pale curl coming in from the upper left
  O.dots(c, { { 6, 18 }, { 7, 17 }, { 8, 17 }, { 9, 17 }, { 10, 18 }, { 11, 19 }, { 11, 20 }, { 10, 21 }, { 9, 21 },
              { 4, 21 }, { 5, 22 }, { 6, 22 }, { 7, 22 } }, WIND)
end)
