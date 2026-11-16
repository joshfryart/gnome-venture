-- Bill Brolly (mt-bill-brolly), yard sprite 64x64. Opus second pass (art-2701-pals-all/c07/opus2), from the Haiku pass.
-- Monsoontangle, rare, wayfinder. "Carries a giant leaf for an umbrella and shares it with the nearest frog."
-- A hornbill in true colours: charcoal-plum body, cream belly and tail band, a big curved gold beak with an
-- ember casque, long lashes. One wing holds the stalk of a giant arched leaf (midrib, paired veins, a dripping
-- tip) that is held well out to the right, over the frog.
-- Haiku fixes: the bird is a black-and-white hornbill instead of purple; the beak and casque are big enough to
-- be the read; the leaf is arched like a brolly; the frog is a real little sprite with bulging eyes and a smile.
-- quirk: the nearest frog, sitting dry under the leaf's edge; one rare sparkle on the leaf.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mt-bill-brolly-yard", 64)

local CHAR = { "#2e2434", "#3e3248", "#54465e", "#6c5e78", "#8a7c96", "#a89cb2" }
local CRM  = { "#b8a890", "#d8ccb0", "#efe6cc", "#fff4dc" }
local BEAK = { "#8f4a1f", "#d98322", "#f5b82e", "#ffd45e", "#ffe9a0" }
local CASQ = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local LEAF = { "#1f4a3a", "#2a6440", "#3f8a48", "#5eaa52", "#8ccc64", "#bce488" }
local FROG = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local SKY  = { "#5f9ad0", "#8bc4ea", "#e4f6ff" }

c:groundShadow(30, 58, 14, 2)
c:groundShadow(51, 58, 6, 1.5)

-- tail (behind), long with a cream band
local tl, tn, tT = O.tube({ { 22, 44 }, { 17, 49 }, { 13, 53 }, { 10, 56 } }, function(t) return 3.2 - t * 1.2 end)
O.shadeN(c, tl, tn, CHAR, { amb = .3, wrap = .45, sep = CHAR[1], rim = true })
tl:each(function(x, y) local t = tT[K(x, y)] or 0 if t > .55 and t < .8 then c:put(x, y, (x + y) % 5 == 0 and CRM[2] or CRM[3], { r = { name = "band" } }) end end)
-- feet
for _, fx in ipairs({ 26, 33 }) do O.flat(c, c:rect(fx, 52, fx + 1, 56), "#74758c", "leg") O.flat(c, c:rect(fx - 1, 56, fx + 3, 57), "#aaa9b8", "toes") end

-- leaf stalk (from the wing tip up under the leaf)
local stalk, sn = O.tube({ { 38, 39 }, { 37, 30 }, { 35, 22 }, { 34, 14 } }, function() return 1 end)
O.shadeN(c, stalk, sn, LEAF, { amb = .3, sep = LEAF[1] })

-- body
local body = c:ellipse(29, 41, 10, 11)
O.shade(c, body, CHAR, { sphere = { 25, 34, 16 }, amb = .3, wrap = .45, sep = CHAR[1], rim = true, bounce = "#5a6a9a", bmax = 2 })
local bel = c:ellipse(30, 45, 6, 6.5) bel:clip(body)
O.shade(c, bel, CRM, { R = 3, amb = .4, wrap = .5, cuts = { .3, .55, .8 } })
-- wing raised forward, holding the stalk
local wing = c:poly{ { 31, 34 }, { 37, 35 }, { 41, 39 }, { 39, 42 }, { 33, 44 }, { 29, 41 } }
local wb = {} wing:each(function(x, y) if (x - y) % 3 == 0 then wb[K(x, y)] = -1 end end) -- feather rows
O.shade(c, wing, CHAR, { R = 2, amb = .3, wrap = .45, bias = wb, sep = CHAR[1], rim = true })
O.dots(c, { { 38, 41 }, { 39, 40 } }, CRM[3]) -- pale wing tips

-- head
local head = c:ellipse(30, 27, 7.5, 7)
O.shade(c, head, CHAR, { sphere = { 27, 23, 11 }, amb = .32, wrap = .45, sep = CHAR[1], rim = true })
-- beak: big curved gold bill pointing right, casque on top
local beak = c:poly{ { 35, 25 }, { 44, 24 }, { 51, 26 }, { 55, 30 }, { 52, 30 }, { 46, 30 }, { 36, 30 } }
local bk = {} beak:each(function(x, y) if y == 28 then bk[K(x, y)] = -2 end end) -- mouth line
O.shade(c, beak, BEAK, { R = 2, amb = .32, wrap = .45, bias = bk, sep = BEAK[1], rim = true })
local casq = c:poly{ { 34, 22 }, { 38, 18 }, { 46, 19 }, { 49, 23 }, { 45, 24 }, { 36, 25 } }
O.shade(c, casq, CASQ, { R = 2, amb = .32, wrap = .45, cuts = { .3, .55, .8 }, sep = CASQ[1], rim = true })
O.dots(c, { { 39, 19 }, { 40, 19 }, { 41, 19 } }, CASQ[4])
-- face: eyes with long lashes (hornbills have them)
c:eyeLocked(24, 24)
c:eyeLocked(31, 24)
O.dots(c, { { 24, 23 }, { 23, 22 }, { 26, 22 }, { 27, 21 } }, "#2b1c26")
O.dots(c, { { 31, 23 }, { 30, 22 }, { 33, 22 }, { 34, 21 } }, "#2b1c26")
c:cheek(23, 30) c:cheek(32, 30)

-- the giant leaf brolly: arched, midrib, paired veins, drip tip on the right
local leaf = HP.mask()
for x = 4, 61 do
  local t = (x - 4) / 57
  local top = 14 - math.sin(t * math.pi) * 9 + t * 3
  local th = 2.5 + math.sin(t * math.pi) * 3.5
  for y = math.floor(top), math.floor(top + th) do leaf:set(x, y) end
end
leaf:cut(c:poly{ { 13, 15 }, { 15, 11 }, { 17, 15 } }) -- a rain tear
local lb = {}
leaf:each(function(x, y)
  local t = (x - 4) / 57
  local mid = 14 - math.sin(t * math.pi) * 9 + t * 3 + 1.5 + math.sin(t * math.pi) * 1.2
  if math.abs(y - mid) < .6 then lb[K(x, y)] = 2 end
  if math.abs(y - mid) >= .6 and (x + math.floor(math.abs(y - mid) * 1.3)) % 6 == 0 then lb[K(x, y)] = -1 end
end)
O.shade(c, leaf, LEAF, { R = 2, amb = .3, wrap = .45, bias = lb, sep = LEAF[1], rim = true, bounce = "#3a6a8a", bmax = 2 })

-- quirk: the frog sitting dry under the leaf's edge
local fr = c:ellipse(51, 54, 5, 3)
fr:add(c:ellipse(48.5, 50.5, 2, 2)) fr:add(c:ellipse(53.5, 50.5, 2, 2))
O.shade(c, fr, FROG, { R = 2, amb = .3, wrap = .45, cuts = { .3, .55, .8 }, sep = FROG[1], rim = true })
O.flat(c, c:rect(48, 50, 49, 51), "#2b1c26", "eye") O.dot(c, 48, 50, "#fff4d6")
O.flat(c, c:rect(53, 50, 54, 51), "#2b1c26", "eye") O.dot(c, 53, 50, "#fff4d6")
O.dots(c, { { 49, 54 }, { 50, 55 }, { 51, 55 }, { 52, 55 }, { 53, 54 } }, FROG[1]) -- grin
O.dots(c, { { 46, 56 }, { 47, 56 }, { 55, 56 }, { 56, 56 } }, FROG[2]) -- feet

O.done(c, "mt-bill-brolly-yard", function(c)
  c:sparkle(10, 4)
  for _, p in ipairs({ { 61, 21 }, { 61, 23 }, { 61, 24 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], SKY[1], { r = { name = "drip" } }) end end
end)
