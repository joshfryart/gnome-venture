-- npc-kestrel-petalwing portrait (npc2 P1_18) species: honey bear cub
-- 80x100 head and shoulders, petal backdrop. Tulip-petal cap, round ears, cream muzzle, heart nose; petal pinwheel in paw.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-kestrel-petalwing"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local FUR = { hi = "#f6c77e", base = "#dc9a45", shade = "#a9643f", deep = "#5e3040" }
local MUZ = { hi = P.cream, base = "#f4d9ae", shade = "#d4a585", deep = "#93636a" }
local PET, GLD = P.petal, P.gold
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- shoulders + belly
local body = c:ellipse(39.5, 108, 31, 29):clip(c:rect(0, 0, 79, 99))
c:part(body, FUR, { band = 3 })
c:part(c:ellipse(39.5, 104, 12, 14):clip(c:rect(0, 0, 79, 99)), MUZ, { band = 2, nopop = true })
-- scalloped petal collar
local col = c:ellipse(39.5, 78, 19, 3.5)
for x = 22, 57, 5 do col:add(c:ellipse(x, 81, 2.5, 2.5)) end
c:part(col, PET, { band = 2 })
-- ears
for _, ex in ipairs{ 22, 57 } do
  c:part(c:ellipse(ex, 35, 7, 7), FUR, { band = 2, nopop = ex > 40 })
  c:part(c:ellipse(ex, 35.5, 3.5, 3.5), MUZ, { band = 1, nopop = true })
end
-- head with cheek fluff
local head = c:ellipse(39.5, 53, 20.5, 17.5)
for _, q in ipairs{ { 19.5, 58 }, { 20.5, 62 }, { 59.5, 58 }, { 58.5, 62 } } do head:add(c:ellipse(q[1], q[2], 1.6, 1.6)) end
c:part(head, FUR, { band = 3, pop = { x = 25, y = 42 } })
c:part(c:ellipse(39.5, 61, 10, 6.5), MUZ, { band = 2, pop = { x = 33, y = 56 } })
c:eyeLocked(28, 47) c:eyeLocked(47, 47)
c:paint({ "..ss...", "sssssss" }, 27, 44, { s = FUR.shade }) c:paint({ "...ss..", "sssssss" }, 46, 44, { s = FUR.shade })
-- heart nose
c:paint({ ".NN.NN.", "NhNNNNN", "NNNNNNN", ".NNNNN.", "..NNN.." }, 36, 55, { N = FUR.deep, h = MUZ.deep })
c:paint({ "i.....i", ".i.i.i.", "..i.i.." }, 36, 62, { i = "ink" })
c:paint({ "PPP", "PPP" }, 24, 59, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 53, 59, { P = "petal.base" })
c:px(24, 59, PET.hi) c:px(53, 59, PET.hi)
-- tulip-petal cap + stem leaf
local cap = c:ellipse(39.5, 35, 12, 4.5)
cap:add(c:poly{ { 27, 35 }, { 29, 21 }, { 36, 31 } })
cap:add(c:poly{ { 33, 33 }, { 39.5, 17 }, { 46, 33 } })
cap:add(c:poly{ { 43, 31 }, { 50, 21 }, { 52, 35 } })
c:part(cap, PET, { band = 2, pop = { x = 30, y = 27 } })
c:fillMask(c:line({ { 35, 37 }, { 34, 31 } }, 1), PET.shade) c:fillMask(c:line({ { 44, 37 }, { 45, 31 } }, 1), PET.shade)
c:fillMask(c:line({ { 29, 39 }, { 50, 39 } }, 1):clip(cap), PET.deep)
local stem = c:line({ { 39, 17 }, { 41, 12 } }, 2)
stem:add(c:ellipse(45, 12, 3.5, 1.6))
c:part(stem, P.moss, { band = 1 })
-- pinwheel in paw (front right)
c:part(c:line({ { 66, 96 }, { 66, 74 } }, 2), P.wood, { band = 1, nopop = true })
local cx, cy = 66, 70
for i = 0, 3 do
  local a = 0.4 + i * math.pi / 2
  local tip = { cx + math.cos(a) * 10, cy + math.sin(a) * 10 }
  local side = { cx + math.cos(a + 1.0) * 6, cy + math.sin(a + 1.0) * 6 }
  c:part(c:poly{ { cx, cy }, tip, side }, (i % 2 == 0) and PET or GLD, { band = 1, nopop = i > 1 })
end
c:part(c:ellipse(cx, cy, 1.6, 1.6), P.wood, { band = 1, pop = { x = cx - 1, y = cy - 1 } })
local paw = c:ellipse(65, 92, 5, 4) c:part(paw, FUR, { band = 2 })
c:paint({ "m.m.m" }, 63, 89, { m = MUZ.shade })
c:finish{ outline = true }
backdrop(PET)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
