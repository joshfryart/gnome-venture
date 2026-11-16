-- Kernel Knock (mh-kernel-knock), yard sprite 64x64. Opus second pass (c00/opus2), built from the Haiku first pass.
-- Seedkeeper, common, Maizehollow. "Knocks twice, then pops with excitement."
-- One fat glossy corn kernel (broad top, tapering to a pale tip cap) caught mid-pop: its hull has split along the
-- top and a cream popcorn puff (warm butter shadows, no blue) is bursting out, two hull flakes curling away.
-- quirk: one little nub fist is raised, knuckles still knocking: two knock ticks beside it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mh-kernel-knock-yard", 64)

local KER  = { "#7a3018", "#b0521c", "#dd7a1e", "#f5a82a", "#ffcf4a", "#fff0a0" }
local POP  = { "#8a6040", "#b88c5c", "#dcb98a", "#f0d9ae", "#fbeccb", "#fff6e0" }
local TIP  = { "#8f6a4a", "#c9a37a", "#ead2a8", "#f8ead0" }

c:groundShadow(32, 57, 15, 3)

-- popcorn puff bursting from the top (drawn first, the hull overlaps its base)
-- each bloom shaded on its own, back to front, with a warm crease line where it overlaps the one behind
for _, q in ipairs({ { 26, 12, 5 }, { 38, 12, 5 }, { 32, 8, 4.5 }, { 21, 20, 4.5 }, { 44, 20, 4.5 }, { 32, 16, 6.5 }, { 26, 21, 4 }, { 39, 21, 4 } }) do
  O.shade(c, c:ellipse(q[1], q[2], q[3], q[3] - .5), POP, { sphere = { q[1] - 2, q[2] - 2, q[3] + 2 }, amb = .35, wrap = .5, sep = POP[3], rim = true, bounce = "#c0906a", bmax = 2 })
end

-- the kernel: broad rounded top, tapering to the tip
local body = c:ellipse(32, 36, 14, 12)
body:add(c:poly{ { 19, 39 }, { 45, 39 }, { 35, 53 }, { 29, 53 } })
-- split hull edge: zigzag along the top
local zig = { { 17, 20 }, { 20, 26 }, { 23, 23 }, { 26, 27 }, { 29, 24 }, { 32, 27 }, { 35, 24 }, { 38, 27 }, { 41, 23 }, { 44, 26 }, { 47, 20 }, { 47, 10 }, { 17, 10 } }
body:cut(c:poly(zig))
local bI, bT = O.shade(c, body, KER, { sphere = { 27, 31, 18 }, amb = .25, wrap = .4, rim = true, bounce = "#8a4a6a", bmax = 2, sep = POP[2] })
-- glossy hull: a second soft streak down the left
O.mark(c, { { 22, 35 }, { 22, 36 }, { 22, 37 }, { 23, 38 }, { 23, 39 } }, KER[6])
-- tip cap
local tip = c:poly{ { 29, 50 }, { 35, 50 }, { 34, 54 }, { 30, 54 } }
O.shade(c, tip, TIP, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = KER[2] })

-- hull flakes curling away from the split
O.shade(c, c:poly{ { 15, 22 }, { 19, 25 }, { 14, 28 }, { 12, 25 } }, KER, { R = 1, amb = .35, wrap = .4 })
O.shade(c, c:poly{ { 48, 21 }, { 51, 24 }, { 50, 28 }, { 46, 25 } }, KER, { R = 1, amb = .35, wrap = .4 })

-- nub arms: left resting, right fist raised and knocking
local aL, nL = O.tube({ { 19, 40 }, { 17, 42 }, { 16, 43 }, { 16, 45 } }, function(t) return 1.8 end)
O.shadeN(c, aL, nL, KER, { amb = .3, wrap = .4, sep = KER[1] })
local aR, nR = O.tube({ { 45, 39 }, { 49, 38 }, { 51, 35 }, { 51, 32 } }, function(t) return 2 end)
O.shadeN(c, aR, nR, KER, { amb = .3, wrap = .4, sep = KER[1] })
O.shade(c, c:ellipse(51.5, 30.5, 2.5, 2.5), KER, { sphere = { 50, 29, 3 }, amb = .35, wrap = .4, sep = KER[1] })
O.dots(c, { { 52, 29 }, { 53, 30 } }, KER[2]) -- knuckle crease

-- face: excited, mouth open
c:eyeLocked(24, 31)
c:eyeLocked(35, 31)
c:cheek(22, 38) c:cheek(40, 38)
O.flat(c, c:rect(30, 39, 33, 42), P.ink, "mouth")
O.dots(c, { { 30, 39 }, { 33, 39 }, { 30, 42 }, { 33, 42 } }, KER[4])
O.dots(c, { { 31, 41 }, { 32, 41 } }, P.petal.base)

O.shift(c, 0, 0)
O.done(c, "mh-kernel-knock-yard", function(c)
  -- knock ticks beside the fist (after the outline, not outlined)
  for _, p in ipairs({ { 57, 26 }, { 58, 25 }, { 57, 31 }, { 58, 31 }, { 59, 31 }, { 57, 35 }, { 58, 36 } }) do c:put(p[1], p[2], P.ink) end
end)
