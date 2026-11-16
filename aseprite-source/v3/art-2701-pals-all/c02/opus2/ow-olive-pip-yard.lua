-- Olive Pip (ow-olive-pip), yard sprite 64x64. Opus second pass (art-2701-pals-all/c02/opus2), built on the Haiku pass.
-- Bloomcaller, common, Olivewhistle. "Grew up in an olive grove and still thinks every tree is hers."
-- A glossy green olive (true olive shape: a tall, slightly lopsided oval with a waxy bloom and one bright spec)
-- with a short stalk and two narrow silver-backed olive leaves on top (double knob). She has one arm round the
-- trunk of a small gnarled olive tree, hugging it like a pet.
-- Fix vs Haiku: the leaf knobs were grass blades (rabbit ears); now true lanceolate olive leaves with midribs and
-- silver undersides; the tree is a real olive (twisted grey trunk, silvery canopy with olives), clear of her body.
-- quirk: a little heart carved into the olive tree's bark (it's hers, obviously).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-olive-pip-yard", 64)

local OLV  = { "#24321c", "#3b5124", "#56722c", "#78933a", "#a2b852", "#d2df8c" }
local LEAF = { "#2c4438", "#466456", "#6a8a74", "#93ad94", "#bfd2b4", "#e2ecd2" }
local BARK = { "#33282a", "#54433e", "#76614f", "#988266", "#bba57f", "#dccaa2" }
local BERRY = { "#2a1f33", "#4a3352", "#73507a" }
local STALK = { "#3a3220", "#6a5a32", "#9a8a4a" }

c:groundShadow(36, 57, 25, 2.5)

-- olive tree (behind, right)
local trunk = O.tube({ { 49, 57 }, { 52, 50 }, { 45, 44 }, { 49, 33 } }, function(t) return 3.2 - 1.2 * t end)
local root = c:poly{ { 44, 57 }, { 47, 53 }, { 52, 53 }, { 55, 57 } }
trunk:add(root)
local tb = {}
trunk:each(function(x, y) if (x * 3 + y) % 5 == 0 then tb[K(x, y)] = -1 end end) -- twisted bark ridges
local tI, tT = O.shade(c, trunk, BARK, { R = 2, bias = tb, amb = .25, wrap = .35, rim = true })
-- branches into the canopy
O.shade(c, c:line({ { 49, 35 }, { 44, 29 } }, 2), BARK, { R = 1, amb = .3 })
O.shade(c, c:line({ { 49, 35 }, { 55, 28 } }, 2), BARK, { R = 1, amb = .3 })
-- canopy: five silvery leaf clumps, each its own shaded cluster
local CAN = { "#22382f", "#365446", "#527660", "#78987c", "#a2bc98", "#ccdcbc" }
for _, q in ipairs({ { 49, 15, 5, 4 }, { 42, 20, 4.5, 3.5 }, { 56, 19, 4.5, 3.5 }, { 45, 26, 5, 3.5 }, { 54, 26, 5, 3.5 } }) do
  local m = c:ellipse(q[1], q[2], q[3], q[4])
  local cb = {}
  m:each(function(x, y) if H(x, y, 5) > .82 then cb[K(x, y)] = 1 end end)
  local cI, cT = O.shade(c, m, CAN, { R = 2, bias = cb, amb = .2, wrap = .35, sep = CAN[1], rim = true, bounce = "#5b6a8a", bmax = 2 })
  O.tex(c, cI, cT, CAN, function(x, y, i) if (x + 2 * y) % 5 == 0 and H(x, y, 6) > .45 and i >= 3 then return -1 end end)
end
-- a few ripe olives
for _, p in ipairs({ { 43, 22 }, { 52, 17 }, { 50, 27 }, { 57, 21 } }) do
  O.dots(c, { { p[1], p[2] }, { p[1] + 1, p[2] }, { p[1], p[2] + 1 }, { p[1] + 1, p[2] + 1 } }, BERRY[2])
  O.dot(c, p[1], p[2], BERRY[3]) O.dot(c, p[1] + 1, p[2] + 1, BERRY[1])
end

-- body: olive
local body = c:ellipse(25, 39, 13.5, 16.5)
local bb = {}
body:each(function(x, y) if y > 53 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, body, OLV, { sphere = { 20, 32, 19 }, bias = bb, amb = .2, wrap = .35, rim = true, bounce = "#5a6d8c", bmax = 2 })
-- waxy bloom: pale speckles on the lit side, one bright spec
O.tex(c, bI, bT, OLV, function(x, y, i) if H(x, y, 21) > .9 and i >= 3 and i <= 5 then return 1 end end)
O.dots(c, { { 17, 27 }, { 18, 27 }, { 16, 28 } }, OLV[6])

-- stalk + two olive leaves (double knob)
O.shade(c, c:line({ { 25, 23 }, { 26, 18 } }, 2), STALK, { R = 1, amb = .3, cuts = { .35, .7 } })
local function leaf(a, b, ctl)
  local m, n, T, S = O.tube({ a, ctl, ctl, b }, function(t) return 2.6 * math.sin(math.pi * t) ^ .8 end)
  local lb = {}
  m:each(function(x, y)
    local s = S[K(x, y)] or 0
    if math.abs(s) < .3 then lb[K(x, y)] = 2 elseif s > .3 then lb[K(x, y)] = 1 end -- midrib, silver underside
  end)
  O.shadeN(c, m, n, LEAF, { bias = lb, amb = .3, sep = LEAF[1] })
end
leaf({ 25, 18 }, { 14, 10 }, { 19, 11 })
leaf({ 26, 18 }, { 37, 9 }, { 33, 11 })

-- face
c:eyeLocked(17, 36)
c:eyeLocked(28, 36)
O.dots(c, { { 15, 43 }, { 16, 43 } }, "#f5809f") O.dots(c, { { 34, 43 }, { 35, 43 } }, "#f5809f")
O.dots(c, { { 22, 44 }, { 23, 45 }, { 24, 45 }, { 25, 45 }, { 26, 44 } }, P.ink)

-- arm hugging the trunk
local arm = O.tube({ { 37, 42 }, { 40, 43 }, { 43, 44 }, { 46, 43 } }, function(t) return 1.8 end)
O.shade(c, arm, OLV, { R = 1, amb = .3, sep = OLV[1] })
O.dots(c, { { 46, 42 }, { 47, 42 } }, OLV[4]) -- fingers on the bark
-- little feet
for _, fx in ipairs({ 19, 30 }) do O.shade(c, c:ellipse(fx, 56, 3, 1.5), OLV, { R = 1, amb = .3, sep = OLV[1] }) end

-- quirk: a heart carved into the bark (red-stained, so it reads at 1x)
O.dots(c, { { 48, 44 }, { 50, 44 }, { 47, 45 }, { 48, 45 }, { 49, 45 }, { 50, 45 }, { 51, 45 }, { 48, 46 }, { 49, 46 }, { 50, 46 }, { 49, 47 } }, "#c2413c")
O.dots(c, { { 48, 44 }, { 47, 45 } }, "#e8755c")
O.dots(c, { { 50, 47 }, { 51, 46 }, { 52, 45 } }, BARK[1])

O.shift(c, -4, -2)
O.done(c, "ow-olive-pip-yard")
