-- Kernel Knock (mh-kernel-knock), yard sprite 64x64. Opus richness pass (c00/opus3), built on c00/opus2.
-- Richness pass: the outline is now a kernel wedge (straight tapering flanks, softer split, no heart shoulders);
-- glossy pericarp streaks down the flanks, crinkle creases in each popcorn bloom, curled hull flakes with a pale
-- inner face, and a butter drip running down the hull from the puff (the closer-look detail).
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
  local I, T = O.shade(c, c:ellipse(q[1], q[2], q[3], q[3] - .5), POP, { sphere = { q[1] - 2, q[2] - 2, q[3] + 2 }, amb = .35, wrap = .5, sep = POP[3], rim = true, bounce = "#c0906a", bmax = 2 })
  -- crinkle: a short curved crease in each bloom, lower right of centre
  O.tex(c, I, T, POP, function(x, y, i)
    local dx, dy = x - q[1], y - q[2]
    if math.abs(math.sqrt(dx * dx + dy * dy) - q[3] * .55) < .5 and dx > 0 and dy > -1 and i >= 3 then return -1 end
  end)
end

-- the kernel: broad rounded top, tapering to the tip
local body = c:ellipse(32, 33, 13, 10)
body:add(c:poly{ { 19, 34 }, { 45, 34 }, { 36, 53 }, { 28, 53 } })
-- split hull edge: soft zigzag along the top
local zig = { { 17, 25 }, { 20, 27 }, { 23, 25 }, { 26, 28 }, { 29, 25 }, { 32, 28 }, { 35, 25 }, { 38, 28 }, { 41, 25 }, { 44, 27 }, { 47, 25 }, { 47, 10 }, { 17, 10 } }
body:cut(c:poly(zig))
local bI, bT = O.shade(c, body, KER, { sphere = { 27, 31, 18 }, amb = .25, wrap = .4, rim = true, bounce = "#8a4a6a", bmax = 2, sep = POP[2] })
-- pericarp streaks: fine lengthwise lines on the flanks (off the face)
O.tex(c, bI, bT, KER, function(x, y, i)
  local u = (x - 32) / math.max(3, 14 - math.max(0, y - 34) * .5)
  if math.abs(u) < .62 or y < 30 then return 0 end
  if math.abs((u * 5) % 1 - .5) < .12 then return -1 end
end)
-- glossy hull: a second soft streak down the left
O.mark(c, { { 21, 33 }, { 21, 34 }, { 21, 35 }, { 22, 36 }, { 22, 37 }, { 23, 39 } }, KER[6])
-- butter drip running down the right of the hull from the puff
O.mark(c, { { 40, 28 }, { 41, 28 }, { 40, 29 }, { 41, 29 }, { 41, 30 }, { 41, 31 }, { 41, 32 } }, "#ffe36a")
O.mark(c, { { 42, 29 }, { 42, 31 }, { 42, 32 }, { 41, 33 }, { 42, 33 } }, "#e8b434")
O.mark(c, { { 40, 28 } }, "#fff6b8")
-- tip cap
local tip = c:poly{ { 29, 50 }, { 35, 50 }, { 34, 54 }, { 30, 54 } }
O.shade(c, tip, TIP, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = KER[2] })

-- hull flakes curling away from the split
O.shade(c, c:poly{ { 15, 22 }, { 19, 24 }, { 14, 28 }, { 12, 25 } }, KER, { R = 1, amb = .35, wrap = .4, sep = KER[1] })
O.dots(c, { { 14, 25 }, { 15, 26 } }, TIP[3])   -- pale inner face of the curl
O.shade(c, c:poly{ { 48, 21 }, { 51, 24 }, { 50, 28 }, { 46, 24 } }, KER, { R = 1, amb = .35, wrap = .4, sep = KER[1] })
O.dots(c, { { 49, 24 }, { 49, 25 } }, TIP[3])

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
