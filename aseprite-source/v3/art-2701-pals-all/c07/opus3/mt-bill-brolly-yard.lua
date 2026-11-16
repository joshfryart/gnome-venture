-- Bill Brolly (mt-bill-brolly), yard sprite 64x64. Opus richness pass (art-2701-pals-all/c07/opus3), built on opus2.
-- opus3: scalloped breast/back feathers, separated primaries with pale tips, violet-teal sheen on the crown, serrated
-- bill edge, horn streaks and a nostril on the bill, banded casque, rain beads on the leaf with a wet dark rim,
-- spotted frog with a pale throat; closer look: a little brass wayfinder compass hung at its neck (red needle).
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
local bI, bT = O.shade(c, body, CHAR, { sphere = { 25, 34, 16 }, amb = .3, wrap = .45, sep = CHAR[1], rim = true, bounce = "#5a6a9a", bmax = 2 })
-- scalloped feathers: little arcs in staggered rows (dark arc, lit pixel above)
O.tex(c, bI, bT, CHAR, function(x, y, i)
  local row = y // 3
  local xx = (x + (row % 2) * 2) % 4
  if y % 3 == 2 and xx ~= 0 and i >= 2 then return -1 end
  if y % 3 == 0 and xx == 2 and i <= 4 then return 1 end
end)
local bel = c:ellipse(30, 45, 6, 6.5) bel:clip(body)
local eI, eT = O.shade(c, bel, CRM, { R = 3, amb = .4, wrap = .5, cuts = { .3, .55, .8 } })
O.tex(c, eI, eT, CRM, function(x, y, i) if y % 4 == 3 and (x + (y // 4) * 2) % 5 == 0 and i >= 2 then return -1 end end) -- soft down flecks
-- wing raised forward, holding the stalk
local wing = c:poly{ { 31, 34 }, { 37, 35 }, { 41, 39 }, { 39, 42 }, { 33, 44 }, { 29, 41 } }
local wb = {} wing:each(function(x, y) if (x - y) % 3 == 0 then wb[K(x, y)] = -1 end end) -- feather rows
O.shade(c, wing, CHAR, { R = 2, amb = .3, wrap = .45, bias = wb, sep = CHAR[1], rim = true })
-- closer look: a brass wayfinder compass on a cord at its neck
O.dots(c, { { 24, 32 }, { 24, 33 }, { 25, 34 } }, "#c8a060")
local cmp = c:ellipse(26, 37, 2.2, 2.2)
O.shade(c, cmp, BEAK, { R = 1, amb = .4, cuts = { .25, .45, .65, .85 }, sep = "#2b1c26" })
O.dot(c, 26, 37, "#efe6cc") O.dot(c, 26, 36, "#e8493b") O.dot(c, 26, 38, "#54465e")
-- separated primaries with pale tips
for k = 0, 2 do O.dots(c, { { 34 + k * 2, 43 - k }, { 35 + k * 2, 43 - k } }, CHAR[1]) end
O.dots(c, { { 38, 41 }, { 39, 40 }, { 36, 42 }, { 34, 43 } }, CRM[3])

-- head
local head = c:ellipse(30, 27, 7.5, 7)
O.shade(c, head, CHAR, { sphere = { 27, 23, 11 }, amb = .32, wrap = .45, sep = CHAR[1], rim = true })
O.dots(c, { { 26, 21 }, { 27, 20 }, { 28, 20 } }, "#7a6aa8") O.dots(c, { { 29, 20 }, { 30, 20 } }, "#4f8a96") -- crown sheen
-- beak: big curved gold bill pointing right, casque on top
local beak = c:poly{ { 35, 25 }, { 44, 24 }, { 51, 26 }, { 55, 30 }, { 52, 30 }, { 46, 30 }, { 36, 30 } }
local bk = {} beak:each(function(x, y) if y == 28 then bk[K(x, y)] = -2 end end) -- mouth line
local kI, kT = O.shade(c, beak, BEAK, { R = 2, amb = .32, wrap = .45, bias = bk, sep = BEAK[1], rim = true })
O.tex(c, kI, kT, BEAK, function(x, y, i) if y ~= 28 and x % 5 == 0 and y < 28 and i >= 3 then return -1 end end) -- horn streaks
for x = 38, 50, 3 do O.dot(c, x, 29, BEAK[1]) end -- serrated cutting edge
O.dot(c, 37, 26, BEAK[1]) -- nostril
local casq = c:poly{ { 34, 22 }, { 38, 18 }, { 46, 19 }, { 49, 23 }, { 45, 24 }, { 36, 25 } }
O.shade(c, casq, CASQ, { R = 2, amb = .32, wrap = .45, cuts = { .3, .55, .8 }, sep = CASQ[1], rim = true })
O.dots(c, { { 39, 19 }, { 40, 19 }, { 41, 19 } }, CASQ[4])
O.dots(c, { { 43, 20 }, { 43, 21 }, { 42, 22 }, { 42, 23 } }, CASQ[1]) O.dots(c, { { 44, 20 }, { 44, 21 } }, "#f5b82e") -- casque band
-- face: eyes with long lashes (hornbills have them)
c:eyeLocked(24, 24)
c:eyeLocked(31, 24)
O.dots(c, { { 24, 23 }, { 23, 22 }, { 26, 22 }, { 27, 21 } }, "#2b1c26")
O.dots(c, { { 31, 23 }, { 30, 22 }, { 33, 22 }, { 34, 21 } }, "#2b1c26")
c:cheek(23, 30) c:cheek(32, 30)

-- the giant leaf brolly: arched, midrib, paired veins, drip tip on the right
local leaf = HP.mask()
for x = 4, 59 do
  local t = (x - 4) / 55
  local top = 14 - math.sin(t * math.pi) * 9 + t * 3
  local th = 3 + math.sin(t * math.pi) * 4.5
  for y = math.floor(top), math.floor(top + th) do leaf:set(x, y) end
end
leaf:cut(c:poly{ { 13, 15 }, { 15, 11 }, { 17, 15 } }) -- a rain tear
local lb = {}
leaf:each(function(x, y)
  local t = (x - 4) / 55
  local mid = 14 - math.sin(t * math.pi) * 9 + t * 3 + 1.5 + math.sin(t * math.pi) * 1.8
  if math.abs(y - mid) < .6 then lb[K(x, y)] = 2 end
  if math.abs(y - mid) >= .6 and (x + math.floor(math.abs(y - mid) * 1.3)) % 6 == 0 then lb[K(x, y)] = -1 end
end)
O.shade(c, leaf, LEAF, { R = 2, amb = .3, wrap = .45, bias = lb, sep = LEAF[1], rim = true, bounce = "#3a6a8a", bmax = 2 })
-- rain beads on the leaf (lit top, dark foot)
for _, b in ipairs({ { 9, 10 }, { 22, 6 }, { 30, 6 }, { 44, 8 }, { 52, 12 } }) do
  if leaf:has(b[1], b[2]) and leaf:has(b[1], b[2] + 1) then O.dot(c, b[1], b[2], "#e4f6ff") O.dot(c, b[1], b[2] + 1, LEAF[2]) end
end
-- wet dark lower edge
leaf:each(function(x, y) if not leaf:has(x, y + 1) and x % 2 == 0 and x > 6 then O.dot(c, x, y, LEAF[2]) end end)

-- quirk: the frog sitting dry under the leaf's edge
local fr = c:ellipse(51, 54, 5, 3)
fr:add(c:ellipse(48.5, 50.5, 2, 2)) fr:add(c:ellipse(53.5, 50.5, 2, 2))
O.shade(c, fr, FROG, { R = 2, amb = .3, wrap = .45, cuts = { .3, .55, .8 }, sep = FROG[1], rim = true })
O.flat(c, c:rect(48, 50, 49, 51), "#2b1c26", "eye") O.dot(c, 48, 50, "#fff4d6")
O.flat(c, c:rect(53, 50, 54, 51), "#2b1c26", "eye") O.dot(c, 53, 50, "#fff4d6")
O.dots(c, { { 49, 54 }, { 50, 55 }, { 51, 55 }, { 52, 55 }, { 53, 54 } }, FROG[1]) -- grin
O.dots(c, { { 46, 56 }, { 47, 56 }, { 55, 56 }, { 56, 56 } }, FROG[2]) -- feet
O.dots(c, { { 50, 56 }, { 51, 56 }, { 52, 56 } }, "#e6eeb0") -- pale throat
O.dots(c, { { 47, 53 }, { 55, 53 }, { 54, 55 } }, FROG[1]) O.dot(c, 52, 52, FROG[4]) -- spots

O.done(c, "mt-bill-brolly-yard", function(c)
  c:sparkle(10, 4)
  for _, p in ipairs({ { 59, 21 }, { 59, 23 }, { 59, 24 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], SKY[1], { r = { name = "drip" } }) end end
end)
