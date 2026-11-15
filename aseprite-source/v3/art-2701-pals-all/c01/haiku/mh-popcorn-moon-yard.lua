-- Popcorn Moon (mh-popcorn-moon), yard 64x64. Haiku pass, c01. RARE: a touch fancier.
-- brewroot, rare. A crescent moon made of popcorn, with a face on its fat side, popcorn bumps on the rim,
-- a glow ring of sparkles, and popped bits flying off the lower right.
-- quirk: goes pop at midnight; a few kernels are bursting off the rim and a burst of puffs sails away.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-popcorn-moon-yard", 64)

local POP  = { "#b89468", "#d9b98a", "#ecd6a8", "#f6e6c0", "#fbf1d6" }
local INK  = P.ink

c:groundShadow(31, 59, 13, 2)

-- crescent body: outer disc minus the offset inner disc
local moon = c:ellipse(31, 32, 22, 22):copy():cut(c:ellipse(41, 24, 17, 17))
local puffs = { {9,36},{9,27},{12,18},{19,11},{28,9},{17,50},{28,55},{40,53} }
for _, p in ipairs(puffs) do moon:add(c:ellipse(p[1], p[2], 2, 2)) end
O.shade(c, moon, POP, { R = 6 })
-- popcorn bumps: each puff separated from the body by a 1 px line
for _, p in ipairs(puffs) do
  O.shade(c, c:ellipse(p[1], p[2], 2, 2), POP, { R = 1, sep = POP[1] })
end

-- popped bits flying off the lower right
O.shade(c, c:ellipse(51, 48, 2, 2), POP, { R = 1 })
O.shade(c, c:ellipse(55, 53, 1, 1), POP, { R = 0 })
O.shade(c, c:ellipse(47, 56, 1, 1), POP, { R = 0 })

-- face on the fat side: locked eyes, button nose, grin, cheeks
c:eyeLocked(13, 29)
c:eyeLocked(19, 29)
c:cheek(11, 34)
c:cheek(20, 35)
O.dot(c, 16, 35, INK)
O.dot(c, 15, 34, P.cream)
O.dots(c, { {13,39},{14,40},{15,40},{16,40},{17,40},{18,40},{19,39} }, "#6e2c2a")

-- rare sparkle
c:sparkle(53, 12)
c:sparkle(57, 36)

O.done(c, "mh-popcorn-moon-yard")
