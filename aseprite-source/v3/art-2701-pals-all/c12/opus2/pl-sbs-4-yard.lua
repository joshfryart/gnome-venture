-- Eightlegs Clasp (pl-sbs-4), yard sprite 64x64. Opus second pass (c12/opus2), built on c12/haiku.
-- Thornblade, uncommon, Hollow of the Silverback Spider. "Eight spider legs that hold on tight and wiggle."
-- Haiku was a flat purple spider on a plank (legs a uniform tangle, no clasp). Now a little silverback spider
-- seen from the front, clasping a twig: a silver-grey abdomen with a dark plum chevron saddle, a plum head
-- carrying the face, and eight thick jointed plum legs (pale joint bands, tiny gold claw tips) fanned out at
-- different knee heights so they do not tangle, seven of them gripping the twig from both sides.
-- quirk: the back right leg is up in the air and wiggling (motion ticks).
-- closer look: six tiny extra eyes in a row above the two big ones (eight eyes in all).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-sbs-4-yard", 64)

local SILV = { "#3a3a56", "#5c5e7e", "#8a8ca8", "#b4b6cc", "#d8dae6", "#eef0f6" }
local PLUM = { "#2e1c3a", "#4a2e5c", "#6a467e", "#8e66a2", "#b28ec2", "#d4b8e0" }
local BARK = { "#3a2428", "#51302b", "#864c33", "#b97a4a", "#d39a62", "#e8b982" }

c:groundShadow(32, 58, 20, 2)

-- the twig it clasps
local tw, tn = O.tube({ { 5, 50 }, { 20, 47 }, { 42, 48 }, { 59, 51 } }, function() return 2.5 end)
local wI, wT = O.shadeN(c, tw, tn, BARK, { amb = .25, wrap = .4, rim = true })
O.tex(c, wI, wT, BARK, function(x, y, i) if (x * 2 + y) % 9 == 0 and i >= 3 then return -1 end end)
O.shade(c, c:ellipse(46, 53, 1.5, 2), BARK, { R = 1, amb = .2 }) -- little broken twig stub below

-- legs: hip -> knee (up and out) -> foot (on the twig); far legs first
local function leg(hip, knee, foot, w)
  local m1, n1 = O.tube({ hip, { (hip[1] + knee[1]) / 2, knee[2] + 1 }, { knee[1], knee[2] }, knee }, function() return w end)
  local m2, n2 = O.tube({ knee, { knee[1] + (foot[1] - knee[1]) * .3, knee[2] + 2 }, { foot[1], foot[2] - 4 }, foot }, function(t) return w - .5 * t end)
  O.shadeN(c, m2, n2, PLUM, { amb = .3, wrap = .4, sep = PLUM[1] })
  O.shadeN(c, m1, n1, PLUM, { amb = .3, wrap = .4, sep = PLUM[1], rim = true })
  -- pale joint band at the knee, gold claw tip
  O.dots(c, { { knee[1], knee[2] }, { knee[1] + 1, knee[2] } }, PLUM[6])
  O.dot(c, foot[1], foot[2] + 1, "#f5b82e")
end
-- left side: three legs gripping the twig, one short front leg
leg({ 23, 24 }, { 11, 11 }, { 6, 48 }, 1.6)
leg({ 23, 30 }, { 5, 27 }, { 13, 47 }, 1.7)
leg({ 25, 37 }, { 13, 38 }, { 20, 46 }, 1.8)
leg({ 27, 42 }, { 23, 44 }, { 27, 46 }, 1.6)
-- right side: two gripping, one short front leg ...
leg({ 41, 30 }, { 59, 27 }, { 51, 47 }, 1.7)
leg({ 39, 37 }, { 51, 38 }, { 44, 46 }, 1.8)
leg({ 37, 42 }, { 41, 44 }, { 37, 46 }, 1.6)
-- ... and quirk: the back right leg is up in the air, wiggling
local m1, n1 = O.tube({ { 41, 24 }, { 46, 18 }, { 50, 13 }, { 52, 11 } }, function() return 1.6 end)
O.shadeN(c, m1, n1, PLUM, { amb = .3, wrap = .4, sep = PLUM[1], rim = true })
local m2, n2 = O.tube({ { 52, 11 }, { 55, 9 }, { 57, 7 }, { 59, 7 } }, function(t) return 1.6 - .6 * t end)
O.shadeN(c, m2, n2, PLUM, { amb = .3, wrap = .4, sep = PLUM[1] })
O.dots(c, { { 52, 11 }, { 53, 11 } }, PLUM[6]) O.dot(c, 60, 7, "#f5b82e")

-- abdomen: silver back with a plum chevron saddle
local abd = c:ellipse(32, 24, 12, 11)
local aI, aT = O.shade(c, abd, SILV, { sphere = { 27, 18, 18 }, amb = .25, wrap = .45, rim = true, bounce = "#7a6aa8", bmax = 2 })
O.tex(c, aI, aT, SILV, function(x, y, i)
  local dx = math.abs(x - 32)
  local v = (y + dx * .8) % 5
  if y < 31 and dx < 7 and v < 1.2 then return -3 end
  if H(x, y, 13) > .93 and i >= 3 then return 1 end -- silky hairs
end)
-- head (front), carries the face
local head = c:ellipse(32, 38, 9.5, 7.5)
local hI, hT = O.shade(c, head, PLUM, { sphere = { 28, 34, 13 }, amb = .35, wrap = .5, rim = true })

c:cheek(25, 41) c:cheek(37, 41)
O.dots(c, { { 30, 42 }, { 31, 43 }, { 32, 43 }, { 33, 42 } }, P.ink)

O.done(c, "pl-sbs-4-yard", function(c)
  c:eyeLocked(25, 35)
  c:eyeLocked(34, 35)
  -- closer look: six tiny extra eyes, a row above the big pair
  for _, x in ipairs({ 27, 29, 31, 33, 35, 37 }) do c:put(x, 33, P.ink) end
  -- wiggle ticks round the raised foot
  for _, p in ipairs({ { 61, 3 }, { 62, 2 }, { 61, 9 }, { 62, 10 }, { 56, 3 }, { 55, 2 } }) do c:put(p[1], p[2], P.ink) end
end)
