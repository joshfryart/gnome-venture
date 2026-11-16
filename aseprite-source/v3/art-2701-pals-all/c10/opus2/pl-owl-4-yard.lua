-- Owlet Peep (pl-owl-4), yard sprite 64x64. Opus second pass (c10/opus2), built on c10/haiku.
-- Thornblade, uncommon. "A sleepy owlet in the den who peeps when it is bored."
-- A great white owl chick: a round ball of cool grey down with a scruffy fluff edge and no ear tufts (so it
-- cannot be confused with the tawny gatepost owl), a pale heart-shaped face, big locked eyes in grey sockets,
-- stubby wings and gold toes, sitting on a pad of den straw. One wing is flopped out in a bored stretch.
-- Haiku pass fixed: the owlet read as a brown cat (pointed ears, painted lids over the eyes, flat beak).
-- quirk: the peep. Beak wide open (pink inside) with three ink peep ticks and a tiny cream note off to the right.
-- closer look: one downy cowlick curl sticking up off its crown.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local BNC = "#7a8fb0"
local c = O.canvas("pl-owl-4-yard", 64)

local DOWN  = { "#3a3348", "#5a546e", "#7f7a95", "#a6a2b9", "#cac7d8", "#e9e7f0" }
local FACE  = { "#948ca4", "#c4bfd0", "#e2dee6", "#f4f1ef" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local STRAW = { "#6a4a2a", "#9a7238", "#c89c4a", "#e8c870", "#f6e2a0" }

c:groundShadow(31, 56, 17, 2.5)
-- den straw pad: a low heap of crossing stalks
local pad = c:ellipse(31, 54, 16, 3)
local sb = {}
pad:each(function(x, y) if (x * 2 + y * 3) % 5 == 0 then sb[K(x, y)] = -1 elseif (x - y * 2) % 7 == 0 then sb[K(x, y)] = 1 end end)
O.shade(c, pad, STRAW, { R = 1, bias = sb, amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 13, 52 }, { 12, 51 }, { 48, 53 }, { 49, 52 }, { 50, 51 } }, STRAW[3]) -- loose stalks poking out

-- body: one round mass, scruffy down along the edge
local body = c:ellipse(31, 36, 15, 16)
for a = 0, 330, 30 do
  local r = math.rad(a)
  body:add(c:ellipse(31 + math.cos(r) * 15, 36 + math.sin(r) * 16, 2, 2))
end
body:cut(c:rect(0, 53, 63, 63))
-- cowlick on the crown
local curl = O.tube({ { 31, 22 }, { 30, 17 }, { 33, 13 }, { 36, 15 } }, function(t) return 1.7 - t * 0.9 end)
body:add(curl)
local bI, bT = O.shade(c, body, DOWN, { sphere = { 26, 29, 21 }, amb = .2, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
-- down texture: soft wisps (1 tone darker short ticks) all over, lighter flecks on the lit side
O.tex(c, bI, bT, DOWN, function(x, y, i)
  local h = H(x, y, 41)
  if h > .86 and i >= 3 then return -1 end
  if h < .06 and i <= 4 then return 1 end
end)
O.mark(c, { { 31, 16 }, { 31, 17 } }, DOWN[6])

-- belly: paler, with faint grey chevrons
local belly = c:ellipse(31, 44, 9, 8)
belly:cut(c:rect(0, 53, 63, 63))
local blb = {}
belly:each(function(x, y)
  local r = y - 40
  if r >= 0 and r % 4 == 0 and (x + (r // 4) * 2) % 4 ~= 0 and (x + (r // 4) * 2) % 4 ~= 2 then blb[K(x, y)] = -2 end
  if r >= 0 and r % 4 == 1 and (x + (r // 4) * 2) % 4 == 2 then blb[K(x, y)] = -2 end
end)
O.shade(c, belly, DOWN, { R = 3, bias = blb, amb = .55, wrap = .6 })

-- wings: right one folded, left one flopped out in a bored stretch
local wr = c:poly{ { 42, 34 }, { 46, 36 }, { 47, 44 }, { 44, 50 }, { 41, 46 } }
local wrb = {} wr:each(function(x, y) wrb[K(x, y)] = -1 end)
local rI, rT = O.shade(c, wr, DOWN, { R = 2, bias = wrb, amb = .25, sep = DOWN[2], bounce = BNC, bmax = 2 })
O.tex(c, rI, rT, DOWN, function(x, y, i) if y > 44 and x % 2 == 0 then return -1 end end)
local wl = c:poly{ { 18, 37 }, { 13, 37 }, { 7, 41 }, { 6, 45 }, { 9, 45 }, { 11, 47 }, { 14, 46 }, { 20, 44 } }
local wlb = {} wl:each(function(x, y) wlb[K(x, y)] = 0 end)
local lI, lT = O.shade(c, wl, DOWN, { R = 2, amb = .25, sep = DOWN[2], rim = true })
O.tex(c, lI, lT, DOWN, function(x, y, i) if x < 13 and (x + y) % 3 == 0 then return -1 end end) -- downy fingers
O.dots(c, { { 9, 44 }, { 12, 45 } }, DOWN[2])

-- heart-shaped facial disc
local disc = O.unionCircles{ { 25.5, 30, 6, 5.5 }, { 37.5, 30, 6, 5.5 } }
disc:add(c:poly{ { 20, 32 }, { 43, 32 }, { 31, 40 } })
O.shade(c, disc, FACE, { R = 3, amb = .4, wrap = .5, cuts = { .3, .55, .8 }, sep = DOWN[2] })
-- grey sockets so the cream eyes read on the pale face
for _, ex in ipairs({ 22, 35 }) do
  local ring = c:ellipse(ex + 2, 29, 3.5, 3.5)
  ring:each(function(x, y) O.mark(c, { { x, y } }, FACE[1]) end)
  c:eyeLocked(ex, 27)
end
O.mark(c, { { 30, 26 }, { 31, 26 }, { 32, 26 } }, FACE[3]) -- disc ridge between the eyes

-- beak wide open mid-peep: gold upper, pink mouth, gold lower
O.dots(c, { { 30, 32 }, { 31, 32 }, { 32, 32 } }, GOLD[3]) O.dot(c, 30, 32, GOLD[4])
O.dots(c, { { 30, 33 }, { 32, 33 } }, GOLD[2]) O.dot(c, 31, 33, "#c94f84")
O.dots(c, { { 30, 34 }, { 32, 34 } }, GOLD[2]) O.dot(c, 31, 34, "#7d2c5e")
O.dots(c, { { 30, 35 }, { 31, 35 }, { 32, 35 } }, GOLD[1])
c:cheek(21, 34) c:cheek(40, 34)

-- gold toes on the straw
for _, tx in ipairs({ 25, 34 }) do
  O.dots(c, { { tx, 52 }, { tx + 1, 52 }, { tx + 2, 52 }, { tx + 3, 52 } }, GOLD[2])
  O.dots(c, { { tx, 52 }, { tx + 2, 52 } }, GOLD[3])
  O.dots(c, { { tx + 1, 53 }, { tx + 3, 53 } }, GOLD[1])
end

O.shift(c, 0, 1)
O.done(c, "pl-owl-4-yard", function(c)
  -- peep ticks off the beak (not outlined)
  for _, p in ipairs({ { 39, 30 }, { 40, 29 }, { 41, 28 }, { 41, 33 }, { 42, 33 }, { 43, 33 }, { 40, 36 }, { 41, 37 }, { 42, 38 } }) do
    c:put(p[1] + 11, p[2], P.ink)
  end
  -- a tiny cream note floating up from the peep
  local nx, ny = -4, -4
  for _, p in ipairs({ { 53, 24 }, { 54, 24 }, { 53, 25 }, { 54, 25 }, { 55, 20 }, { 55, 21 }, { 55, 22 }, { 55, 23 }, { 55, 24 }, { 56, 20 }, { 57, 21 } }) do c:put(p[1] + nx, p[2] + ny, P.cream) end
  for _, p in ipairs({ { 52, 24 }, { 52, 25 }, { 53, 26 }, { 54, 26 }, { 56, 22 }, { 56, 23 }, { 56, 24 }, { 54, 20 }, { 54, 19 }, { 55, 19 }, { 56, 19 }, { 57, 20 }, { 58, 21 }, { 57, 22 } }) do c:put(p[1] + nx, p[2] + ny, P.ink) end
end)
