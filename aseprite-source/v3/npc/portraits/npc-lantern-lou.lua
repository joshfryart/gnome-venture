-- npc-lantern-lou portrait (npc2 P1_18) species: rosy lantern moth
-- 80x100 head and shoulders, sky backdrop. Feathery antennae through a wide sea-blue knob hat, dark eye mask,
-- fuzzy snout with curled proboscis, cream ruff, tan eyespot wings; brass lantern glowing in both hands.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-lantern-lou"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local FUR = { hi = P.dusk.hi, base = P.dusk.base, shade = P.dusk.shade, deep = P.dusk.deep }
local FACE = { hi = P.cream, base = "#e6d4f2", shade = P.dusk.hi, deep = P.dusk.base }
local RUFF = { hi = P.cream, base = "#f3e6c8", shade = "#d2bccf", deep = P.dusk.shade }
local WING = { hi = "#f2ddb0", base = "#d9b582", shade = "#a7808a", deep = "#6b4a6a" }
local HAT, GLD, WOOD = P.sea, P.gold, P.wood
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg) local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function feather(pts, dir)
  local m = c:line(pts, 1) local add = HP.mask()
  m:each(function(x, y) if y % 2 == 0 then add:set(x + dir, y) add:set(x + 2 * dir, y - 1) end end)
  c:part(m:add(add), WING, { noshade = true, nopop = true })
end
-- wings
for _, s in ipairs{ -1, 1 } do
  local up = oval(39.5 + s * 23, 68, 16, 8, s * -50)
  c:part(up, WING, { band = 2 })
  c:part(c:ellipse(39.5 + s * 27, 64, 3, 3), GLD, { band = 1, nopop = true })
  c:fillMask(c:ellipse(39.5 + s * 27, 64, 1, 1), FUR.deep)
  c:fillMask(c:line({ { 39.5 + s * 14, 76 }, { 39.5 + s * 30, 58 } }, 1):clip(up:shrink(2)), WING.shade)
  c:part(oval(39.5 + s * 26, 88, 9, 6, s * 20), WING, { band = 2, nopop = true })
end
-- body + fuzz
local body = c:ellipse(39.5, 108, 29, 27)
for _, q in ipairs{ { 12, 92 }, { 14, 86 }, { 67, 92 }, { 65, 86 } } do body:add(c:ellipse(q[1], q[2], 2, 2)) end
body:clip(c:rect(0, 0, 79, 99))
c:part(body, FUR, { band = 3 })
for y = 86, 98, 4 do for x = 14 + (y % 8) // 2, 66, 6 do if body:has(x, y) then c:px(x, y, FUR.hi) c:px(x, y + 1, FUR.hi) end end end
-- ruff
local ruff = c:ellipse(39.5, 78, 20, 4)
for x = 21, 58, 5 do ruff:add(c:ellipse(x, 81.5, 2.5, 2.5)) end
c:part(ruff, RUFF, { band = 2 })
-- lantern
c:part(c:line({ { 32, 82 }, { 35, 78 }, { 44, 78 }, { 47, 82 } }, 1), WOOD, { noshade = true, nopop = true })
c:part(c:rrect(30, 82, 49, 85, 2), WOOD, { band = 1 })
c:part(c:rrect(31, 86, 48, 99, 3), GLD, { band = 2, nopop = true })
c:fillMask(c:rrect(34, 88, 45, 99, 2), GLD.hi)
c:fillMask(c:ellipse(39.5, 93, 2.5, 3.5), P.ember.hi)
c:fillMask(c:ellipse(39.5, 93.5, 1, 2), P.cream)
for y = 87, 99 do c:px(36, y, WOOD.shade) c:px(43, y, WOOD.shade) end
c:px(32, 88, P.cream) c:px(32, 89, P.cream) c:px(32, 90, P.cream)
for _, hx in ipairs{ 28, 51 } do c:part(c:ellipse(hx, 88, 3.5, 3.5), FUR, { band = 1 }) end
-- antennae (behind hat)
feather({ { 30, 34 }, { 23, 24 }, { 15, 15 } }, -1)
feather({ { 49, 34 }, { 56, 24 }, { 64, 15 } }, 1)
-- head
local head = c:ellipse(39.5, 55, 20, 16)
for _, q in ipairs{ { 19.5, 58 }, { 20.5, 63 }, { 59.5, 58 }, { 58.5, 63 }, { 30, 70 }, { 39.5, 71 }, { 49, 70 } } do head:add(c:ellipse(q[1], q[2], 1.8, 1.8)) end
c:part(head, FACE, { band = 3 })
c:part(c:ellipse(31, 50, 5.5, 4.5), FUR, { band = 1, nopop = true }) c:part(c:ellipse(48, 50, 5.5, 4.5), FUR, { band = 1, nopop = true })
c:eyeLocked(29, 48) c:eyeLocked(46, 48)
c:part(c:ellipse(39.5, 58, 3.5, 2.5), RUFF, { band = 1, pop = { x = 37, y = 57 } })
c:paint({ "ppp", "..p", "p.p", "pp." }, 38, 61, { p = GLD.deep })
c:paint({ "i...", ".ii." }, 31, 62, { i = "ink" }) c:paint({ "...i", ".ii." }, 45, 62, { i = "ink" })
c:paint({ "PPP", "PPP" }, 23, 57, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 57, { P = "petal.base" })
-- wide hat
local hat = c:ellipse(39.5, 38, 26, 5.5)
hat:add(c:poly{ { 20, 38 }, { 59, 38 }, { 39.5, 22 } })
c:part(hat, HAT, { band = 2, pop = { x = 30, y = 30 } })
c:fillMask(c:line({ { 15, 40 }, { 64, 40 } }, 1):clip(hat:shrink(1)), HAT.shade)
c:stitch{ { 21, 38 }, { 58, 38 } }
c:part(c:ellipse(39.5, 21, 2.6, 2.6), GLD, { band = 1, pop = { x = 38, y = 20 } })
c:finish{ outline = true }
backdrop(P.sky)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
