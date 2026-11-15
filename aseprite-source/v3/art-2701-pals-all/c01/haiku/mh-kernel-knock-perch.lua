-- Kernel Knock (mh-kernel-knock), perch sprite 36x36. Haiku pass, c01. Hand-built at this size.
-- quirk: two knock marks and a popped puff above.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-kernel-knock-perch", 36)

local CORN = { "#8f4a1f", "#b5652a", "#d98322", "#f5b82e", "#ffd55a", "#ffe9a0" }
local POP  = { "#c9ad8a", "#dfc8a6", "#eedcbc", "#f6e9d0", "#fff4e0" }
local INK  = P.ink

c:groundShadow(18, 32, 8, 2)

for _, p in ipairs({ { 12, 6, 2, 2 }, { 18, 4, 2, 2 }, { 24, 7, 2, 2 } }) do
  O.shade(c, c:ellipse(p[1], p[2], p[3], p[4]), POP, { R = 1 })
end

local body = c:ellipse(18, 18, 8, 8)
body:add(c:poly{ {11,22},{18,30},{25,22} })
O.shade(c, body, CORN, { R = 3 })

local arm = c:line({ {25,20}, {28,17} }, 1)
O.flat(c, arm, CORN[3])
O.shade(c, c:ellipse(29, 16, 2, 2), CORN, { R = 1, sep = CORN[1] })
for _, l in ipairs({ { {4,14},{2,12} }, { {4,20},{2,22} } }) do
  O.flat(c, c:line(l, 1), CORN[4])
end

c:eyeSmall(14, 16)
c:eyeSmall(20, 16)
O.dot(c, 18, 20, INK)
O.dots(c, { {16,22},{17,23},{18,23},{19,23},{20,22} }, "#6e2c2a")

O.done(c, "mh-kernel-knock-perch")
