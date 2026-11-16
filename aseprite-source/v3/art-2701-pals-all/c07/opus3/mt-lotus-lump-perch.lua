-- Lotus Lump (mt-lotus-lump), perch sprite 36x36, hand-built at this size (opus3 richness pass, from opus2).
-- opus3: petal veins on the bud, rim on the petals, rain beads and a curled back edge on the pad, a raindrop on the tip.
-- Pink lotus bud with a pointed tip (pale petals cupping the base, two back petals), on a notched lily pad
-- with a ripple ring. Pill eyes under drooping lids with lashes (asleep).
-- quirk: a sleep bubble from its nose.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mt-lotus-lump-perch", 36)

local PET = { "#7d2c5e", "#a83a72", "#d45c8e", "#f088a8", "#ffb4c8", "#ffe0e6" }
local PAD = { "#1f4a44", "#24544a", "#3f9150", "#62b058", "#9ad06a", "#c4e07a" }
local SKY = { "#5f9ad0", "#8bc4ea", "#b9e2f5", "#e4f6ff" }

local rip = c:ellipse(18, 31, 14, 2.5) rip:cut(c:ellipse(18, 30.5, 12.5, 1.8))
O.flat(c, rip, "#5fc4c8", "ripple")
local pad = c:ellipse(18, 28.5, 12.5, 3.5) pad:cut(c:poly{ { 19, 28 }, { 26, 33 }, { 30, 33 } })
O.shade(c, pad, PAD, { R = 2, amb = .3, wrap = .45, sep = PAD[1], rim = true })
O.dots(c, { { 8, 28 }, { 28, 28 } }, "#d8f4ee") O.dots(c, { { 8, 29 }, { 28, 29 } }, PAD[2])
for _, d in ipairs({ -1, 1 }) do
  O.shade(c, c:poly{ { 18 + d * 3, 27 }, { 18 + d * 9, 24 }, { 18 + d * 11, 15 }, { 18 + d * 6, 19 } }, PET, { R = 1, amb = .26, sep = PET[1] })
end
local bud = c:ellipse(18, 20, 8, 7.5) bud:add(c:poly{ { 12, 16 }, { 17, 7 }, { 19, 7 }, { 24, 16 } })
local bb = {} bud:each(function(x, y) if y < 11 then bb[K(x, y)] = -2 elseif y < 14 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, bud, PET, { sphere = { 15, 15, 13 }, amb = .34, wrap = .45, bias = bb, sep = PET[1], rim = true, bounce = "#8a6fd0", bmax = 2 })
O.tex(c, bI, bT, PET, function(x, y, i) if y < 16 and (x == 15 or x == 21) and i >= 3 then return -1 end end) -- veins
O.dot(c, 18, 5, SKY[2]) O.dot(c, 18, 6, SKY[3]) -- raindrop on the tip
for _, d in ipairs({ -1, 1 }) do
  local fp = c:poly{ { 18 + d * 1, 27 }, { 18 + d * 7, 27 }, { 18 + d * 10, 20 }, { 18 + d * 6, 23 }, { 18 + d * 3, 25 } }
  O.shade(c, fp, PET, { R = 1, amb = .45, sep = PET[1], rim = true })
end
for _, ex in ipairs({ 14, 21 }) do
  c:eyeSmall(ex, 17)
  O.dots(c, { { ex, 17 }, { ex + 1, 17 }, { ex, 18 }, { ex + 1, 18 } }, PET[3]) -- lid shut over the pill
  O.dots(c, { { ex - 1, 18 }, { ex + 2, 18 } }, "#2b1c26") -- lid corners: closed arc
end
O.dot(c, 11, 21, "#f5809f") O.dot(c, 25, 21, "#f5809f")
O.dot(c, 16, 23, "#5a1e3a")
O.flat(c, c:ellipse(20.5, 23.5, 1.5, 1.5), SKY[3], "bubble") O.dot(c, 20, 23, SKY[4]) O.dot(c, 21, 24, SKY[2])
O.shift(c, 0, -1)
O.done(c, "mt-lotus-lump-perch", function(c)
  for _, p in ipairs({ { 4, 4 }, { 30, 6 }, { 9, 11 }, { 28, 13 } }) do
    for k = 0, 1 do if not c:get(p[1], p[2] + k) then c:put(p[1], p[2] + k, SKY[2], { r = { name = "rain" } }) end end
  end
end)
