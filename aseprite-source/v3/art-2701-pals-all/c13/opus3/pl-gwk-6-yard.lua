-- Grey Wolf Whistle (pl-gwk-6), yard sprite 64x64. Opus richness pass (c13/opus3), built on c13/opus2.
-- opus3: hue-shifted pewter (blue-slate shade to warm pale top), cast-fur cheek ruffs jutting out at both sides of
-- the chamber (a wolf, not a cat), engraved fur lines up the ears with pale inner tufts and dark tips, a solder seam
-- round the chamber's shaded rim, two engraved bands at the mouthpiece end, a brow ridge over each eye, braided cord
-- with a lit twist. closer-look: the cork pea peeking up through the sound slot.
-- Wayfinder, rare, Lair of the Grey Wolf King (whimsy-wolf). "A whistle the king carried, and the wolves still
-- answer it."
-- Haiku weakness fixed: a grey cat-like head with a box on its chin did not read as a whistle at all. Now a real
-- pea whistle in old pewter: the round chamber (with the wolf's face, a pale muzzle and a black nose) and a long
-- flat mouthpiece out to the left with its sound slot, two pricked wolf ears on top, and the king's braided red cord
-- looped through a ring with a gold tassel. Shaped like no other pal in the set (whistle, not a head or a blob).
-- quirk: the wolves still answer it: blown notes leave the mouthpiece on the left, and three answering howl marks
-- come back from the right. closer-look: a tiny crown stamped on the mouthpiece. Rare: sparkles.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-6-yard", 64)

local PEW  = { "#262a40", "#424a62", "#666f88", "#929cb0", "#c0c6d0", "#ebeae6" }
local MUZ  = { "#8a8e9e", "#b8bcc8", "#e2e0dc" }
local EAR  = { "#2e2a36", "#4a4452" }
local CORD = { "#4e1620", "#86242e", "#c23e3a", "#ea7458" }
local GOLD = { "#6a3e1a", "#a8662a", "#e0a03a", "#f8d468", "#fff0b0" }

c:groundShadow(34, 57, 20, 2)
-- cord and tassel first (it hangs behind the ring)
local cord, cn, CT = O.tube({ { 51, 46 }, { 57, 48 }, { 58, 52 }, { 54, 54 } }, function() return 1.3 end)
local cI, cT = O.shadeN(c, cord, cn, CORD, { amb = .35, wrap = .5, rim = true, sep = CORD[1] })
O.tex(c, cI, cT, CORD, function(x, y, i) if (x + y) % 3 == 0 then return -1 end if (x + y) % 3 == 1 and i >= 3 then return 1 end end)
local tas = c:poly{ { 52, 53 }, { 56, 53 }, { 58, 59 }, { 50, 59 } }
local tI, tT = O.shade(c, tas, GOLD, { R = 2, amb = .35, wrap = .5, cuts = { .25, .45, .65, .82 }, sep = GOLD[1] })
O.tex(c, tI, tT, GOLD, function(x, y, i) if x % 2 == 0 and y > 55 then return -1 end end)
O.flat(c, c:rect(52, 53, 56, 54), CORD[3], "knot") O.dot(c, 53, 53, CORD[4])
-- ears (behind the chamber top)
for _, e in ipairs({ { 27, 1 }, { 43, -1 } }) do
  local bx, s = e[1], e[2]
  -- tall pricked wolf ears, dark inside with a pale fur tuft
  local m = c:poly{ { bx - 5, 25 }, { bx + 5, 25 }, { bx + s * 2, 5 } }
  local eI, eT = O.shade(c, m, PEW, { R = 2, amb = .3, wrap = .45, rim = true, sep = PEW[1] })
  -- engraved fur lines up the ear, darker tip
  O.tex(c, eI, eT, PEW, function(x, y, i)
    if y < 9 then return -1 end
    if (x * 2 + y) % 5 == 0 and i >= 3 then return -1 end
  end)
  O.flat(c, c:poly{ { bx - 2, 23 }, { bx + 2, 23 }, { bx + s * 2, 11 } }, EAR[2], "inner")
  O.dots(c, { { bx, 22 }, { bx - 1, 21 }, { bx + 1, 20 }, { bx, 19 }, { bx - 1, 23 } }, PEW[5])
  O.dots(c, { { bx + 1, 22 }, { bx, 20 } }, PEW[4])
end
-- chamber: round pewter body, with cast-fur cheek ruffs jutting out low on both sides
local ch = c:ellipse(36, 35, 14, 13)
ch:add(c:poly{ { 23, 33 }, { 18, 36 }, { 22, 38 }, { 19, 42 }, { 24, 42 } })
ch:add(c:poly{ { 49, 33 }, { 54, 36 }, { 50, 38 }, { 53, 42 }, { 48, 42 } })
local chI, chT = O.shade(c, ch, PEW, { sphere = { 31, 29, 19 }, amb = .28, wrap = .45, rim = true, bounce = "#7a8ab8", bmax = 3, sep = PEW[1] })
-- worn pewter: tiny scuffs, and a gloss arc on the upper left
O.tex(c, chI, chT, PEW, function(x, y, i) if O.H(x, y, 31) > .94 and i >= 3 then return -1 end end)
O.mark(c, { { 26, 30 }, { 26, 29 }, { 27, 27 }, { 28, 26 }, { 29, 25 } }, PEW[6])
-- solder seam round the shaded lower-right rim of the chamber
for d = -20, 130, 6 do
  for k = 0, 3 do
    local a = math.rad(d + k)
    local x, y = math.floor(36 + math.cos(a) * 12 + .5), math.floor(35 + math.sin(a) * 11 + .5)
    O.mark(c, { { x, y } }, PEW[2])
  end
end
-- fur lines on the cheek ruffs
O.mark(c, { { 20, 37 }, { 21, 40 }, { 22, 41 }, { 52, 37 }, { 51, 40 }, { 50, 41 } }, PEW[2])
-- mouthpiece out to the left (flat tube), sound slot on top by the chamber
local mp = c:poly{ { 8, 23 }, { 27, 21 }, { 27, 31 }, { 8, 29 } }
local mn = {}
mp:each(function(x, y) local sy = (y - 26) / 5 mn[K(x, y)] = { -.15, sy, math.sqrt(math.max(.05, 1 - sy * sy)) } end)
local mI, mT = O.shadeN(c, mp, mn, PEW, { amb = .3, wrap = .45, rim = true, sep = PEW[1] })
O.flat(c, c:rect(8, 24, 9, 28), PEW[1], "bore") O.dots(c, { { 9, 24 }, { 9, 28 } }, PEW[2])
-- two engraved bands near the mouthpiece end
for _, bx in ipairs({ 11, 12 }) do for y = 22, 30 do if mp:has(bx, y) then O.mark(c, { { bx, y } }, (bx == 11) and PEW[2] or PEW[5]) end end end
O.flat(c, c:rect(20, 22, 25, 23), PEW[1], "slot") O.dots(c, { { 20, 24 }, { 21, 24 }, { 22, 24 }, { 23, 24 }, { 24, 24 }, { 25, 24 } }, PEW[5])
-- closer-look: the cork pea peeking up through the sound slot
O.dots(c, { { 22, 22 }, { 23, 22 } }, "#c08048") O.dot(c, 22, 22, "#e8b070") O.dot(c, 23, 23, "#7a4428")
-- tiny stamped crown on the mouthpiece
O.dots(c, { { 13, 26 }, { 15, 25 }, { 17, 26 }, { 13, 27 }, { 14, 27 }, { 15, 27 }, { 16, 27 }, { 17, 27 } }, GOLD[3])
O.dots(c, { { 15, 25 } }, GOLD[5])
-- ring on the right for the cord
local ring = c:ellipse(49, 46, 3, 3)
ring:cut(c:ellipse(49, 46, 1, 1))
O.shade(c, ring, GOLD, { sphere = { 48, 45, 4 }, amb = .35, wrap = .5, cuts = { .25, .45, .65, .82 }, sep = GOLD[1] })

-- face: wolf muzzle and nose on the chamber
local muz = c:ellipse(36, 41, 6.5, 4)
O.shade(c, muz, MUZ, { R = 2, amb = .4, wrap = .5, cuts = { .35, .7 } })
O.dots(c, { { 35, 38 }, { 36, 38 }, { 37, 38 }, { 36, 39 } }, P.ink) O.dot(c, 35, 38, PEW[4])
O.dots(c, { { 36, 40 }, { 33, 41 }, { 34, 42 }, { 35, 42 }, { 36, 42 }, { 37, 42 }, { 38, 42 }, { 39, 41 } }, P.ink)
c:eyeLocked(28, 31)
c:eyeLocked(39, 31)
-- brow ridges (engraved)
O.dots(c, { { 27, 29 }, { 28, 28 }, { 29, 28 }, { 30, 28 }, { 41, 28 }, { 42, 28 }, { 43, 28 }, { 44, 29 } }, PEW[2])
c:cheek(27, 38) c:cheek(44, 38)

O.done(c, "pl-gwk-6-yard", function(c)
  -- blown notes out of the mouthpiece (left), answering howl marks coming back from the right
  for _, p in ipairs({ { 5, 19 }, { 4, 18 }, { 3, 17 }, { 4, 26 }, { 3, 26 }, { 2, 26 }, { 5, 33 }, { 4, 34 }, { 3, 35 } }) do c:put(p[1], p[2], P.ink) end
  for _, a in ipairs({ { 55, 14 }, { 58, 22 }, { 59, 30 } }) do
    -- small open arc facing the whistle: an answering "awoo"
    local x, y = a[1], a[2]
    for _, q in ipairs({ { 0, 0 }, { 0, 1 }, { 1, -1 }, { 1, 2 }, { 2, -2 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], "#a8d8ec") end
  end
  c:sparkle(12, 8)
  c:sparkle(55, 4)
end)
