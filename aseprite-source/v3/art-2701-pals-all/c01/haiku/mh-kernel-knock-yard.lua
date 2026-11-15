-- Kernel Knock (mh-kernel-knock), yard 64x64. Haiku pass, c01.
-- seedkeeper, common. A single golden kernel, excited, with a little fist and two popped puffs on top.
-- quirk: knock marks beside it and a burst of popped corn puffs above its head.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-kernel-knock-yard", 64)

local CORN  = { "#8f4a1f", "#b5652a", "#d98322", "#f5b82e", "#ffd55a", "#ffe9a0" }
local POP   = { "#c9ad8a", "#dfc8a6", "#eedcbc", "#f6e9d0", "#fff4e0" }
local INK   = P.ink

c:groundShadow(31, 58, 14, 3)

-- popped puffs above the kernel
for _, p in ipairs({ { 20, 13, 3, 3 }, { 30, 8, 4, 4 }, { 41, 13, 3, 3 }, { 25, 19, 2, 2 } }) do
  local pm = c:ellipse(p[1], p[2], p[3], p[4])
  O.shade(c, pm, POP, { R = 2 })
end

-- kernel body: round top, tapered tip
local body = c:ellipse(31, 33, 15, 15)
body:add(c:poly{ {19,38},{31,55},{43,38} })
O.shade(c, body, CORN, { R = 6 })

-- excited arm and little fist, knock lines on the left
local arm = c:line({ {43,36}, {47,31} }, 2)
O.flat(c, arm, CORN[3])
local fist = c:ellipse(49, 29, 3, 3)
O.shade(c, fist, CORN, { R = 1, sep = CORN[1] })
local knock = {}
for _, l in ipairs({ { {8,26},{5,23} }, { {7,33},{3,33} }, { {8,40},{5,43} } }) do
  local m = c:line(l, 1)
  O.flat(c, m, CORN[4])
end

-- face: locked eyes, ink button nose, open excited mouth
c:eyeLocked(23, 33)
c:eyeLocked(35, 33)
c:cheek(19, 40)
c:cheek(41, 40)
O.dot(c, 31, 39, INK)
O.dot(c, 30, 38, P.cream)
O.dots(c, { {28,43},{34,43} }, CORN[1])
O.dots(c, { {29,44},{30,44},{31,44},{32,44},{33,44},{29,45},{30,45},{31,45},{32,45},{33,45} }, "#6e2c2a")

O.done(c, "mh-kernel-knock-yard")
