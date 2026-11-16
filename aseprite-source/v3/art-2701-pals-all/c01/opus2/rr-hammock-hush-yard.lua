-- Hammock Hush (rr-hammock-hush), yard sprite 64x64. Opus second pass (art-2701-pals-all/c01/opus2), from the Haiku idea.
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
O.tex(c, bI, bT, WOOD, function(x, y, i) if (x * 7 + y) % 9 == 0 and i >= 2 then return -1 end end)
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
  local i = v < .35 and 1 or (v < .55 and 2 or (v < .8 and 3 or 4))
  if band == 0 then i = i + 1 end
  if (x + y) % 2 == 0 and i > 1 then i = i - 1 end -- weave
  c:put(x, y, R[i], ctok)
end)

-- toes hooked over the top edge of the cloth (it is gripping it)
for _, tx in ipairs({ 25, 35 }) do
  O.dots(c, { { tx, 17 }, { tx + 1, 16 }, { tx + 2, 16 }, { tx + 3, 16 }, { tx + 4, 17 } }, FUR[4])
  O.dots(c, { { tx + 1, 15 }, { tx + 3, 15 } }, FUR[5])
  O.dots(c, { { tx + 1, 18 }, { tx + 3, 18 } }, "#3a2a2a") O.dots(c, { { tx + 1, 19 }, { tx + 3, 19 } }, "#6a5a50") -- claws over the edge
end

-- body (hanging), fur strands run downward
local body = c:ellipse(32, 31, 9, 8)
local yI, yT = O.shade(c, body, FUR, { R = 4, amb = .18, wrap = .35, sep = FUR[1], rim = true, bounce = "#4f7a8a", bmax = 2 })
O.tex(c, yI, yT, FUR, function(x, y, i)
  local h = H(x, 0, 21)
  if (y + math.floor(h * 4)) % 4 == 0 and i >= 3 and h > .4 then return -1 end
  if H(x, y, 22) > .9 and i <= 5 then return 1 end
end)

-- arms dangling down past the head, hooked claws at the bottom
for _, s in ipairs({ { 22, -1 }, { 42, 1 } }) do
  local arm = c:line({ { s[1] + s[2] * 1, 32 }, { s[1] + s[2] * 2, 40 }, { s[1] + s[2] * 2, 49 } }, 3)
  local aI, aT = O.shade(c, arm, FUR, { R = 1, amb = .2, sep = FUR[1], rim = true })
  local cx = s[1] + s[2] * 2
  O.dots(c, { { cx - 1, 51 }, { cx, 52 }, { cx + 1, 51 } }, "#3a2a2a")
end

-- head at the bottom (upside down)
local head = c:ellipse(32, 44, 10.5, 9)
local hI, hT = O.shade(c, head, FUR, { R = 4, amb = .2, wrap = .35, sep = FUR[1], rim = true, bounce = "#4f7a8a", bmax = 2 })
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
