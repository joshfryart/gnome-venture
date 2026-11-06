-- pumpkin-butter (D10 final, Sonnet high). A slim straight-sided glass jar, open, brimming with glossy orange pumpkin
-- butter: swirled top with a dusting of cinnamon, thick glass (bright rim, pale edge streaks, cool bounce), a cream paper
-- label with a little pumpkin, and a wooden spoon standing in the jar, its handle smeared with butter near the rim.
-- quirk: one fat drip of butter has overflowed the rim and is sliding down the front of the glass.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aD10_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("pumpkin-butter")

local GL   = { "#3f7f8e", "#5fa3ac", "#8ccbcc", "#b4e4de", "#dcf6f0", "#fbfffb" }
local OR   = { "#7a2c14", "#b04a18", "#dc6e1c", "#f59428", "#ffb94a", "#ffe08a" }
local WOOD = { "#3f2220", "#6b3d2a", "#945a38", "#bd8250", "#dba872", "#f2cf9c" }
local PAP  = { "#a89868", "#cabc88", "#e8dca8", "#f6ecc4", "#fff6d8", "#fffcec" }
local GRN  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

c:groundShadow(28, 58, 16, 2.2)

local CX = 27.5
-- jar silhouette
local jar = c:poly{ { 17, 24 }, { 38, 24 }, { 38, 27 }, { 40, 30 }, { 40, 53 }, { 37, 57 }, { 18, 57 }, { 15, 53 }, { 15, 30 }, { 17, 27 } }
jar:add(c:ellipse(CX, 24, 10.5, 2.6))
-- glass shell: cylinder normals, pale core => rim strong
local gtok = { r = { name = "glass" } }
local gn = {}
jar:each(function(x, y) local k = K(x, y)
  local t = max(-0.97, min(0.97, (x - CX) / 12.2))
  gn[k] = { A.norm(t, 0.0, sqrt(1 - t * t)) }
end)
A.shade(c, jar, gn, GL, { amb = 0.2, wrap = 0.35, tok = gtok, cuts = { 0.3, 0.5, 0.66, 0.8, 0.92 } })
-- contents (inset 2px, thicker glass at the base)
local inner = jar:shrink(2):cut(c:rect(0, 0, 63, 25))
inner:cut(c:rect(0, 54, 63, 63))
inner:add(c:ellipse(CX, 25, 8.2, 1.9))
local itok = { r = { name = "butter" } }
local inn = {}
inner:each(function(x, y) local k = K(x, y)
  local t = max(-0.97, min(0.97, (x - CX) / 10))
  inn[k] = { A.norm(t, -0.1, sqrt(1 - t * t)) }
end)
local ib = {}
inner:each(function(x, y) if y < 28 and abs(x - CX) < 8 then ib[K(x, y)] = 0 end end)
local ii = A.shade(c, inner, inn, OR, { amb = 0.2, wrap = 0.4, tok = itok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- reflected cool light on the lower-right inside
inner:each(function(x, y) if x >= 35 and y > 36 and y < 52 and ii[K(x, y)] and ii[K(x, y)] <= 3 then c:put(x, y, OR[min(6, ii[K(x, y)] + 1)], itok) end end)
-- smooth top surface of the butter: pale ellipse + swirl + cinnamon
local top = c:ellipse(CX, 25, 8.2, 1.9)
top:each(function(x, y) c:put(x, y, (y < 25) and OR[5] or OR[4], itok) end)
for _, p in ipairs{ { 22, 25 }, { 23, 24 }, { 25, 24 }, { 27, 25 }, { 29, 25 }, { 31, 24 } } do c:put(p[1], p[2], OR[6], itok) end
for _, p in ipairs{ { 24, 25 }, { 26, 26 }, { 28, 26 }, { 30, 26 }, { 33, 25 } } do c:put(p[1], p[2], OR[2], itok) end
for _, p in ipairs{ { 21, 26 }, { 25, 23 }, { 30, 24 }, { 33, 26 }, { 34, 24 } } do c:put(p[1], p[2], WOOD[2], itok) end
-- a few air bubbles in the butter
for _, p in ipairs{ { 21, 44 }, { 33, 49 }, { 22, 52 } } do c:put(p[1], p[2], OR[5], itok) c:put(p[1] + 1, p[2], OR[4], itok) end
-- glass: bright rim ring, edge streaks, thick base
for x = 17, 38 do c:put(x, 21, GL[5], gtok) end
local rimE = c:ellipse(CX, 24, 10.5, 2.6):edge()
rimE:each(function(x, y) c:put(x, y, (y <= 24 and x < CX + 3) and GL[6] or GL[4], gtok) end)
for y = 29, 52 do c:put(16, y, GL[6], gtok) end
for y = 30, 40 do c:put(17, y, GL[5], gtok) end
for y = 31, 50 do c:put(39, y, GL[2], gtok) end
for x = 18, 36 do c:put(x, 55, GL[4], gtok) c:put(x, 56, GL[3], gtok) end
c:put(16, 28, GL[6], gtok) c:put(17, 27, GL[6], gtok)
-- neck ring under the lip
for x = 17, 38 do c:put(x, 27, GL[3], gtok) end
-- label
local lab = c:rect(20, 36, 35, 49)
local ln = {}
lab:each(function(x, y) local t = max(-0.97, min(0.97, (x - CX) / 9)) ln[K(x, y)] = { A.norm(t * 1.0, 0, sqrt(1 - t * t)) } end)
local ltok = { r = { name = "label" } }
A.shade(c, lab, ln, PAP, { amb = 0.35, wrap = 0.4, tok = ltok, cuts = { 0.3, 0.5, 0.66, 0.8, 0.92 } })
for x = 20, 35 do c:put(x, 36, PAP[2], ltok) c:put(x, 49, PAP[1], ltok) end
for _, p in ipairs{ { 22, 38 }, { 31, 47 }, { 24, 47 }, { 33, 39 } } do c:put(p[1], p[2], PAP[2], ltok) end
-- pumpkin on the label
local pm = c:ellipse(27.5, 43, 5, 3.4)
local pn = X.pillow(pm, 3)
A.shade(c, pm, pn, OR, { amb = 0.1, wrap = 0.3, tok = { r = { name = "pk" } }, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
for _, x in ipairs{ 25, 28, 30 } do for y = 41, 45 do if pm:has(x, y) then c:put(x, y, OR[2], ltok) end end end
c:put(26, 41, OR[6], ltok) c:put(27, 42, OR[5], ltok)
c:put(28, 39, GRN[1], ltok) c:put(28, 40, GRN[2], ltok) c:put(29, 39, GRN[3], ltok)
c:put(30, 40, GRN[3], ltok) c:put(31, 40, GRN[2], ltok)

-- wooden spoon standing in the jar, leaning out to the upper right
local handle, hn, hT, hS = X.cyl(31, 26, 50, 9, function(t) return 1.7 - 0.45 * t end)
local htok = { r = { name = "spoon" } }
local hidx = A.shade(c, handle, hn, WOOD, { amb = 0.1, wrap = 0.28, tok = htok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
handle:each(function(x, y) local k = K(x, y)
  if abs(hS[k]) < 0.1 and X.hash(x, y, 3) > 0.4 then c:put(x, y, WOOD[max(1, hidx[k] - 2)], htok) end   -- grain
  if hS[k] > 0.55 and hT[k] > 0.1 then c:put(x, y, WOOD[min(6, hidx[k] + 0)], htok) end
end)
-- butter smeared on the handle near the jar
handle:each(function(x, y) local k = K(x, y) if hT[k] < 0.2 then
  local i = (hS[k] < -0.1) and 4 or ((hS[k] < 0.5) and 3 or 2)
  c:put(x, y, OR[i], htok) end end)
c:px(36, 23, OR[3]) c:px(35, 22, OR[4]) c:px(36, 22, OR[4])
-- spoon end rounded cap light
c:px(49, 9, WOOD[6]) c:px(50, 9, WOOD[5])
-- rim contact shadow where the spoon enters
for _, p in ipairs{ { 29, 26 }, { 30, 27 } } do c:put(p[1], p[2], OR[1], itok) end

-- quirk: overflow drip down the front of the glass (right side)
local dr = HP.mask()
dr:add(c:rect(36, 25, 37, 33)):add(c:ellipse(36.5, 35, 1.6, 1.8))
local dtok = { r = { name = "drip" } }
local dn = X.pillow(dr, 1.6)
A.shade(c, dr, dn, OR, { amb = 0.15, wrap = 0.3, tok = dtok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
for y = 26, 33 do c:put(36, y, OR[5], dtok) end
c:put(36, 35, OR[6], dtok)
c:put(37, 36, OR[1], dtok) c:put(36, 37, OR[1], dtok)
A.save(c, "pumpkin-butter")
