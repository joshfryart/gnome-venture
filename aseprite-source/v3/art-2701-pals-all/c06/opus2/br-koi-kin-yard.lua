-- Koi Kin (br-koi-kin), yard sprite 64x64. Opus second pass (art-2701-pals-all/c06/opus2), built on the Haiku pass.
-- Common, seedkeeper. "Swims round the koi pond with a great many cousins, all orange."
-- An orange koi pal rising out of a round stone-rimmed pond to face us: cream head patch, scale rows, a
-- dorsal fin, side fins, whisker barbels and a round koi mouth, its tail flicking up out of the water behind.
-- Under the water a ring of small orange cousins swims round the pond.
-- Fixes vs Haiku: the pond is a bounded oval with a stone rim (was a full-width band), the koi faces us
-- with a clear face (was a side-on red fish), cousins are true fish shapes (were blobs).
-- quirk: one cousin has popped its head up beside the pal and is blowing a bubble.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("br-koi-kin-yard", 64)

local KOI  = { "#5a1c1a", "#8e2e1c", "#c4501e", "#ec7a2a", "#f8a44a", "#ffd08a" }
local CRM  = { "#c49a86", "#e6c8b0", "#f8e6d2", "#fff6ea" }
local FIN  = { "#8e2e1c", "#d0602a", "#f49a5a", "#ffc89a", "#ffe6cc" }
local STON = { "#3a3446", "#58526a", "#7c7890", "#a4a2b4", "#c8c8d2" }
local WAT  = { "#14364a", "#1c4e62", "#24687a", "#358a94", "#5aaeac", "#9cd6cc" }
local SUB  = { "#9a4a2a", "#c86a32" } -- cousins seen through water
local BNC  = "#3a7a8a"

-- pond: stone rim, then water
local rim = c:ellipse(32, 50, 29, 10)
local sb = {} rim:each(function(x, y) if O.H(x, y, 3) > .7 then sb[K(x, y)] = -1 end if (x * 3 + y) % 7 == 0 then sb[K(x, y)] = 1 end end)
O.shade(c, rim, STON, { R = 2, amb = .28, wrap = .4, bias = sb, rim = true, cuts = { .25, .45, .65, .85 } })
local water = c:ellipse(32, 50, 25.5, 7.5)
local wb = {} water:each(function(x, y) wb[K(x, y)] = -1 end)
O.shade(c, water, WAT, { R = 4, amb = .3, wrap = .4, bias = wb, sep = STON[1] })
-- cousins swimming round the pond, under the water (flat, no outline: they sit inside the water)
local function cousin(x, y, dir, big)
  local L = big and 5 or 4
  for i = 0, L - 1 do
    c:put(x + i * dir, y, SUB[2]) c:put(x + i * dir, y + 1, SUB[1])
    if big and i >= 1 and i <= 3 then c:put(x + i * dir, y - 1, SUB[2]) end
  end
  c:put(x + L * dir, y, SUB[1]) c:put(x + (L + 1) * dir, y - 1, SUB[2]) c:put(x + (L + 1) * dir, y + 1, SUB[2])
  c:put(x, y, "#f0a060") c:put(x + dir, y, "#f0a060")
  for i = 0, L do c:put(x + i * dir, y + 2, WAT[1]) end -- their shadow on the pond floor
end
cousin(9, 50, 1, true) cousin(20, 54, 1, false) cousin(33, 55, 1, true) cousin(46, 53, 1, false) cousin(56, 49, -1, false) cousin(27, 50, -1, false)

-- tail fan flicking up out of the water at the right
local tail = c:poly{ { 47, 41 }, { 53, 33 }, { 59, 25 }, { 57, 33 }, { 62, 32 }, { 54, 42 } }
local tb = {} tail:each(function(x, y) if (x - y) % 3 == 0 then tb[K(x, y)] = 1 end end)
O.shade(c, tail, FIN, { R = 2, amb = .3, wrap = .45, bias = tb, sep = FIN[1], cuts = { .25, .45, .65, .85 } })

-- dorsal fin along the back
local dor = c:poly{ { 22, 31 }, { 30, 25 }, { 40, 26 }, { 44, 33 } }
local db = {} dor:each(function(x, y) if x % 3 == 0 then db[K(x, y)] = -1 end end)
O.shade(c, dor, FIN, { R = 1, amb = .35, wrap = .45, bias = db, sep = FIN[1], cuts = { .25, .45, .65, .85 } })

-- body: swimming at the surface, head to the left turned to us, lower body under the waterline
local body = c:ellipse(30, 39, 18, 9)
body:add(c:ellipse(46, 40, 6, 4.5))
body:cut(c:rect(0, 46, 63, 63))
local bI, bT = O.shade(c, body, KOI, { sphere = { 24, 33, 20 }, amb = .26, wrap = .35, sep = KOI[1], rim = true, bounce = BNC, bmax = 2 })
-- scale rows: small arcs on the back half only
O.tex(c, bI, bT, KOI, function(x, y, i) if x >= 34 and y <= 42 and ((x + (y % 2) * 2) % 4 == 0) and y % 2 == 0 and i >= 4 then return -1 end end)
-- cream kohaku patches
local patch = c:ellipse(39, 34, 5, 3)
patch:add(c:ellipse(28, 31, 3, 1.5))
patch:clip(body)
O.shade(c, patch, CRM, { sphere = { 36, 32, 8 }, amb = .4, wrap = .45, cuts = { .3, .55, .8 } })
-- side fin
O.shade(c, c:poly{ { 30, 42 }, { 25, 47 }, { 31, 46 }, { 34, 43 } }, FIN, { R = 1, amb = .35, wrap = .45, sep = FIN[1], cuts = { .25, .45, .65, .85 } })
-- water line ripples where it breaks the surface
for _, p in ipairs({ { 11, 46 }, { 12, 46 }, { 13, 47 }, { 48, 46 }, { 49, 46 }, { 50, 47 }, { 20, 47 }, { 21, 47 }, { 38, 47 }, { 39, 47 } }) do
  c.pix[p[2] * c.w + p[1]] = WAT[6]
end

-- face on the head, turned to us
c:eyeLocked(14, 34)
c:eyeLocked(24, 34)
-- round koi mouth + barbels at the front
O.dots(c, { { 13, 41 }, { 14, 41 }, { 12, 42 }, { 15, 42 }, { 13, 43 }, { 14, 43 } }, P.ink)
O.dots(c, { { 13, 42 }, { 14, 42 } }, "#7a2a30")
O.dots(c, { { 11, 43 }, { 10, 44 }, { 16, 43 }, { 17, 44 } }, KOI[2])
c:cheek(19, 41) c:cheek(29, 40)

-- quirk: a cousin pops its head up, blowing a bubble
O.shade(c, c:ellipse(53, 47, 2.5, 2), KOI, { sphere = { 52, 46, 3 }, amb = .35, sep = KOI[1] })
O.dot(c, 52, 46, P.ink)

O.shift(c, 0, -11)
O.done(c, "br-koi-kin-yard", function(c)
  for _, p in ipairs({ { 56, 32 }, { 57, 31 }, { 58, 32 }, { 57, 33 }, { 59, 28 } }) do
    if not c.pix[p[2] * c.w + p[1]] then c:put(p[1], p[2], WAT[6]) end
  end
end)
