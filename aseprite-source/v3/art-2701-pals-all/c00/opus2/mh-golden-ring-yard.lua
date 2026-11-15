-- Golden Ring (mh-golden-ring), yard sprite 64x64. Opus second pass (c00/opus2), built from the Haiku first pass.
-- Rootwarden, uncommon, Maizehollow. "A hole shaped like a good harvest."
-- A thick golden hoop of twisted straw standing on its edge: rope twist round the hoop (smoothed off on the lower
-- band, which is the face), torus lighting with a bright rim on the upper-left, warm bounce inside the hole.
-- The hole is much bigger than in the first pass so what is inside reads.
-- quirk: a wheat sheaf, tied with an ember ribbon, fills the hole exactly; its ears poke out over the top of the hoop.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mh-golden-ring-yard", 64)

local GOLD = { "#6e3418", "#a8581c", "#d8861e", "#f5b02c", "#ffd658", "#fff0a0" }
local WHT  = { "#7a4a1f", "#b07a32", "#d8a848", "#f0cc6a", "#fbe49a" }
local STLK = { "#7a5a2a", "#a88442", "#d0ac62", "#ecd290" }
local RIB  = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

c:groundShadow(32, 57, 18, 2.5)

-- the sheaf (behind the hoop): stalks fanned top and bottom, pinched at the tie
local stalks = { { 22, 7 }, { 27, 4 }, { 32, 2 }, { 37, 4 }, { 42, 7 } }
for i, s in ipairs(stalks) do
  local m, n = O.tube({ { s[1], s[2] + 6 }, { 32 + (s[1] - 32) * .3, 22 }, { 32 + (s[1] - 32) * .1, 31 }, { 32 + (s[1] - 32) * .8, 44 } }, function(t) return .9 end)
  O.shadeN(c, m, n, STLK, { amb = .35, wrap = .5, cuts = { .3, .55, .8 } })
end
-- wheat ears: plump grain stacks with a whisker of awn
for i, s in ipairs(stalks) do
  local ear = HP.mask()
  for k = 0, 3 do ear:add(c:ellipse(s[1] - .5 + (k % 2), s[2] + 1 + k * 2, 1.5, 1.2)) end
  ear:add(c:rect(s[1], s[2] + 1, s[1], s[2] + 8))
  local eI, eT = O.shade(c, ear, WHT, { R = 1, amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 }, sep = WHT[1] })
  O.tex(c, eI, eT, WHT, function(x, y, k) if (y - s[2]) % 2 == 0 and x ~= s[1] then return -1 end end) -- grain rows
  O.dot(c, s[1], s[2] - 1, WHT[3]) O.dot(c, s[1] + (i % 2 == 0 and 1 or -1), s[2] - 2, WHT[3])
end
-- ribbon tie round the waist of the sheaf
O.shade(c, c:rect(28, 30, 36, 32), RIB, { R = 1, amb = .35, cuts = { .3, .6, .8 }, sep = RIB[1] })
O.shade(c, c:poly{ { 35, 32 }, { 39, 37 }, { 37, 38 }, { 34, 33 } }, RIB, { R = 1, amb = .4, cuts = { .3, .6, .8 } })

-- the hoop
local hoop = c:ellipse(32, 33, 22, 22)
local hole = c:ellipse(32, 28.5, 11, 11)
hoop:cut(hole)
local hI, hT = O.shade(c, hoop, GOLD, { R = 6, amb = .12, wrap = .3, rim = true, bounce = "#a0587a", bmax = 2 })
-- straw rope twist, smoothed off over the face band
local function faceband(x, y) return y >= 40 and x >= 19 and x <= 45 end
O.tex(c, hI, hT, GOLD, function(x, y, i)
  if faceband(x, y) then return 0 end
  local a = math.atan(y - 33, x - 32)
  local r = math.sqrt((x - 32)^2 + (y - 33)^2)
  local v = (a / (2 * math.pi) * 26 + r * .45) % 1
  if v < .14 then return -2 end
  if v < .3 then return -1 end
  if v > .8 and i >= 3 and i <= 5 then return 1 end
end)

-- face on the lower band
c:eyeLocked(24, 42)
c:eyeLocked(35, 42)
c:cheek(21, 48) c:cheek(41, 48)
O.dots(c, { { 29, 49 }, { 30, 50 }, { 31, 50 }, { 32, 50 }, { 33, 50 }, { 34, 49 } }, P.ink)
O.dots(c, { { 31, 51 }, { 32, 51 } }, GOLD[2])
c:sparkle(14, 18)

O.shift(c, 0, 0)
O.done(c, "mh-golden-ring-yard")
