-- Owlet Peep (pl-owl-4), perch sprite 36x36. Opus richness pass (c10/opus3), built on c10/opus2, hand-built at this size.
-- Richness pass: down flecks, lit straw stalks, a darker disc rim, pale wing-stub tips, a bit of eggshell in the straw.
-- Great white owl chick: round grey down ball, scruffy edge, cowlick curl, pale heart face with pill eyes in
-- grey sockets, one wing flopped out, gold toes on a straw pad.
-- quirk: the peep: open beak and three ink peep ticks.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local BNC = "#7a8fb0"
local c = O.canvas("pl-owl-4-perch", 36)

local DOWN  = { "#3a3348", "#5a546e", "#7f7a95", "#a6a2b9", "#cac7d8", "#e9e7f0" }
local FACE  = { "#948ca4", "#c4bfd0", "#e2dee6", "#f4f1ef" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local STRAW = { "#6a4a2a", "#9a7238", "#c89c4a", "#e8c870", "#f6e2a0" }

c:groundShadow(16, 32, 10, 1.5)
local pad = c:ellipse(16, 31, 10, 1.5)
local sb = {} pad:each(function(x, y) if (x * 2 + y) % 4 == 0 then sb[K(x, y)] = -1 end end)
O.shade(c, pad, STRAW, { R = 1, bias = sb, amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 } })
O.mark(c, { { 8, 30 }, { 9, 30 }, { 10, 30 }, { 21, 31 }, { 22, 31 }, { 23, 30 } }, STRAW[5])
local shell = c:poly{ { 24, 31 }, { 24, 28 }, { 25, 29 }, { 26, 28 }, { 27, 29 }, { 27, 31 } }
O.shade(c, shell, { "#a49a94", "#d6ccc0", "#efe6d8", "#f8f2e6" }, { R = 1, amb = .4, wrap = .5, cuts = { .3, .55, .8 }, nopop = true })

local body = c:ellipse(16, 20, 9, 10)
for a = 0, 315, 45 do
  local r = math.rad(a + 20)
  body:add(c:ellipse(16 + math.cos(r) * 9, 20 + math.sin(r) * 10, 1.2, 1.2))
end
body:cut(c:rect(0, 30, 35, 35))
body:add(O.tube({ { 16, 11 }, { 15, 8 }, { 17, 6 }, { 19, 7 } }, function(t) return 1.2 - t * .6 end))
local bI, bT = O.shade(c, body, DOWN, { sphere = { 13, 16, 13 }, amb = .2, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, DOWN, function(x, y, i) local h = O.H(x, y, 41) if h > .9 and i >= 3 then return -1 end end)
local belly = c:ellipse(16, 25, 5, 4)
belly:cut(c:rect(0, 30, 35, 35))
O.shade(c, belly, DOWN, { R = 2, amb = .55, wrap = .6 })
O.dots(c, { { 14, 25 }, { 18, 25 }, { 16, 27 } }, DOWN[4])
-- flopped wing
local wl = c:poly{ { 9, 21 }, { 5, 22 }, { 3, 25 }, { 6, 26 }, { 10, 25 } }
O.shade(c, wl, DOWN, { R = 1, amb = .25, sep = DOWN[2], rim = true })
O.dots(c, { { 4, 25 }, { 6, 25 } }, DOWN[2]) O.dots(c, { { 3, 25 }, { 5, 25 } }, DOWN[5])

local disc = O.unionCircles{ { 12.5, 17, 3.5, 3.5 }, { 19.5, 17, 3.5, 3.5 } }
disc:add(c:poly{ { 9, 18 }, { 23, 18 }, { 16, 23 } })
O.shade(c, disc, FACE, { R = 2, amb = .4, wrap = .5, cuts = { .3, .55, .8 }, sep = DOWN[1] })
for _, ex in ipairs({ 11, 19 }) do
  O.mark(c, { { ex - 1, 16 }, { ex - 1, 17 }, { ex - 1, 18 }, { ex + 2, 16 }, { ex + 2, 17 }, { ex + 2, 18 }, { ex, 19 }, { ex + 1, 19 } }, FACE[1])
  c:eyeSmall(ex, 16)
end
O.dot(c, 15, 19, GOLD[4]) O.dot(c, 16, 19, GOLD[3])
O.dot(c, 15, 20, "#c94f84") O.dot(c, 16, 20, GOLD[2])
O.dot(c, 15, 21, GOLD[1]) O.dot(c, 16, 21, GOLD[1])
O.dot(c, 9, 20, "#f5809f") O.dot(c, 23, 20, "#f5809f")
O.dots(c, { { 12, 30 }, { 13, 30 }, { 14, 30 }, { 18, 30 }, { 19, 30 }, { 20, 30 } }, GOLD[2]) O.dots(c, { { 12, 30 }, { 18, 30 } }, GOLD[3])

O.shift(c, 1, -1)
O.done(c, "pl-owl-4-perch", function(c)
  for _, p in ipairs({ { 30, 14 }, { 31, 13 }, { 31, 18 }, { 32, 18 }, { 33, 18 }, { 30, 22 }, { 31, 23 } }) do c:put(p[1], p[2], P.ink) end
end)
