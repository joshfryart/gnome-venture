-- Seedling Plod (mt-seedling-plod), yard sprite 64x64. Opus second pass (art-2701-pals-all/c07/opus2), from the Haiku pass.
-- Monsoontangle, common, wayfinder. "Plods through the paddy one seedling at a time and sings to each."
-- A squat pear-shaped moss body with grassy blade flecks and a pale belly, three long rice blades sprouting from
-- its crown, stubby mud-brown legs sunk in a strip of paddy water, and one rice seedling (mud clump + blades)
-- held out in its mitten.
-- Haiku fixes: the gold sprout became true rice blades (long, thin, green), the body is a pear with texture and a
-- belly instead of a flat ball, the seedling in hand says "one at a time", clog feet became wading legs.
-- quirk: it sings to the seedling (round open mouth turned to it, one sea note drifting up).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mt-seedling-plod-yard", 64)

local MOSS = { "#24544a", "#2f7350", "#3f9150", "#5aaa52", "#86c862", "#bfe282" }
local BEL  = { "#7aa85a", "#a2c878", "#c8e09a", "#e6f0bc" }
local RICE = { "#2f6a3a", "#4a8c3c", "#74b04a", "#a8d468", "#d4ec98" }
local MUD  = { "#3e2a26", "#5e3e30", "#86583e", "#a87a52" }
local PAD  = { "#3a5a5a", "#4f7c6e", "#6aa088", "#9cc8a8" }
local NOTE = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

-- paddy water strip
local water = c:ellipse(31, 57, 18, 2.6)
O.flat(c, water, PAD[3], "paddy")
water:each(function(x, y) if y >= 58 then c:put(x, y, PAD[2], { r = { name = "paddy" } }) end end)
O.dots(c, { { 16, 56 }, { 17, 56 }, { 18, 56 }, { 44, 56 }, { 45, 56 } }, PAD[4])

-- legs wading
for _, lx in ipairs({ 25, 37 }) do
  O.shade(c, c:rect(lx - 2, 49, lx + 2, 56), MUD, { R = 2, amb = .3, cuts = { .3, .55, .8 }, sep = MUD[1] })
end
O.dots(c, { { 22, 56 }, { 23, 56 }, { 27, 56 }, { 28, 56 }, { 34, 56 }, { 35, 56 }, { 39, 56 }, { 40, 56 } }, PAD[4]) -- ripple lip

-- rice blades on the crown (behind the head top)
local function blade(p, w, R)
  local m, n = O.tube(p, function(t) return w * (1 - t * .75) end)
  O.shadeN(c, m, n, R, { amb = .32, wrap = .45, sep = R[1], rim = true })
end
blade({ { 30, 22 }, { 29, 15 }, { 26, 9 }, { 21, 5 } }, 1.6, RICE)
blade({ { 32, 22 }, { 33, 14 }, { 34, 8 }, { 33, 3 } }, 1.6, RICE)
blade({ { 34, 22 }, { 38, 16 }, { 42, 12 }, { 47, 10 } }, 1.5, RICE)

-- the held seedling (right), mud clump with roots and 3 blades
blade({ { 53, 34 }, { 53, 29 }, { 52, 25 }, { 50, 22 } }, 1.1, RICE)
blade({ { 54, 34 }, { 55, 30 }, { 57, 27 }, { 59, 25 } }, 1.0, RICE)
blade({ { 53, 34 }, { 54, 30 }, { 55, 26 }, { 55, 22 } }, 1.0, RICE)
O.shade(c, c:ellipse(53.5, 36, 3, 2.2), MUD, { R = 1, amb = .3, cuts = { .3, .55, .8 }, sep = MUD[1] })
O.dots(c, { { 52, 39 }, { 54, 39 }, { 55, 40 } }, MUD[3]) -- root hairs

-- body: squat pear
local body = c:ellipse(31, 39, 14.5, 11.5)
body:add(c:ellipse(31, 29, 10, 8))
local bI, bT = O.shade(c, body, MOSS, { sphere = { 25, 30, 22 }, amb = .3, wrap = .45, sep = MOSS[1], rim = true, bounce = "#3a6a8a", bmax = 2 })
-- grassy blade flecks
O.tex(c, bI, bT, MOSS, function(x, y, i)
  if (x < 21 or x > 41 or y < 26) and H(x, 0, 3) > .55 and (y + math.floor(H(x, 1, 4) * 5)) % 5 < 2 and i >= 3 then return -1 end
end)
local bel = c:ellipse(31, 44, 8, 5.5) bel:clip(body)
O.shade(c, bel, BEL, { R = 3, amb = .4, wrap = .5, cuts = { .25, .5, .75 } })
-- arm reaching to the seedling
local arm, an = O.tube({ { 43, 38 }, { 47, 38 }, { 49, 37 }, { 51, 37 } }, function() return 2 end)
O.shadeN(c, arm, an, MOSS, { amb = .32, sep = MOSS[1], rim = true })
O.shade(c, c:ellipse(51, 37.5, 2.5, 2.5), MOSS, { R = 1, amb = .35, sep = MOSS[2] })
-- left arm resting
O.shade(c, c:ellipse(17, 41, 2.5, 3.5), MOSS, { R = 1, amb = .3, sep = MOSS[1] })

-- face, turned a little toward the seedling
c:eyeLocked(26, 28)
c:eyeLocked(36, 28)
c:cheek(23, 35) c:cheek(42, 35)
-- singing mouth: round "o"
O.dots(c, { { 33, 35 }, { 34, 35 }, { 32, 36 }, { 35, 36 }, { 32, 37 }, { 35, 37 }, { 33, 38 }, { 34, 38 } }, "#3e1620")
O.dots(c, { { 33, 36 }, { 34, 36 }, { 33, 37 }, { 34, 37 } }, "#b52e3f") O.dot(c, 34, 37, "#e8493b")

-- the sung note, drifting up between face and seedling
O.flat(c, c:rect(44, 22, 45, 23), NOTE[3], "note") O.dot(c, 44, 22, NOTE[4]) O.dot(c, 45, 23, NOTE[2])
O.flat(c, c:rect(46, 17, 46, 22), NOTE[2], "note") O.dots(c, { { 47, 18 }, { 48, 19 } }, NOTE[3])

O.shift(c, -3, 0)
O.done(c, "mt-seedling-plod-yard")
