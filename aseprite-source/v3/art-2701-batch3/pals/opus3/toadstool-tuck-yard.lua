-- Toadstool Tuck (mm-toadstool-tuck), yard sprite 64x64. Opus richness pass (art-2701-batch3/pals/opus3),
-- built on opus2. Bloomcaller, common, Mistmoor. "Tucks under the fairy ring and counts to ninety-nine twice."
-- A red fly-agaric: domed cap with a fine mottle, raised cream warts that each cast a tiny shadow, a rim
-- light on the upper-left and a darker rolled brim; a pink gill skirt with gills fanning in to the stem;
-- a plump cream stem with fibre streaks and the fly-agaric's frilly ring (annulus) worn like a skirt.
-- Fix vs opus2: the cap sits 2 px higher and the cap shadow band is narrower, so the locked eyes get two
-- clear rows of lit stem above them instead of tucking right under the gills.
-- quirk: a ring of tiny tan fairy-ring mushrooms; look closer and one of them is a red baby Tuck, eyes open.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("toadstool-tuck-yard", 64)

local CAP  = { "#561634", "#86213a", "#b9303c", "#e04c3e", "#f47a50", "#ffaf7a" }
local STEM = { "#87697a", "#ae9390", "#cdb39f", "#e2cdb3", "#efdfc4", "#f9efd9" }
local GILL = { "#7e4c62", "#a8707a", "#cc9590", "#e4b8a6", "#f3d4bc" }
local WART = { "#b39a92", "#d6c0aa", "#ecdcc2", "#f8eed6", "#fff4d6" }
local TAN  = { "#5e3a33", "#8c5c42", "#b98656", "#dcae78", "#f2d29e" }
local BNC  = "#b7a6b6" -- cool bounce on the stem's shade side

c:groundShadow(32, 58, 17, 3)

-- quirk, back row of the fairy ring (behind the stem)
local function mini(x, y, flip)
  O.shade(c, c:rect(x + 2, y + 3, x + 3, y + 4), STEM, { R = 1, amb = .45 })
  local cp = c:poly{ { x, y + 2 }, { x + 1, y }, { x + 4, y }, { x + 5, y + 2 } }
  O.shade(c, cp, TAN, { R = 1, amb = .35, cuts = { .25, .45, .65, .85 } })
  O.dots(c, { { x + 1, y + 2 }, { x + 2, y + 2 }, { x + 3, y + 2 }, { x + 4, y + 2 } }, TAN[2])
  O.dot(c, flip and x + 3 or x + 2, y + 1, TAN[5])
  O.dot(c, flip and x + 2 or x + 3, y + 3, STEM[2]) -- cap shadow on the little stem
end
mini(7, 48) mini(51, 47, true)

-- stem: plump barrel, a touch wider at the foot
local stem = c:ellipse(32, 44, 11, 12)
stem:add(c:ellipse(32, 52, 12, 4))
stem:cut(c:rect(0, 57, 63, 63))
local si, st = O.shade(c, stem, STEM, { R = 6, amb = .3, wrap = .4, bounce = BNC, bmax = 3 })
-- fibre streaks: broken vertical hairlines, denser toward the shade side
O.tex(c, si, st, STEM, function(x, y, i)
  if y > 43 and (x == 24 or x == 40) and H(x, y, 3) > .45 then return -1 end
end)

-- arm down on the left, arm up on the right counting
local armL = c:ellipse(20.5, 47, 2.5, 3)
O.shade(c, armL, STEM, { R = 1, amb = .35, sep = STEM[2], rim = true })
local armR = O.tube({ { 42, 48 }, { 46, 46 }, { 47, 43 }, { 47, 40 } }, function(t) return 1.6 end)
O.shade(c, armR, STEM, { R = 1, amb = .4, sep = STEM[2] })
-- three fingers held up (counting)
O.dots(c, { { 46, 38 }, { 46, 37 }, { 48, 38 }, { 48, 37 }, { 47, 38 }, { 47, 37 } }, STEM[5])
O.dots(c, { { 46, 39 }, { 47, 39 }, { 48, 39 } }, STEM[4])
O.dots(c, { { 47, 37 } }, STEM[3]) -- finger split

-- annulus: the frilly fly-agaric ring round the waist, scalloped hem, lit top edge
for x = 20, 44 do
  local edge = (x == 20 or x == 44)
  local lit = x < 33
  O.dot(c, x, 49, edge and WART[2] or (lit and WART[5] or WART[4]))
  O.dot(c, x, 50, lit and WART[4] or WART[3])
  if not edge and x % 3 ~= 0 then O.dot(c, x, 51, lit and WART[3] or WART[2]) end
  if not edge and x % 3 == 0 then O.mark(c, { { x, 51 } }, STEM[2]) end
  if not edge and x % 3 ~= 0 then O.mark(c, { { x, 52 } }, STEM[2]) end
end
O.dots(c, { { 21, 48 }, { 43, 48 } }, STEM[2])

-- gill skirt under the brim: gills fan in toward the stem
local gill = c:ellipse(32, 29, 24, 3.5)
gill:cut(c:rect(0, 0, 63, 27))
local gi, gt = O.shade(c, gill, GILL, { R = 2, amb = .45, cuts = { .25, .45, .65, .82 } })
O.tex(c, gi, gt, GILL, function(x, y, i)
  local u = 32 + (x - 32) / (1 - (y - 28) * .09)
  if math.floor(u + .5) % 2 == 0 then return -1 end
end)

-- cap dome
local cap = c:ellipse(32, 25, 27, 17)
cap:cut(c:rect(0, 29, 63, 63))
cap:cut(c:rect(0, 28, 6, 28)) cap:cut(c:rect(57, 28, 63, 28))
local cb = {}
cap:each(function(x, y) if y >= 27 then cb[K(x, y)] = -1 end end) -- darker rolled brim
local ci, ct = O.shade(c, cap, CAP, { sphere = { 26, 20, 28 }, bias = cb, amb = .16, wrap = .3, rim = true })
-- fine mottle in the cap skin (tiny darker freckles, a few lighter on the lit side)
O.tex(c, ci, ct, CAP, function(x, y, i)
  local h = H(x, y, 11)
  if h > .965 and i >= 3 and i <= 5 then return -1 end
end)
-- brim lip highlight line (rolled edge catching the light)
for x = 10, 30 do if c:get(x, 26) then O.mark(c, { { x, 26 } }, CAP[4]) end end
for x = 36, 52 do if c:get(x, 27) and x % 4 ~= 0 then O.mark(c, { { x, 27 } }, CAP[2]) end end

-- raised warts (foreshortened toward the rim), each with a cast shadow lower-right
local warts = { { 22, 12, 2.5, 2 }, { 35, 10, 3, 2 }, { 45, 16, 2.5, 2 }, { 14, 20, 2, 1.5 },
                { 29, 19, 3, 2 }, { 51, 23, 1.5, 1.5 }, { 40, 23, 2, 1.5 }, { 20, 25, 1.5, 1 }, { 9, 25, 1, 1 } }
for _, w in ipairs(warts) do
  local m = c:ellipse(w[1], w[2], w[3], w[4])
  m:shift(1, 1):each(function(x, y) if ct and c.own[y * 64 + x] == ct and not m:has(x, y) then c.pix[y * 64 + x] = CAP[2] end end)
  O.shade(c, m, WART, { sphere = { w[1] - 1, w[2] - 1, w[3] + 1 }, amb = .35, cuts = { .25, .45, .65, .85 } })
end
O.dots(c, { { 10, 16 }, { 56, 19 }, { 29, 7 }, { 48, 10 } }, WART[2]) -- small flecks

-- face under the cap: a narrow cap shadow band, then two lit rows, then the eyes
stem:each(function(x, y)
  if y <= 32 then O.mark(c, { { x, y } }, STEM[2]) elseif y == 33 then O.mark(c, { { x, y } }, STEM[3]) end
end)
for _, ex in ipairs({ 24, 35 }) do
  local e = 36
  O.dots(c, { { ex - 1, e + 2 }, { ex - 1, e + 3 }, { ex, e + 4 }, { ex + 5, e + 2 }, { ex + 5, e + 3 }, { ex + 4, e + 4 },
              { ex + 1, e + 5 }, { ex + 2, e + 5 }, { ex + 3, e + 5 } }, STEM[3])
  O.dots(c, { { ex, e - 1 }, { ex + 1, e - 1 }, { ex + 2, e - 1 }, { ex + 3, e - 1 } }, STEM[3]) -- brow
  c:eyeLocked(ex, e)
end
c:cheek(21, 42) c:cheek(41, 42)
-- nose: little warm button, lit tip, dark underside
O.dots(c, { { 31, 41 }, { 32, 41 } }, "#e0b09a")
O.dot(c, 31, 41, "#f6d5bd")
O.dots(c, { { 31, 42 }, { 32, 42 } }, "#a8746a")
-- counting mouth: small open "o"
O.dots(c, { { 30, 44 }, { 33, 44 } }, "#a8483a")
O.dots(c, { { 31, 44 }, { 32, 44 }, { 31, 45 }, { 32, 45 } }, "#6e2c2a")
O.dot(c, 32, 45, "#c94f60")

-- quirk, front row of the fairy ring
mini(3, 54) mini(13, 56) mini(55, 53, true)
-- the baby Tuck in the ring: red cap with one wart, two ink dot eyes on a fat little stem
do
  local x, y = 44, 54
  O.shade(c, c:rect(x + 1, y + 3, x + 5, y + 6), STEM, { R = 1, amb = .4 })
  O.dots(c, { { x + 1, y + 3 }, { x + 2, y + 3 }, { x + 3, y + 3 }, { x + 4, y + 3 }, { x + 5, y + 3 } }, STEM[2])
  local cp = c:poly{ { x, y + 2 }, { x + 1, y }, { x + 5, y }, { x + 6, y + 2 } }
  O.shade(c, cp, CAP, { R = 1, amb = .3 })
  O.dot(c, x + 2, y, CAP[6]) O.dot(c, x + 4, y + 1, WART[5])
  O.dots(c, { { x + 2, y + 4 }, { x + 4, y + 4 } }, P.ink)
end

O.done(c, "toadstool-tuck-yard")
