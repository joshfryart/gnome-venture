-- Ember Flake (pl-cwy-1), yard sprite 64x64. Opus richness pass (c11/opus3), built on c11/opus2.
-- Thornblade, common, Forge of the Cinder Wyrm. "A cinder that drifted off the wyrm's back and stayed warm."
-- haiku drew a flat red hexagon with a face: no cinder or scale read, no glow. Now a single wyrm scale gone to
-- cinder: a charcoal shield shape with a pointed tip, its top edge curled forward like a flake of bark, crackled
-- with glowing ember veins, the lower edge still red-hot from inside. It hovers over a warm-lit shadow.
-- quirk: it stayed warm: heat ripples curl up off its top, the tip glows from within, a few sparks drift.
-- opus3: every crust plate is bevelled (ash-lit upper-left lip, dark lower-right lip), plates near a crack pick up
-- a warm red cast, white-hot cores at crack junctions, ash flecks, warm ember bounce on the lower-right edge.
-- closer look: one tiny flame flickers out of a crack on the crown, like a candle it forgot to blow out.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-1-yard", 64)

local CHAR = { "#1c1420", "#2e2028", "#463438", "#6a5656", "#958682", "#c4b8ac" }
local EMBR = { "#7a2018", "#c8401c", "#f07a26", "#ffbe48", "#ffe696" }
local HEAT = { "#e06a2a", "#f6a040" }

-- warm glow on the ground under it
c:groundShadow(32, 59, 14, 2)

-- the scale: rounded shield with a pointed tip
local sc = c:ellipse(31, 28, 17, 15)
sc:add(c:poly{ { 15, 32 }, { 47, 30 }, { 44, 46 }, { 41, 54 }, { 39, 55 } })
sc:cut(c:ellipse(15, 20, 2.5, 2.5)) -- a chipped corner
local sI, sT = O.shade(c, sc, CHAR, { sphere = { 24, 18, 26 }, amb = .2, wrap = .35, rim = true, bounce = "#a8401c", bmax = 3 })
-- ash grain
O.tex(c, sI, sT, CHAR, function(x, y, i) if H(x, y, 4) > .82 then return -1 end if H(x, y, 5) > .9 and i >= 3 then return 1 end end)
-- crackle: the crust breaks into plates (voronoi), ember glow showing in every crack; hotter toward the tip.
-- one big plate is kept whole round the face.
local seeds = { { 31, 26 }, { 18, 18 }, { 30, 13 }, { 42, 15 }, { 16, 31 }, { 45, 28 }, { 23, 41 }, { 36, 42 }, { 44, 39 }, { 38, 51 }, { 29, 50 } }
sc:each(function(x, y)
  local q = y * c.w + x
  if c.own[q] ~= sT then return end
  local d1, d2, k1 = 1e9, 1e9, 0
  for k, sd in ipairs(seeds) do
    local w = (k == 1) and .48 or 1 -- the face plate is bigger
    local d = math.sqrt((x - sd[1]) ^ 2 + (y - sd[2]) ^ 2) * w
    if d < d1 then d2 = d1 d1 = d k1 = k elseif d < d2 then d2 = d end
  end
  local heat = (y - 14) / 40 -- 0 top .. 1 tip
  -- bevel each plate: probe the plate owner one step up-left and down-right
  local function owner(px, py)
    local b1, kk = 1e9, 0
    for k, sd in ipairs(seeds) do local d = math.sqrt((px - sd[1]) ^ 2 + (py - sd[2]) ^ 2) * ((k == 1) and .48 or 1) if d < b1 then b1, kk = d, k end end
    return kk
  end
  local i0 = sI[K(x, y)] or 3
  if owner(x - 2, y - 2) ~= k1 then c.pix[q] = CHAR[math.min(6, i0 + 1)]:lower()
  elseif owner(x + 2, y + 2) ~= k1 then c.pix[q] = CHAR[math.max(1, i0 - 1)]:lower() end
  if d2 - d1 < 2.6 and d2 - d1 >= 1.1 and heat > .15 and heat <= .45 then c.pix[q] = "#5a2a26" end -- warm cast by the cracks
  if d2 - d1 < 1.1 then
    c.pix[q] = (heat > .55 and EMBR[4] or (heat > .25 and EMBR[3] or EMBR[2])):lower()
  elseif d2 - d1 < 2.1 and heat > .45 then
    c.pix[q] = EMBR[1]:lower() -- plate edges glowing red near the tip
  end
end)
-- white-hot cores where three cracks meet (approximate: brightest crack pixels near the tip)
O.mark(c, { { 31, 47 }, { 38, 45 }, { 33, 51 } }, EMBR[5])
-- ash flecks on the upper crust
O.mark(c, { { 22, 15 }, { 27, 12 }, { 36, 13 }, { 19, 24 }, { 44, 22 } }, CHAR[6])
-- red-hot rim along the lower edge
sc:each(function(x, y)
  local q = y * c.w + x
  if c.own[q] == sT and y > 38 and (not sc:has(x, y + 1) or not sc:has(x + 1, y)) then c.pix[q] = EMBR[3]:lower() end
end)

-- face
c:eyeLocked(23, 24)
c:eyeLocked(36, 24)
c:cheek(21, 31) c:cheek(41, 31)
-- small happy open mouth, glowing inside
O.flat(c, c:rect(30, 31, 34, 32), EMBR[2], "mouth") O.dots(c, { { 31, 32 }, { 32, 32 }, { 33, 32 } }, EMBR[4])
O.dots(c, { { 29, 30 }, { 30, 30 }, { 31, 30 }, { 32, 30 }, { 33, 30 }, { 34, 30 }, { 35, 30 }, { 29, 31 }, { 35, 31 }, { 30, 33 }, { 31, 33 }, { 32, 33 }, { 33, 33 }, { 34, 33 } }, P.ink)

-- the forgotten candle flame on the crown crack
O.dots(c, { { 25, 13 }, { 25, 12 }, { 26, 13 } }, EMBR[3]) O.dot(c, 26, 12, EMBR[4]) O.dot(c, 25, 11, EMBR[5]) O.dot(c, 26, 10, EMBR[4])

O.done(c, "pl-cwy-1-yard", function(c)
  -- heat ripples (un-outlined) and drifting sparks
  for _, w in ipairs({ { 24, 4 }, { 32, 2 }, { 40, 5 } }) do
    for j = 0, 6 do c:put(w[1] + ((j // 2) % 2), w[2] + j, j < 3 and HEAT[2] or HEAT[1]) end
  end
  for _, p in ipairs({ { 12, 20 }, { 52, 14 }, { 54, 40 }, { 10, 44 } }) do c:put(p[1], p[2], EMBR[4]) end
  for _, p in ipairs({ { 13, 20 }, { 53, 14 } }) do c:put(p[1], p[2], EMBR[3]) end
  -- warm light on the ground below the tip
  for x = 27, 37 do c:put(x, 58, EMBR[2]) end for x = 29, 35 do c:put(x, 59, EMBR[1]) end
end)
