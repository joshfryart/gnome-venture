-- Ember Flake (pl-cwy-1), perch sprite 36x36. Opus second pass (c11/opus2), hand-built at this size.
-- A cinder scale: pale ash face plate (so the pill eyes read), ash-grey crust on top, charcoal plates cracked apart by glowing ember seams that get hotter toward
-- its pointed tip, red-hot lower edge. 2x3 pill eyes on the big face plate, small glowing open mouth.
-- quirk: it stayed warm: two heat ripples rising off its top and a spark.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-1-perch", 36)

local CHAR = { "#1c1420", "#2e2028", "#463438", "#6a5656", "#958682", "#c4b8ac" }
local EMBR = { "#7a2018", "#c8401c", "#f07a26", "#ffbe48", "#ffe696" }
local HEAT = { "#e06a2a", "#f6a040" }

c:groundShadow(18, 33, 8, 1)
local sc = c:ellipse(17, 15, 10, 8.5)
sc:add(c:poly{ { 7, 18 }, { 27, 17 }, { 25, 25 }, { 23, 30 }, { 21, 31 } })
local sI, sT = O.shade(c, sc, CHAR, { sphere = { 13, 9, 15 }, amb = .2, wrap = .35, rim = true })
local seeds = { { 17, 14 }, { 9, 9 }, { 25, 9 }, { 8, 19 }, { 26, 17 }, { 14, 24 }, { 22, 24 }, { 21, 30 } }
sc:each(function(x, y)
  local q = y * c.w + x
  if c.own[q] ~= sT then return end
  local d1, d2, k1 = 1e9, 1e9, 0
  for k, sd in ipairs(seeds) do
    local d = math.sqrt((x - sd[1]) ^ 2 + (y - sd[2]) ^ 2) * ((k == 1) and .5 or 1)
    if d < d1 then d2 = d1 d1 = d k1 = k elseif d < d2 then d2 = d end
  end
  -- the face plate is a paler ash so the pill eyes read
  if k1 == 1 then c.pix[q] = CHAR[math.min(6, (sI[K(x, y)] or 3) + 2)]:lower() end
  local heat = (y - 7) / 24
  if d2 - d1 < 1 then c.pix[q] = (heat > .6 and EMBR[4] or (heat > .3 and EMBR[3] or EMBR[2])):lower() end
  if y > 22 and (not sc:has(x, y + 1) or not sc:has(x + 1, y)) then c.pix[q] = EMBR[3]:lower() end
end)
-- face
c:eyeSmall(13, 12)
c:eyeSmall(20, 12)
O.dot(c, 11, 16, P.petal.base) O.dot(c, 24, 16, P.petal.base)
O.dots(c, { { 16, 17 }, { 17, 17 }, { 18, 17 } }, EMBR[2]) O.dot(c, 17, 18, EMBR[4])
O.dots(c, { { 15, 16 }, { 16, 16 }, { 17, 16 }, { 18, 16 }, { 19, 16 }, { 15, 17 }, { 19, 17 }, { 16, 18 }, { 18, 18 } }, P.ink)

O.done(c, "pl-cwy-1-perch", function(c)
  for _, w in ipairs({ { 13, 1 }, { 21, 1 } }) do for j = 0, 3 do c:put(w[1] + ((j // 2) % 2), w[2] + j, j < 2 and HEAT[2] or HEAT[1]) end end
  c:put(31, 10, EMBR[4]) c:put(4, 25, EMBR[3])
end)
