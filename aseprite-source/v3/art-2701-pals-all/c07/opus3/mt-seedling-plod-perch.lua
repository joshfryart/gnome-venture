-- Seedling Plod (mt-seedling-plod), perch sprite 36x36, hand-built at this size (opus3 richness pass, from opus2).
-- opus3: grass tufts on the silhouette, rim on the blades, mud splashes and a wet line on the legs, moss strokes,
-- a dewdrop on the tall blade.
-- Pear-shaped moss body with a pale belly, three rice blades on the crown (2 px at the base), mud legs in a
-- paddy strip, a seedling held out in one hand.
-- quirk: singing to it (round open mouth, one note).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mt-seedling-plod-perch", 36)

local MOSS = { "#24544a", "#2f7350", "#3f9150", "#5aaa52", "#86c862", "#bfe282" }
local BEL  = { "#a2c878", "#c8e09a", "#e6f0bc" }
local RICE = { "#2f6a3a", "#4a8c3c", "#74b04a", "#a8d468", "#d4ec98" }
local MUD  = { "#3e2a26", "#5e3e30", "#86583e", "#a87a52" }
local PAD  = { "#4f7c6e", "#6aa088", "#9cc8a8" }

local water = c:ellipse(16, 32, 10, 1.3)
O.flat(c, water, PAD[2], "paddy")
for _, lx in ipairs({ 12, 19 }) do
  O.shade(c, c:rect(lx, 27, lx + 2, 32), MUD, { R = 1, amb = .3, cuts = { .3, .55, .8 }, sep = MUD[1] })
  O.dots(c, { { lx, 31 }, { lx + 1, 31 }, { lx + 2, 31 } }, "#4f7c6e") O.dot(c, lx + 1, 29, MUD[4])
end
local function blade(p, w)
  local m, n = O.tube(p, function(t) return w * (1 - t * .7) end)
  O.shadeN(c, m, n, RICE, { amb = .32, wrap = .45, sep = RICE[1], rim = true })
end
blade({ { 15, 11 }, { 14, 8 }, { 12, 5 }, { 10, 3 } }, 1)
blade({ { 17, 11 }, { 17, 7 }, { 18, 5 }, { 18, 2 } }, 1)
blade({ { 18, 11 }, { 20, 8 }, { 22, 6 }, { 25, 5 } }, 1)
blade({ { 29, 19 }, { 29, 16 }, { 28, 14 }, { 27, 12 } }, .8)
blade({ { 30, 19 }, { 31, 16 }, { 32, 14 }, { 33, 13 } }, .8)
O.shade(c, c:ellipse(29.5, 20.5, 2, 1.5), MUD, { R = 1, amb = .3, cuts = { .3, .55, .8 }, sep = MUD[1] })
local body = c:ellipse(16, 21, 9, 7) body:add(c:ellipse(16, 15, 6, 5))
body:add(c:poly{ { 11, 13 }, { 11, 10 }, { 13, 12 } }) body:add(c:poly{ { 21, 13 }, { 22, 10 }, { 20, 12 } }) body:add(c:poly{ { 7, 21 }, { 6, 18 }, { 8, 19 } })
local bI, bT = O.shade(c, body, MOSS, { sphere = { 12, 15, 15 }, amb = .3, wrap = .45, sep = MOSS[1], rim = true, bounce = "#3a6a8a", bmax = 2 })
O.tex(c, bI, bT, MOSS, function(x, y, i) if (x < 11 or x > 22 or y > 24) and O.H(x, y // 2, 3) > .8 and i >= 3 then return -1 end end)
local bel = c:ellipse(16, 25, 5, 3) bel:clip(body)
O.shade(c, bel, BEL, { R = 2, amb = .4, cuts = { .35, .7 } })
local arm, an = O.tube({ { 23, 21 }, { 25, 21 }, { 26, 21 }, { 28, 21 } }, function() return 1.2 end)
O.shadeN(c, arm, an, MOSS, { amb = .32, sep = MOSS[1] })
c:eyeSmall(12, 15)
c:eyeSmall(19, 15)
O.dot(c, 10, 19, "#f5809f") O.dot(c, 23, 19, "#f5809f")
O.dots(c, { { 16, 19 }, { 17, 19 }, { 15, 20 }, { 18, 20 }, { 16, 21 }, { 17, 21 } }, "#3e1620") O.dots(c, { { 16, 20 }, { 17, 20 } }, "#b52e3f")
O.flat(c, c:rect(24, 10, 25, 11), "#5fc4c8", "note") O.flat(c, c:rect(26, 6, 26, 10), "#3a86b0", "note") O.dot(c, 27, 7, "#5fc4c8")
O.dot(c, 19, 4, "#7fd2d6") O.dot(c, 19, 5, "#3a86b0") -- dewdrop
O.done(c, "mt-seedling-plod-perch")
