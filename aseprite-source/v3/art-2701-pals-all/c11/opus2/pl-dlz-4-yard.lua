-- Diamond Spur (pl-dlz-4), yard sprite 64x64. Opus second pass (c11/opus2), built on c11/haiku.
-- Thornblade, uncommon, Dragonlizard Den. "Four diamond bumps off the lizard's back, very proud of their pattern."
-- haiku drew a brown bean with four gold blobs on top. Now a horned lizard: wide, flat, dusty-rose body with a fringe
-- of little side spines, a crown of horns behind the head, short stubby tail, chin lifted proudly.
-- quirk: four tall gold-rimmed jade diamonds standing up in a row along its back, each with a lit facet.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-dlz-4-yard", 64)

local MAUV = { "#3a1e34", "#5e2e4a", "#8a4660", "#b26a78", "#d6949a", "#f0c0b4" }
local SAND = { "#8a5a4a", "#c08a6a", "#e8bc92", "#f8dcb4" }
local JADE = { "#123a3a", "#1a5a52", "#24806a", "#3cac82", "#76d49a", "#c0f0c0" }
local GOLD = { "#7a4a1a", "#b8782a", "#f2b23c", "#ffe08a" }
local HORN = { "#5a3a30", "#9a6a4a", "#d0a070", "#f2d4a4" }

c:groundShadow(33, 57, 24, 2.5)

-- stubby tail
local tail, tn = O.tube({ { 46, 46 }, { 52, 47 }, { 56, 50 }, { 59, 53 } }, function(t) return 3.6 * (1 - .8 * t) + .3 end)
local tI, tT = O.shadeN(c, tail, tn, MAUV, { amb = .25, wrap = .4, rim = true, bounce = "#5a6a9a", bmax = 2 })
-- back legs
for _, L in ipairs({ { 44, 48, 47, 54 }, { 22, 48, 19, 54 } }) do
  local m, n = O.tube({ { L[1], L[2] }, { L[1], L[2] + 3 }, { L[3], L[4] - 1 }, { L[3], L[4] } }, function(t) return 2.3 - .5 * t end)
  O.shadeN(c, m, n, MAUV, { amb = .25, wrap = .4, sep = MAUV[1] })
  O.flat(c, c:rect(L[3] - 2, L[4] + 1, L[3] + 2, L[4] + 1), MAUV[3], "foot")
  O.dots(c, { { L[3] - 2, L[4] + 2 }, { L[3], L[4] + 2 }, { L[3] + 2, L[4] + 2 } }, HORN[3])
end

-- quirk: four diamonds standing along the back (drawn before the body so the body overlaps their bases)
local dia = { { 28, 32, 4, 6 }, { 36, 30, 4, 7 }, { 44, 31, 4, 7 }, { 51, 35, 4, 6 } }
for _, d in ipairs(dia) do
  local m = c:poly{ { d[1], d[2] - d[4] }, { d[1] + d[3], d[2] }, { d[1], d[2] + d[4] }, { d[1] - d[3], d[2] } }
  -- gold rim
  O.flat(c, m, GOLD[2], "rim")
  local inner = m:shrink(1)
  local iI, iT = O.shade(c, inner, JADE, { R = 1, amb = .25, wrap = .4 })
  -- facets: upper-left facet lit, lower-right facet dark
  inner:each(function(x, y)
    local q = y * c.w + x
    if c.own[q] ~= iT then return end
    local u, v = (x - d[1]) / d[3], (y - d[2]) / d[4]
    if u <= 0 and v <= 0 then c.pix[q] = JADE[5] elseif u > 0 and v > 0 then c.pix[q] = JADE[2] elseif u > 0 then c.pix[q] = JADE[4] else c.pix[q] = JADE[3] end
  end)
  O.dots(c, { { d[1] - 1, d[2] - d[4] + 3 }, { d[1] - 2, d[2] - d[4] + 4 } }, JADE[6])
  O.dots(c, { { d[1], d[2] - d[4] }, { d[1] - d[3], d[2] } }, GOLD[4])
end

-- body: wide and flat
local body = c:ellipse(34, 44, 17, 8)
local bI, bT = O.shade(c, body, MAUV, { sphere = { 28, 37, 20 }, amb = .25, wrap = .4, rim = true, bounce = "#5a6a9a", bmax = 2, sep = MAUV[1] })
-- pebbly texture + a row of pale side spines
O.tex(c, bI, bT, MAUV, function(x, y, i) if (x * 5 + y * 3) % 7 == 0 and i >= 3 then return -1 end end)
for x = 20, 50, 3 do
  local y = 44 + math.floor(math.sqrt(math.max(0, 1 - ((x - 34) / 17) ^ 2)) * 6)
  O.mark(c, { { x, y - 1 } }, SAND[3]) O.mark(c, { { x, y - 2 } }, SAND[4])
end
-- belly stripe of sand
for x = 24, 44 do O.mark(c, { { x, 50 } }, SAND[2]) end
-- front legs
for _, L in ipairs({ { 22, 46, 18, 53 }, { 36, 48, 37, 54 } }) do
  local m, n = O.tube({ { L[1], L[2] }, { L[1], L[2] + 3 }, { L[3], L[4] - 1 }, { L[3], L[4] } }, function(t) return 2.4 - .5 * t end)
  O.shadeN(c, m, n, MAUV, { amb = .3, wrap = .45, sep = MAUV[1] })
  O.flat(c, c:rect(L[3] - 2, L[4] + 1, L[3] + 2, L[4] + 1), MAUV[4], "foot")
  O.dots(c, { { L[3] - 2, L[4] + 2 }, { L[3], L[4] + 2 }, { L[3] + 2, L[4] + 2 } }, HORN[3])
end

-- crown of horns behind the head
for _, h in ipairs({ { { 12, 24 }, { 14, 15 }, { 17, 23 } }, { { 17, 25 }, { 21, 17 }, { 22, 27 } }, { { 7, 26 }, { 7, 18 }, { 11, 24 } } }) do
  O.shade(c, c:poly(h), HORN, { R = 1, amb = .3, wrap = .45, cuts = { .25, .5, .78 }, sep = HORN[1] })
end
-- head, chin up
local head = c:ellipse(14, 33, 10, 8)
local hI, hT = O.shade(c, head, MAUV, { sphere = { 10, 27, 13 }, amb = .3, wrap = .4, rim = true, bounce = "#5a6a9a", bmax = 2, sep = MAUV[1] })
-- pale chin, lifted
local chin = c:ellipse(14, 38.5, 7, 2.5) chin:clip(head)
O.shade(c, chin, SAND, { R = 1, amb = .35, wrap = .45, cuts = { .25, .5, .78 }, sep = MAUV[2] })
-- smug closed smile, curling up at one end
O.dots(c, { { 9, 36 }, { 10, 37 }, { 11, 37 }, { 12, 37 }, { 13, 37 }, { 14, 37 }, { 15, 37 }, { 16, 37 }, { 17, 36 }, { 18, 35 } }, P.ink)
O.dots(c, { { 12, 33 }, { 16, 33 } }, MAUV[1])
c:eyeLocked(6, 27)
c:eyeLocked(16, 27)
c:cheek(5, 33) c:cheek(20, 33)

O.done(c, "pl-dlz-4-yard", function(c)
  c:sparkle(57, 22)
end)
