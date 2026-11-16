-- Coffee Crumb (th-coffee-crumb), yard sprite 64x64. Opus second pass (art-2701-pals-all/c05/opus2) over the Haiku pass.
-- Brewroot, common, Thornacre. "Roasts the beans with great care and a very large hat."
-- A plump roasted coffee bean (glossy dark-roast ramp, the bean's S-crease running down its belly) under a hat
-- far too big for it: a dusk-purple felt fedora with a pinched crown and a red band, brim wider than the bean.
-- The brim throws a shadow band over its brow; locked eyes sit just under it. It holds a little wooden
-- roasting paddle with two beans in the scoop, with great care.
-- Fixes vs Haiku: bean now reads as a coffee bean (crease, gloss), hat has a fedora shape and a band rather
-- than a flat box, the brim casts shade on the face, five-plus tone ramps everywhere.
-- quirk: a curl of roasting steam rises out of the dent in the hat's crown.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("th-coffee-crumb-yard", 64)

local BEAN = { "#2e1a1c", "#4a2a22", "#6b3d2a", "#8f5634", "#b67645", "#d8a067" }
local HAT  = { "#251c38", "#3a2b56", "#54407c", "#7058a0", "#8e77bf", "#b29ddb" }
local BAND = { "#4f1a26", "#7f2a33", "#b2423d", "#de6a4e", "#f29a6c" }
local WOOD = { "#3d2620", "#64402c", "#8d6340", "#b48a58", "#d6b27c" }
local STM  = { "#9e93ad", "#c6bccf", "#e6dfe8", "#f7f2f4" }
local BNC  = "#5b4a6e"

c:groundShadow(32, 58, 15, 2.5)

-- feet
for _, fx in ipairs({ 26, 38 }) do
  O.shade(c, c:ellipse(fx, 55.5, 3.5, 2), BEAN, { R = 1, amb = .25, sep = BEAN[1], rim = true })
end

-- bean body
local body = c:ellipse(32, 39, 13, 15)
local bI, bT = O.shade(c, body, BEAN, { sphere = { 29, 35, 17 }, amb = .3, wrap = .45, rim = true, bounce = BNC, bmax = 2 })
-- roast mottling (keeps the lighting)
O.tex(c, bI, bT, BEAN, function(x, y, i)
  local h = H(x, y, 5)
  if h > .965 and i >= 3 and i <= 5 then return -1 end
  if h < .015 and i >= 2 and i <= 4 then return 1 end
end)
-- the bean crease: an S down the belly, dark groove with a lit lip on its left
local crease = { { 33, 44 }, { 32, 45 }, { 31, 46 }, { 31, 47 }, { 32, 48 }, { 33, 49 }, { 33, 50 }, { 32, 51 }, { 31, 52 } }
O.mark(c, crease, BEAN[1])
local lip = {}
for _, p in ipairs(crease) do lip[#lip+1] = { p[1] - 1, p[2] } end
O.mark(c, lip, BEAN[5])
O.mark(c, { { 34, 45 }, { 34, 50 } }, BEAN[2])

-- arms: left at the side, right forward holding the paddle
O.shade(c, c:ellipse(18.5, 42, 2.5, 4.5), BEAN, { R = 1, amb = .25, sep = BEAN[1], rim = true })

-- roasting paddle: handle down-left to up-right, scoop with two beans
local hm, hn = O.tube({ { 44, 50 }, { 46, 47 }, { 49, 43 }, { 51, 39 } }, function() return 1 end)
O.shadeN(c, hm, hn, WOOD, { amb = .3, sep = WOOD[1] })
local scoop = c:ellipse(52.5, 36, 3.5, 2.5)
O.shade(c, scoop, WOOD, { R = 1, amb = .3, sep = WOOD[1], rim = true })
O.dots(c, { { 50, 35 }, { 51, 35 }, { 52, 35 }, { 53, 35 }, { 54, 35 }, { 55, 35 } }, WOOD[2]) -- scoop hollow
for _, b in ipairs({ { 51, 33 }, { 54, 33 } }) do
  local m = c:ellipse(b[1], b[2], 1.5, 1.5)
  O.shade(c, m, BEAN, { R = 1, amb = .3, sep = BEAN[1] })
  O.dot(c, b[1], b[2] + 1, BEAN[1])
end
O.shade(c, c:ellipse(45.5, 45, 2.5, 3), BEAN, { R = 1, amb = .3, sep = BEAN[1], rim = true }) -- hand over the handle

-- hat: wide brim first, crown on top
local brim = c:ellipse(32, 24, 22, 4)
local brb = {}
brim:each(function(x, y) if y >= 26 then brb[K(x, y)] = -1 end end)
local hI, hT = O.shade(c, brim, HAT, { R = 2, bias = brb, amb = .2, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
-- brim upturn: lit top edge line
for x = 12, 52 do
  local y = 24 - math.floor(math.sqrt(math.max(0, 1 - ((x - 32) / 22.5) ^ 2)) * 4 + .5)
  if x < 32 then O.mark(c, { { x, y + 1 } }, HAT[5]) end
end
local crown = c:poly{ { 20, 22 }, { 21, 12 }, { 23, 8 }, { 29, 7 }, { 32, 9 }, { 35, 7 }, { 41, 8 }, { 43, 12 }, { 44, 22 } }
local cb = {}
crown:each(function(x, y) if x > 38 then cb[K(x, y)] = -1 end end)
local cI, cT = O.shade(c, crown, HAT, { R = 4, bias = cb, amb = .2, wrap = .35, sep = HAT[1], rim = true, bounce = BNC, bmax = 2 })
-- felt nap
O.tex(c, cI, cT, HAT, function(x, y, i) if H(x, y, 9) > .95 and i >= 3 and i <= 5 then return 1 end end)
-- crown pinch: dent line from the top
O.mark(c, { { 32, 10 }, { 32, 11 }, { 32, 12 } }, HAT[2]) O.mark(c, { { 31, 10 }, { 31, 11 } }, HAT[5])
-- band
local band = c:rect(20, 18, 44, 21)
O.shade(c, band, BAND, { R = 1, amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 }, sep = HAT[1] })
O.mark(c, { { 21, 18 }, { 22, 18 }, { 23, 18 }, { 24, 18 }, { 25, 18 }, { 26, 18 }, { 27, 18 } }, BAND[5])
-- bow knot on the band (left)
O.shade(c, c:rect(23, 18, 26, 21), BAND, { R = 1, amb = .5, sep = BAND[1] })
O.dots(c, { { 24, 19 }, { 25, 20 } }, BAND[2]) O.dot(c, 23, 18, BAND[5])

-- brim shadow on the brow
for x = 21, 43 do
  if c:get(x, 28) then O.mark(c, { { x, 28 } }, BEAN[2]) end
  if c:get(x, 29) and (x % 3 ~= 0) then O.mark(c, { { x, 29 } }, BEAN[3]) end
end

-- face
c:eyeLocked(24, 31) c:eyeLocked(35, 31)
O.dots(c, { { 23, 30 }, { 24, 30 }, { 40, 30 }, { 39, 30 } }, BEAN[1]) -- brow tilt: proud
c:cheek(21, 37) c:cheek(41, 37)
O.dots(c, { { 29, 38 }, { 30, 39 }, { 31, 39 }, { 32, 39 }, { 33, 39 }, { 34, 38 } }, P.ink)
O.dot(c, 31, 40, "#c2463f") O.dot(c, 32, 40, "#c2463f")

-- quirk: roasting steam curling up out of the crown dent: soft un-outlined wisps (drawn after the outline)
local function wisps(c)
  local W1 = { { 31, 8 }, { 30, 7 }, { 30, 6 }, { 31, 5 }, { 32, 4 }, { 32, 3 }, { 31, 2 }, { 30, 1 }, { 30, 0 } }
  local W2 = { { 34, 8 }, { 35, 7 }, { 35, 6 }, { 34, 5 }, { 34, 4 }, { 35, 3 }, { 36, 2 } }
  for i, p in ipairs(W1) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], i < 4 and STM[4] or (i < 7 and STM[3] or STM[2])) end end
  for i, p in ipairs(W2) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], i < 3 and STM[3] or STM[2]) end end
end
O.shift(c, -1, 2)
O.done(c, "th-coffee-crumb-yard", wisps)
