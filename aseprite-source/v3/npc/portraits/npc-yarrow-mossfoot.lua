-- npc-yarrow-mossfoot portrait (npc2 P1_39) species: frog (green tree frog)
-- Same design as the sprite: cheerful herbalist frog, gold-ringed bulging eyes, wide smile, pink smock with V collar,
-- floppy brown hat between the eye bumps, moss on the shoulder; holds a flowering yarrow stalk. Backdrop: gold disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-yarrow-mossfoot"
local FR = { hi = "#cfe38c", base = "#8fbf5a", shade = "#4f8a5e", deep = "#2f5452" }
local BELLY = { hi = "#fff1c2", base = "#ecd99a", shade = "#bfae8e", deep = "#7e7486" }
local STEM = { hi = P.moss.hi, base = P.moss.shade, shade = P.moss.deep, deep = "#1f3a3a" }
local UMB = { hi = P.cream, base = "#f1e6cf", shade = "#cdb8c8", deep = "#8f7a9a" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function eye(x, y)
  for j = 0, 4 do for i = 0, 4 do if not ((i == 0 or i == 4) and (j == 0 or j == 4)) then keep(x + i, y + j, P.cream) end end end
  for j = 1, 3 do for i = 1, 3 do keep(x + i, y + j, P.ink) end end
  keep(x + 1, y + 1, P.cream)
end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- shoulders: pink smock, V collar, stitched edge, moss patch
local body = c:ellipse(39.5, 99, 32, 31):clip(c:rect(0, 0, 79, 99))
c:part(body, P.petal, { band = 2, pop = { 14, 82 } })
c:part(c:poly{ { 31, 66 }, { 48, 66 }, { 39.5, 84 } }, BELLY, { band = 1, nopop = true })
for _, q in ipairs{ { 31, 70 }, { 32, 73 }, { 34, 76 }, { 36, 79 }, { 43, 79 }, { 45, 76 }, { 47, 73 }, { 48, 70 } } do keep(q[1], q[2], P.gold.base) end
local mo = c:ellipse(20, 74, 5, 2.5)
c:part(mo, P.moss, { band = 1, pop = { 17, 73 } })
keep(16, 72, P.moss.base) keep(20, 72, P.moss.hi) keep(23, 73, P.moss.shade)
-- yarrow stalk, feathery leaves, umbel
c:part(c:line({ { 66, 99 }, { 66, 24 } }, 2), STEM, { noshade = true, nopop = true })
for _, l in ipairs{ { 67, 70, 73, 65 }, { 65, 62, 60, 58 }, { 67, 52, 72, 48 }, { 65, 44, 61, 41 }, { 67, 36, 71, 33 } } do
  local m = c:line({ { l[1], l[2] }, { l[3], l[4] } }, 1)
  local sx = l[3] > l[1] and 1 or -1
  m:add(c:rect(math.floor((l[1] + l[3]) / 2), math.floor((l[2] + l[4]) / 2) - 2, math.floor((l[1] + l[3]) / 2), math.floor((l[2] + l[4]) / 2) - 1))
  c:part(m, STEM, { noshade = true, nopop = true })
end
local um = c:ellipse(66.5, 21, 9, 3.5)
for _, q in ipairs{ { 58.5, 20, 2.5 }, { 62, 17, 2.5 }, { 67, 16, 2.5 }, { 72, 17, 2.5 }, { 75, 20, 2 } } do um:add(c:ellipse(q[1], q[2], q[3], q[3])) end
c:part(um, UMB, { band = 2, pop = { 60, 17 } })
for _, q in ipairs{ { 59, 20 }, { 62, 18 }, { 65, 20 }, { 67, 17 }, { 70, 19 }, { 72, 17 }, { 74, 21 }, { 68, 22 }, { 63, 22 } } do keep(q[1], q[2], P.gold.hi) end
local hand = c:ellipse(64.5, 86, 5, 4)
c:part(hand, FR, { band = 2, pop = { 61, 83 } })
keep(63, 88, FR.deep) keep(66, 88, FR.deep)
-- wide frog head, cream throat, spots, snout, smile
local head = c:ellipse(39.5, 52, 21, 14)
c:part(head, FR, { band = 3, pop = { 23, 44 } })
c:part(c:ellipse(39.5, 64, 13, 4):clip(head), BELLY, { band = 1, inner = false, nopop = true })
for _, q in ipairs{ { 30, 43 }, { 48, 42 }, { 39, 40 }, { 56, 48 }, { 22, 49 } } do
  keep(q[1], q[2], FR.shade) keep(q[1] + 1, q[2], FR.shade) keep(q[1], q[2] + 1, FR.shade) keep(q[1] + 1, q[2] + 1, FR.shade)
end
for x = 37, 42 do keep(x, 48, FR.hi) end
keep(36, 49, FR.hi) keep(43, 49, FR.hi)
keep(37, 50, FR.deep) keep(42, 50, FR.deep)
for x = 23, 56 do keep(x, 58 - math.floor(((x - 39.5) / 16.5) ^ 2 * 3 + 0.5), P.ink) end
for _, q in ipairs{ { 21, 54 }, { 22, 54 }, { 57, 54 }, { 58, 54 }, { 22, 55 }, { 57, 55 } } do keep(q[1], q[2], P.petal.base) end
-- floppy hat between the eye bumps
local hm = c:ellipse(39.5, 32, 11, 2.5)
hm:add(c:poly{ { 32, 32 }, { 47, 32 }, { 44, 18 }, { 36, 20 } })
hm:add(c:line({ { 40, 20 }, { 44, 14 }, { 49, 14 }, { 51, 17 } }, 3))
c:part(hm, P.wood, { band = 3, pop = { 36, 23 } })
c:part(c:rect(32, 28, 47, 30):clip(hm), P.gold, { band = 1, sep = true, pop = { 34, 28 } })
for x = 31, 47, 3 do keep(x, 33, P.wood.deep) end
-- bulging eye bumps with gold rings
for _, ex in ipairs{ 26.5, 52.5 } do
  c:part(c:ellipse(ex, 38, 7, 6.5), FR, { band = 2, pop = { math.floor(ex) - 4, 33 } })
  c:part(c:ellipse(ex, 38.5, 4.5, 4.5), P.gold, { band = 1, nopop = true })
  eye(math.floor(ex) - 2, 36)
end
c:finish{ outline = true }
backdrop(P.gold)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
