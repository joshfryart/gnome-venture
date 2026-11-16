-- Diamond Spur (pl-dlz-4), perch sprite 36x36. Opus richness pass (c11/opus3), hand-built at this size.
-- Dusty-rose horned lizard: crown of three horns, chin up, flat wide body, stubby tail. 2x3 pill eyes.
-- quirk: the four gold-rimmed jade diamonds standing along its back (lit facet upper-left).
-- opus3: sparse bead scales, pale fringe spines with shadow, horn rings, rim + bounce, one pale diamond on the tail.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-dlz-4-perch", 36)

local MAUV = { "#3a1e34", "#5e2e4a", "#8a4660", "#b26a78", "#d6949a", "#f0c0b4" }
local SAND = { "#c08a6a", "#e8bc92", "#f8dcb4" }
local JADE = { "#123a3a", "#1a5a52", "#24806a", "#3cac82", "#76d49a", "#c0f0c0" }
local GOLD = { "#b8782a", "#ffe08a" }
local HORN = { "#5a3a30", "#9a6a4a", "#d0a070", "#f2d4a4" }

c:groundShadow(18, 33, 14, 1)
local tail, tn = O.tube({ { 29, 27 }, { 31, 28 }, { 32, 29 }, { 33, 31 } }, function(t) return 2 * (1 - .75 * t) + .3 end)
O.shadeN(c, tail, tn, MAUV, { amb = .3, wrap = .4, rim = true, bounce = "#5a6a9a", bmax = 2 })
-- diamonds: hand-placed 3x6 jade gems (lit facet upper-left, dark lower-right, gold tip), 5 px apart
local GEM = { ".G.", "LMD", "LMD", "LMD", "MDD", ".D." }
local map = { G = GOLD[2], L = JADE[5], M = JADE[4], D = JADE[2] }
for _, d in ipairs({ { 16, 16 }, { 21, 15 }, { 26, 15 }, { 31, 18 } }) do
  for r, row in ipairs(GEM) do for k = 1, 3 do
    local ch = row:sub(k, k)
    if map[ch] then O.dot(c, d[1] - 2 + k, d[2] + r - 1, map[ch]) end
  end end
  O.dot(c, d[1] - 1, d[2] + 1, JADE[6])
end
local body = c:ellipse(20, 25, 11, 4.5)
local bI, bT = O.shade(c, body, MAUV, { sphere = { 15, 21, 12 }, amb = .3, wrap = .4, rim = true, bounce = "#5a6a9a", bmax = 2, sep = MAUV[1] })
O.bumps(c, bI, bT, MAUV, 63, .88, 3)
for x = 12, 27, 3 do O.mark(c, { { x, 28 } }, SAND[3]) O.mark(c, { { x + 1, 28 } }, MAUV[2]) end
for _, L in ipairs({ { 11, 28 }, { 17, 29 }, { 24, 29 } }) do
  O.flat(c, c:rect(L[1], L[2], L[1] + 1, 31), MAUV[3], "leg")
  O.dots(c, { { L[1] - 1, 32 }, { L[1] + 2, 32 } }, HORN[3])
end
for _, h in ipairs({ { { 5, 13 }, { 5, 8 }, { 8, 12 } }, { { 8, 12 }, { 10, 6 }, { 12, 12 } }, { { 12, 13 }, { 15, 8 }, { 15, 14 } } }) do
  local hi, ht = O.shade(c, c:poly(h), HORN, { R = 1, amb = .35, wrap = .45, cuts = { .25, .5, .78 }, sep = HORN[1], rim = true })
  O.tex(c, hi, ht, HORN, function(x, y, i) if y % 3 == 1 then return -1 end end)
end
local head = c:ellipse(8.5, 18, 6, 5)
O.shade(c, head, MAUV, { sphere = { 6, 14, 8 }, amb = .35, wrap = .45, rim = true, bounce = "#5a6a9a", bmax = 2, sep = MAUV[1] })
local chin = c:ellipse(9, 21.5, 4.5, 1.5) chin:clip(head)
O.flat(c, chin, SAND[3], "chin")
O.dots(c, { { 6, 20 }, { 7, 21 }, { 8, 21 }, { 9, 21 }, { 10, 21 }, { 11, 20 }, { 12, 20 } }, P.ink)
c:eyeSmall(5, 15)
c:eyeSmall(11, 15)
O.dot(c, 4, 19, P.petal.base) O.dot(c, 14, 19, P.petal.base)

O.done(c, "pl-dlz-4-perch", function(c) c:sparkle(31, 9) end)
