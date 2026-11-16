-- Shellstep (gc-shellstep), yard sprite 64x64. Opus second pass (art-2701-pals-all/c04/opus2), from the Haiku pass.
-- Rootwarden, uncommon, Great Canopy. "Takes a very slow walk to the stall and still arrives on time."
-- A forest tortoise mid-step, facing right: high amber dome with real scutes (seams, a lighter growth patch per
-- plate), a pale marginal rim, moss tufts on top (rootwarden), sage-green skin, stumpy legs, a round head big
-- enough for the locked eyes and a calm smile.
-- Fixed from Haiku: green lid + brown log body + gold disc did not read as one animal, the head was a tiny nub
-- with the face lost, and the speed lines said "fast". Now one tortoise silhouette with the face on a real head.
-- quirk: a gold pocket watch on a cord round its neck (always on time).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("gc-shellstep-yard", 64)

local SHELL = { "#3a2420", "#5e3a24", "#8a5a2a", "#b07e38", "#d4a852", "#ecd08a" }
local SKIN  = { "#2a3430", "#45564a", "#617a5e", "#83a072", "#a8c48e", "#d0e2b0" }
local GOLD  = { "#8a5a1a", "#c98a22", "#f0be38", "#fbe07a" }
local MOSS  = { "#1f4a3c", "#2f6b46", "#4a8f4e", "#72b35a", "#a2d070" }

c:groundShadow(31, 56, 25, 2.5)

-- legs (back pair first)
for _, L in ipairs({ { 21, 50, 3 }, { 35, 50, 3 } }) do
  O.shade(c, c:rrect(L[1] - L[3], L[2] - 6, L[1] + L[3], L[2] + 4, 2), SKIN, { R = 2, amb = .1, wrap = .3, sep = SKIN[1] })
end
for _, L in ipairs({ { 12, 50 }, { 41, 49 } }) do
  local leg = c:rrect(L[1] - 4, L[2] - 6, L[1] + 3, L[2] + 5, 2)
  local lI, lT = O.shade(c, leg, SKIN, { R = 2, amb = .2, wrap = .4, sep = SKIN[1], rim = true })
  O.tex(c, lI, lT, SKIN, function(x, y, i) if (x + y * 2) % 5 == 0 and i >= 3 then return -1 end end) -- scaly
  O.dots(c, { { L[1] - 3, L[2] + 5 }, { L[1] - 1, L[2] + 5 }, { L[1] + 1, L[2] + 5 } }, SKIN[6]) -- toenails
end

-- neck and head
local neck = O.tube({ { 38, 42 }, { 42, 41 }, { 44, 39 }, { 46, 37 } }, function() return 4 end)
O.shadeN(c, neck, (select(2, O.tube({ { 38, 42 }, { 42, 41 }, { 44, 39 }, { 46, 37 } }, function() return 4 end))), SKIN, { amb = .2, wrap = .4 })
local head = c:ellipse(48.5, 35, 9, 7.5)
local hI, hT = O.shade(c, head, SKIN, { sphere = { 45, 31, 12 }, amb = .2, wrap = .4, sep = SKIN[1], rim = true, bounce = "#5a7aa0", bmax = 2 })

-- shell dome
local shell = c:ellipse(25, 39, 21, 19)
shell:cut(c:rect(0, 45, 63, 63))
local sI, sT = O.shade(c, shell, SHELL, { sphere = { 20, 27, 28 }, amb = .22, wrap = .45, rim = true, bounce = "#6a5a8a", bmax = 2, sep = SHELL[1] })
-- scutes: voronoi plates with seams and a lighter growth patch
local seeds = { { 25, 25 }, { 14, 30 }, { 36, 30 }, { 25, 35 }, { 8, 39 }, { 42, 39 }, { 17, 41 }, { 33, 41 } }
shell:each(function(x, y)
  if y >= 42 then return end
  local d1, d2, best = 1e9, 1e9, nil
  for i, s in ipairs(seeds) do
    local d = math.sqrt((x - s[1]) ^ 2 + ((y - s[2]) * 1.2) ^ 2)
    if d < d1 then d2 = d1 d1 = d best = i elseif d < d2 then d2 = d end
  end
  local p = y * 64 + x
  if c.own[p] ~= sT then return end
  if d2 - d1 < 1.1 then c.pix[p] = SHELL[2]:lower()
  elseif d1 < 2.6 then
    local i = sI[K(x, y)] c.pix[p] = SHELL[math.min(6, i + 1)]:lower()
  end
end)
-- marginal rim band
local rim = c:ellipse(25, 42.5, 20.5, 3) rim:cut(c:rect(0, 46, 63, 63)) rim:clip(shell:copy():add(c:rect(5, 42, 45, 45)))
local rv = {}
rim:each(function(x, y) rv[K(x, y)] = .6 - (x - 25) * .012 end)
local rI, rT = X.tone(c, rim, rv, { SHELL[3], SHELL[4], SHELL[5], SHELL[6] }, { cuts = { .35, .5, .7 } })
for x = 6, 44, 4 do O.mark(c, { { x, 43 }, { x, 44 } }, SHELL[2]) end
for x = 6, 45 do if rim:has(x, 41) then O.mark(c, { { x, 41 } }, SHELL[1]) end end

-- moss tufts on top (rootwarden)
for _, m in ipairs({ { 20, 21, 3.5, 1.6 }, { 29, 20.5, 2.5, 1.4 } }) do
  O.shade(c, c:ellipse(m[1], m[2], m[3], m[4]), MOSS, { R = 1, amb = .3, wrap = .4, sep = MOSS[1] })
end
O.dots(c, { { 19, 19 }, { 22, 19 }, { 28, 19 } }, MOSS[5])

-- tail
O.flat(c, c:rect(4, 44, 5, 45), SKIN[3], "tail")

-- quirk: pocket watch on a cord
O.dots(c, { { 43, 41 }, { 44, 42 }, { 44, 43 } }, "#7a3a2a")
local watch = c:ellipse(45, 46.5, 3, 3)
O.shade(c, watch, GOLD, { sphere = { 44, 45, 4 }, amb = .35, wrap = .4, sep = GOLD[1], cuts = { .3, .55, .8 } })
O.flat(c, c:rect(44, 45, 46, 48), "#f8ecd0", "dial")
O.dots(c, { { 45, 45 }, { 45, 46 }, { 46, 46 } }, P.ink)
O.dot(c, 45, 43, GOLD[3])

-- face
c:eyeLocked(42, 31)
c:eyeLocked(50, 31)
c:cheek(40, 37) c:cheek(54, 37)
O.dots(c, { { 46, 38 }, { 47, 39 }, { 48, 39 }, { 49, 39 }, { 50, 38 } }, P.ink)
O.dots(c, { { 47, 34 }, { 49, 34 } }, SKIN[2])

O.shift(c, 1, -1)
O.done(c, "gc-shellstep-yard")
