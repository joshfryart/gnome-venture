-- Hammock Hush (rr-hammock-hush), yard sprite 64x64. Opus third pass (art-2701-pals-all/c01/opus3), richness
-- pass over opus2: fur now hangs in downward strands (lit strands on the upper-left, dark strands in the shade),
-- green algae flecks in the coat, a twill weave and stripe seams on the hammock (no checker), tassels at its
-- ends, bark grain and a knot on the branch, hooked claws. A sloth moth hides in the fur (real sloths carry them).
-- Bloomcaller, common, Rainroot. "Hangs upside down for hours and calls it thinking."
-- A mossy sloth pal hanging UPSIDE DOWN under its own striped hammock: hooked toes over the cloth, body and arms
-- dangling, head at the bottom with the fur tuft falling down (gravity cue), a pink bloom caught in the tuft.
-- Sloth mask: cream face, dark eye stripes, mouth above the eyes (it is upside down), calm and content.
-- Fixes: the Haiku pal sat in the hammock the right way up; now it really hangs upside down and the
-- gravity cues (dangling arms, falling tuft, sagging cloth) make the flip read at 1x.
-- quirk: a little thought cloud with three dots (it is "thinking").
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("rr-hammock-hush-yard", 64)

local FUR  = { "#2c2a34", "#44483a", "#5f6a40", "#82904e", "#a9b264", "#d0d08c" }
local FACE = { "#8a6458", "#c09474", "#e4c29a", "#f6e2bc" }
local MASK = "#4a3026"
local WOOD = { "#3a2228", "#5e3a2e", "#86563a", "#ad7a4c", "#d0a068", "#ecc890" }
local GOLD = { "#5e3a1c", "#9a5d1e", "#d08a2a", "#f0b440", "#f8d670", "#fdf0b0" }
local CLOT = { "#5a1f3a", "#9a3048", "#d2505a", "#f08070" }
local LEAF = { "#1f4a3c", "#2f7a46", "#58a850", "#94d066" }
local CLD  = { "#8696b4", "#b2c0d6", "#d9e3ee", "#eef3f8" }

c:groundShadow(32, 59, 10, 1.5)

-- branch across the top
local br = c:line({ { 8, 8 }, { 20, 7 }, { 40, 7 }, { 56, 8 } }, 3)
local bI, bT = O.shade(c, br, WOOD, { R = 1, amb = .25, sep = WOOD[1], rim = true })
O.tex(c, bI, bT, WOOD, function(x, y, i)
  if y == 7 and (x // 5 + math.floor(H(x // 5, 1, 4) * 3)) % 3 == 0 and i >= 3 then return -1 end -- bark grain
  if y == 6 and H(x, y, 5) > .8 and i >= 3 then return 1 end
end)
O.dots(c, { { 44, 7 }, { 45, 7 } }, WOOD[2]) O.dot(c, 44, 6, WOOD[5]) -- knot
O.dots(c, { { 7, 6 }, { 6, 5 } }, LEAF[3]) O.dots(c, { { 8, 5 }, { 9, 5 } }, LEAF[4]) O.dots(c, { { 56, 6 }, { 57, 5 } }, LEAF[2]) O.dot(c, 55, 5, LEAF[4])

-- ropes
O.seg(c, 12, 10, 13, 14, GOLD[4]) O.seg(c, 13, 10, 14, 14, GOLD[2])
O.seg(c, 51, 10, 50, 14, GOLD[4]) O.seg(c, 52, 10, 51, 14, GOLD[2])

-- legs (behind the cloth) going up to the toes
for _, lx in ipairs({ 27, 37 }) do
  local lg = c:rect(lx - 2, 18, lx + 2, 27)
  O.shade(c, lg, FUR, { R = 2, amb = .2, sep = FUR[1] })
end

-- hammock cloth: a sagging striped band
local cloth = HP.mask()
for x = 13, 51 do
  local u = (x + .5 - 32) / 19.5
  local t = 13 + 7 * (1 - u * u)
  local th = 3 + 2 * (1 - u * u)
  for y = math.floor(t), math.floor(t + th) do cloth:set(x, y) end
end
local cn = X.pillow(cloth, 2)
local cv = X.light(cn, { amb = .3, wrap = .4 })
local ctok = { r = { name = "cloth" } }
cloth:each(function(x, y)
  local v = cv[K(x, y)] or .5
  local band = (x // 4) % 3
  local R = band == 0 and GOLD or (band == 1 and CLOT or { "#173f4a", "#1f6a6a", "#2f9a8a", "#5cc8a8" })
  local i = v < .35 and 2 or (v < .55 and 2 or (v < .8 and 3 or 4))
  if band == 0 then i = math.min(#R, i + 1) end
  if (x - y) % 3 == 0 and i > 1 then i = i - 1 end -- twill weave, diagonal
  if x % 4 == 0 then i = math.max(1, i - 1) end      -- stripe seam
  c:put(x, y, R[i], ctok)
end)
-- tassels where the cloth meets the ropes
for _, tx in ipairs({ 13, 50 }) do
  O.seg(c, tx, 19, tx, 21, GOLD[3]) O.seg(c, tx + 1, 19, tx + 1, 22, GOLD[4]) O.dot(c, tx + 1, 22, GOLD[2])
end


-- toes hooked over the top edge of the cloth (it is gripping it)
for _, tx in ipairs({ 25, 35 }) do
  O.dots(c, { { tx, 17 }, { tx + 1, 16 }, { tx + 2, 16 }, { tx + 3, 16 }, { tx + 4, 17 } }, FUR[4])
  O.dots(c, { { tx + 1, 15 }, { tx + 3, 15 } }, FUR[5])
  O.dots(c, { { tx + 1, 18 }, { tx + 3, 18 } }, "#3a2a2a") O.dots(c, { { tx + 1, 19 }, { tx + 3, 19 } }, "#6a5a50") -- claws over the edge
end

-- body (hanging), fur strands run downward
local body = c:ellipse(32, 31, 9, 8)
local yI, yT = O.shade(c, body, FUR, { R = 4, amb = .18, wrap = .35, sep = FUR[1], rim = true, bounce = "#4f7a8a", bmax = 2 })
-- hanging fur strands: each column gets a 2 px strand at a hashed offset; lit ones on the lit side
local function strands(I, T, skip)
  O.tex(c, I, T, FUR, function(x, y, i)
    if skip and skip(x, y) then return end
    local h = H(x, 0, 21)
    local ph = (y + math.floor(h * 5)) % 5
    if ph <= 1 and h > .35 then
      if i >= 4 then return 1 end
      if i >= 2 then return -1 end
    end
    if ph == 2 and h > .35 and i >= 3 and i <= 4 then return -1 end
  end)
end
strands(yI, yT)
O.dots(c, { { 26, 29 }, { 27, 30 }, { 38, 26 } }, "#4a8a5a") O.dot(c, 27, 29, "#7ab86a") -- algae flecks
-- sloth moth tucked in the fur on the shade side
O.dots(c, { { 37, 33 }, { 39, 33 } }, "#c8b088") O.dot(c, 38, 33, "#6a5040") O.dots(c, { { 37, 34 }, { 39, 34 } }, "#9a8060")
O.dot(c, 37, 33, "#e8d8b0")


-- arms dangling down past the head, hooked claws at the bottom
for _, s in ipairs({ { 22, -1 }, { 42, 1 } }) do
  local arm = c:line({ { s[1] + s[2] * 1, 32 }, { s[1] + s[2] * 2, 40 }, { s[1] + s[2] * 2, 49 } }, 3)
  local aI, aT = O.shade(c, arm, FUR, { R = 1, amb = .2, sep = FUR[1], rim = true })
  strands(aI, aT)
  local cx = s[1] + s[2] * 2
  O.dots(c, { { cx - 1, 51 }, { cx, 52 }, { cx + 1, 51 } }, "#3a2a2a")
end

-- head at the bottom (upside down)
local head = c:ellipse(32, 44, 10.5, 9)
local hI, hT = O.shade(c, head, FUR, { R = 4, amb = .2, wrap = .35, sep = FUR[1], rim = true, bounce = "#4f7a8a", bmax = 2 })
strands(hI, hT)

-- falling tuft at the bottom of the head (its crown points at the ground)
local tuft = c:poly{ { 26, 51 }, { 29, 57 }, { 31, 53 }, { 33, 57 }, { 35, 53 }, { 38, 56 }, { 39, 51 } }
O.shade(c, tuft, FUR, { R = 1, amb = .2 })
-- pink bloom caught in the tuft
O.dots(c, { { 36, 53 }, { 38, 53 }, { 37, 52 }, { 37, 54 } }, "#ef7a8a") O.dot(c, 37, 53, "#f8d670")
-- cream face mask
local fm = c:ellipse(32, 42.5, 8.5, 6.5)
O.shade(c, fm, FACE, { R = 2, amb = .35, wrap = .4, cuts = { .3, .55, .8 } })
-- dark sloth eye patches with a stripe running outward and UP toward the ears (it is upside down)
for _, s in ipairs({ { 26.5, -1 }, { 37.5, 1 } }) do
  local pm = c:ellipse(s[1], 45, 3.5, 3)
  pm:add(c:line({ { s[1] + s[2] * 2, 43 }, { s[1] + s[2] * 5, 40 }, { s[1] + s[2] * 6, 38 } }, 2))
  pm:each(function(x, y) if fm:has(x, y) or head:has(x, y) then O.dot(c, x, y, MASK) end end)
end
c:eyeLocked(24, 43)
c:eyeLocked(35, 43)
-- nose + calm mouth ABOVE the eyes (it is upside down)
O.dots(c, { { 31, 42 }, { 32, 42 } }, MASK) O.dots(c, { { 31, 41 }, { 32, 41 } }, "#6a4a40")
O.dots(c, { { 29, 38 }, { 30, 39 }, { 31, 39 }, { 32, 39 }, { 33, 39 }, { 34, 38 } }, P.ink)
O.dots(c, { { 22, 40 }, { 23, 40 } }, P.petal.base) O.dots(c, { { 40, 40 }, { 41, 40 } }, P.petal.base)

-- quirk: thought cloud with three dots
local cl = O.unionCircles{ { 50, 33, 3.5, 3 }, { 54, 32, 3, 3 }, { 53, 36, 3.5, 2.5 }, { 48, 36, 2.5, 2 } }
O.shade(c, cl, CLD, { R = 2, amb = .4, cuts = { .35, .6, .85 }, rim = true })
O.dots(c, { { 48, 34 }, { 51, 34 }, { 54, 34 } }, "#5d6b8c")
O.flat(c, c:rect(46, 40, 47, 41), CLD[3], "puff") O.dot(c, 46, 40, CLD[4])
O.flat(c, c:rect(44, 43, 44, 43), CLD[3], "puff2")

O.done(c, "rr-hammock-hush-yard")
