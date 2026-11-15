-- Tide Tuck (ss-tide-tuck), yard sprite 64x64. Opus second pass (c00/opus2), built from the Haiku first pass.
-- Brewroot, common, Sunsprinkle. "Tucks itself into the sand just before a wave."
-- A small sand-gold dome creature with a ribbed shell back, dug into a sand mound up to its chin, the sand pulled
-- over it like a blanket; sand grain flecks, rim light.
-- quirk: the reason it is tucking: a breaking wave curls over it from behind. The first pass wave read as a blue
-- block; this one is a real curl (a hook-shaped tube of water with an open barrel, lit inner face, darker back,
-- cream foam along the crest and a spray lip at the tip) so the silhouette says "wave".
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ss-tide-tuck-yard", 64)

local SEA  = { "#1e3560", "#2a4a7a", "#2f6f9e", "#3f9cb8", "#6cc8c8", "#a8e8dc" }
local FOAM = { "#9cc8cc", "#d6ece4", "#fff4d6" }
local SAND = { "#8a6040", "#b88a58", "#d8ac72", "#ecca8e", "#f8e2ae" }
local SHEL = { "#7a3a2a", "#b0602e", "#d88c3a", "#f2b450", "#ffd678", "#fff0ae" }

c:groundShadow(32, 58, 27, 2)

-- the wave: hook-shaped tube rising from the right and curling over to the left
local wp = { { 50, 52 }, { 58, 22 }, { 42, 5 }, { 27, 18 } }
local wave, wn, WT, WS = O.tube(wp, function(t) return 10 * (1 - t) ^ .6 + 1.6 end)
wave:cut(c:rect(0, 53, 63, 63))
local wI, wTk = O.shadeN(c, wave, wn, SEA, { amb = .22, wrap = .4, bounce = "#1e2a50", bmax = 2 })
-- inner (concave, lit) face one tone up, back of the wave darker; streaks along the flow
O.tex(c, wI, wTk, SEA, function(x, y, i)
  local s, t = WS[K(x, y)], WT[K(x, y)]
  if not s then return 0 end
  if s < -.25 and t and t < .9 then
    if (t * 14 + s) % 1 < .12 then return 2 end
    return 1
  end
  if s > .6 then return -1 end
end)
-- foam along the crest: the outer top edge of the curl, scalloped
wave:each(function(x, y)
  local t, s = WT[K(x, y)], WS[K(x, y)]
  if t and s and t > .3 and t < .98 and s > .5 then
    local q = y * c.w + x
    if c.own[q] == wTk then c.pix[q] = (H(x, y, 3) > .45 or s > .8) and FOAM[3] or FOAM[2] end
  end
end)
-- spray lip at the tip
O.flat(c, c:ellipse(26, 20, 2.5, 2), FOAM[3], "spray")
O.flat(c, c:rect(24, 22, 24, 23), FOAM[2], "spray")

-- the creature: ribbed sand-gold dome
local dome = c:ellipse(27, 44, 11, 10)
local dI, dT = O.shade(c, dome, SHEL, { sphere = { 24, 40, 13 }, amb = .25, wrap = .4, rim = true, bounce = "#7a6a8a", bmax = 2, sep = SEA[1] })
-- shell ribs fanning up the back of the dome (kept off the face)
for _, r in ipairs({ { { 19, 37 }, { 17, 42 } }, { { 23, 35 }, { 22, 37 } }, { { 31, 35 }, { 32, 37 } }, { { 35, 37 }, { 37, 42 } } }) do
  local m = c:line(r, 1)
  m:each(function(x, y) local q = y * c.w + x if c.own[q] == dT then c.pix[q] = SHEL[math.max(1, (dI[K(x, y)] or 3) - 1)] end end)
end
O.mark(c, { { 22, 39 }, { 23, 38 } }, SHEL[6])

-- sand mound pulled up to its chin, with a lip of sand over the front
local sand = c:ellipse(32, 58, 29, 8)
sand:add(c:ellipse(27, 52, 16, 5))
sand:cut(c:rect(0, 59, 63, 63))
local sI, sT = O.shade(c, sand, SAND, { R = 3, amb = .3, wrap = .45, cuts = { .25, .45, .65, .85 }, sep = SAND[1] })
O.tex(c, sI, sT, SAND, function(x, y, i) local h = H(x, y, 9) if h > .9 then return -1 end if h < .06 then return 1 end end) -- grains
-- foam wash where the wave meets the sand
for x = 42, 58 do local y = 51 + ((x % 3 == 0) and 0 or 1) if c.own[y * c.w + x] then c.pix[y * c.w + x] = FOAM[3] end end

-- face peeking over the sand blanket
c:eyeLocked(20, 38)
c:eyeLocked(29, 38)
c:cheek(18, 44) c:cheek(34, 44)
O.dots(c, { { 25, 44 }, { 26, 45 }, { 27, 45 }, { 28, 44 } }, P.ink)

O.shift(c, 0, -1)
O.done(c, "ss-tide-tuck-yard", function(c)
  -- spray droplets off the tip (not outlined)
  for _, p in ipairs({ { 20, 18 }, { 19, 23 }, { 22, 14 } }) do c:put(p[1], p[2], FOAM[2]) end
end)
