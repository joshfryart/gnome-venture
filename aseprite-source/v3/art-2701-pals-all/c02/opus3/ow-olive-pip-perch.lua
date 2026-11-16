-- Olive Pip (ow-olive-pip), perch sprite 36x36. Opus richness pass (c02/opus3), built on opus2, hand-built at this size.
-- Richness (opus3): bark furrows with lit ridges + bounce, canopy leaf gaps and silver flashes, olives as 2x2
-- purple drupes with a glint (not dots), olive skin freckles kept off the face, leaf rim light.
-- Glossy green olive with a stalk and two silver olive leaves (double knob), one arm round a small olive tree.
-- Fix vs Haiku: the tree was cut close to the body and touched it; now it stands 2 px clear, with a
-- twisted trunk and three canopy clumps; the leaf knobs are olive leaves, not grass ears.
-- quirk: a red heart carved into the trunk.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-olive-pip-perch", 36)

local OLV  = { "#24321c", "#3b5124", "#56722c", "#78933a", "#a2b852", "#d2df8c" }
local LEAF = { "#2c4438", "#466456", "#6a8a74", "#93ad94", "#bfd2b4", "#e2ecd2" }
local CAN  = { "#22382f", "#365446", "#527660", "#78987c", "#a2bc98", "#ccdcbc" }
local BARK = { "#33282a", "#54433e", "#76614f", "#988266", "#bba57f", "#dccaa2" }

c:groundShadow(19, 31, 13, 1.2)

-- tree
local trunk = O.tube({ { 28, 32 }, { 30, 27 }, { 26, 23 }, { 28, 16 } }, function(t) return 2 - .6 * t end)
trunk:add(c:poly{ { 25, 32 }, { 27, 30 }, { 30, 30 }, { 32, 32 } })
local tI, tT = O.shade(c, trunk, BARK, { R = 1, amb = .25, wrap = .35, rim = true, bounce = "#5b6a8a", bmax = 2 })
O.tex(c, tI, tT, BARK, function(x, y, i) if (x * 3 + y) % 5 == 0 and i >= 3 then return -1 end end)
for _, q in ipairs({ { 28, 8, 3.5, 3 }, { 25, 12, 3, 2.5 }, { 31, 12, 3, 2.5 } }) do
  local cI, cT = O.shade(c, c:ellipse(q[1], q[2], q[3], q[4]), CAN, { R = 1.5, amb = .2, wrap = .35, sep = CAN[1], rim = true })
  O.tex(c, cI, cT, CAN, function(x, y, i) if (x + 2 * y) % 5 == 0 and i >= 3 then return -1 end end)
end
for _, q in ipairs({ { 24, 11 }, { 31, 12 }, { 28, 7 } }) do -- olives: 2x2 drupes with a glint
  O.dots(c, { { q[1], q[2] }, { q[1] + 1, q[2] }, { q[1], q[2] + 1 }, { q[1] + 1, q[2] + 1 } }, "#5a3468")
  O.dot(c, q[1], q[2], "#c99ad0") O.dot(c, q[1] + 1, q[2] + 1, "#24182c")
end
-- heart carved in the trunk
O.dots(c, { { 26, 24 }, { 28, 24 }, { 26, 25 }, { 27, 25 }, { 28, 25 }, { 27, 26 } }, "#c2413c")

-- body
local body = c:ellipse(13, 21, 8, 9.5)
local bI, bT = O.shade(c, body, OLV, { sphere = { 10, 17, 11 }, amb = .2, wrap = .35, rim = true, bounce = "#5a6d8c", bmax = 2 })
O.tex(c, bI, bT, OLV, function(x, y, i)
  if y >= 18 and y <= 27 and x >= 7 and x <= 19 then return end
  if H(x, y, 23) > .93 and i >= 2 and i <= 4 then return 1 end
end)
O.dots(c, { { 9, 14 }, { 10, 14 } }, OLV[6])
-- stalk + leaves
O.flat(c, c:rect(13, 9, 13, 11), "#6a5a32", "stalk")
local function leaf(a, b, ctl)
  local m, n, T, S = O.tube({ a, ctl, ctl, b }, function(t) return 1.6 * math.sin(math.pi * t) ^ .8 end)
  local lb = {}
  m:each(function(x, y) if (S[K(x, y)] or 0) > .2 then lb[K(x, y)] = 1 end end)
  O.shadeN(c, m, n, LEAF, { bias = lb, amb = .3, sep = LEAF[1] })
end
leaf({ 13, 9 }, { 6, 4 }, { 9, 5 })
leaf({ 14, 9 }, { 21, 3 }, { 18, 5 })

-- face
c:eyeSmall(9, 20)
c:eyeSmall(15, 20)
O.dot(c, 7, 24, "#f5809f") O.dot(c, 18, 24, "#f5809f")
O.dots(c, { { 11, 25 }, { 12, 26 }, { 13, 26 }, { 14, 25 } }, P.ink)
-- arm to the trunk
O.shade(c, c:line({ { 20, 23 }, { 25, 24 } }, 2), OLV, { R = 1, amb = .3, sep = OLV[1] })
-- feet
for _, fx in ipairs({ 10, 16 }) do O.shade(c, c:ellipse(fx, 31, 2, 1), OLV, { R = 1, amb = .3, sep = OLV[1] }) end

O.shift(c, -1, -1)
O.done(c, "ow-olive-pip-perch")
