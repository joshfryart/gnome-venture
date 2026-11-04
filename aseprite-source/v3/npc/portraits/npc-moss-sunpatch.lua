-- npc-moss-sunpatch portrait (npc2 P1_22) species: field mouse
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function keep(c, x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function pts(c, l, hex) for _, q in ipairs(l) do keep(c, q[1], q[2], hex) end end
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then keep(c, x, y, hex) end end) end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg) local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  local R = math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do for x = math.floor(cx - R), math.ceil(cx + R) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end

local NAME = "npc-moss-sunpatch"
local FUR, HAT, GO = P.wood, P.dusk, P.gold
local PINK = { hi = P.petal.hi, base = "#e8a0a8", shade = P.petal.shade, deep = P.petal.deep }
local SMOCK = { hi = "#ece0c4", base = "#c8b392", shade = "#8f7f8f", deep = "#5b4a63" }
local MUZ = { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }
local SUN = { base = "#f2cf6e", shade = "#d9a24a", deep = "#a86d3a" }
local c = HP.canvas{ w = 80, h = 100, name = NAME }
c:part(c:line({ { 18, 92 }, { 9, 86 }, { 8, 77 }, { 14, 73 } }, 2), PINK, { band = 1, nopop = true })
c:part(c:rect(33, 60, 46, 76), FUR, { band = 2, nopop = true })
local body = c:ellipse(39.5, 101, 32, 29):clip(c:rect(0, 72, 79, 99))
c:part(body, SMOCK, { band = 3, pop = { x = 16, y = 84 } })
c:part(c:ellipse(39.5, 74, 10, 3), SMOCK, { band = 1, sep = true, nopop = true })
for _, y in ipairs{ 81, 87, 93 } do c:paint({ "hg", "gs" }, 39, y, { h = "gold.hi", g = "gold.base", s = "gold.shade" }) end
-- ears
for _, sg in ipairs{ -1, 1 } do
  local ex = 39.5 + sg * 20
  c:part(c:ellipse(ex, 38, 8, 8), FUR, { band = 2, nopop = true, sep = true })
  c:part(c:ellipse(ex, 38, 5, 5), PINK, { band = 2, sep = true, pop = { x = ex - 3, y = 35 } })
end
local head = c:ellipse(39.5, 50, 19, 15.5)
c:part(head, FUR, { band = 3, sep = true, pop = { x = 27, y = 41 } })
c:part(c:ellipse(39.5, 57, 9, 6), MUZ, { band = 2, sep = true, pop = { x = 34, y = 52 } })
c:paint({ ".hPP.", "hPPPP", "PPPPs", ".sss." }, 37, 52, { h = "petal.hi", P = "petal.base", s = "petal.shade" })
c:paint({ "...i...", "i.i.i.i", ".i...i." }, 36, 56, { i = "ink" })
pts(c, { { 38, 59 }, { 41, 59 } }, P.petal.shade)
c:eyeLocked(29, 45) c:eyeLocked(46, 45)
c:cheek(26, 54) c:cheek(52, 54)
-- hat
local hm = c:ellipse(39.5, 35, 18, 3.5)
hm:add(c:poly{ { 26, 35 }, { 53, 35 }, { 46, 15 }, { 36, 15 } })
hm:add(c:line({ { 41, 16 }, { 37, 8 }, { 30, 5 } }, 5))
hm:add(c:line({ { 30, 5 }, { 25, 9 } }, 3))
c:part(hm, HAT, { band = 3, sep = true, pop = { x = 33, y = 22 } })
under(c, hm, HAT.deep)
for x = 26, 53 do if hm:has(x, 31) and (x % 3 ~= 2) then keep(c, x, 31, GO.base) end end
pts(c, { { 36, 14 }, { 37, 14 }, { 38, 13 }, { 44, 26 }, { 45, 25 } }, HAT.deep)
local charm = c:ellipse(23, 11, 2.5, 2.5)
for _, q in ipairs{ { 23, 7 }, { 19, 11 }, { 27, 11 }, { 23, 15 } } do charm:set(q[1], q[2]) end
c:part(charm, GO, { band = 1, sep = true, pop = { x = 22, y = 10 } })
-- sunflower
c:part(c:line({ { 70, 99 }, { 66, 68 } }, 2), P.moss, { nopop = true })
c:part(oval(72, 84, 4, 2, -30), P.moss, { band = 1, sep = true, pop = { x = 70, y = 83 } })
local fl = c:ellipse(66, 62, 6.5, 6.5)
for i = 0, 9 do local a = math.rad(i * 36) fl:add(c:ellipse(66 + math.cos(a) * 7, 62 + math.sin(a) * 7, 2, 2)) end
c:part(fl, GO, { band = 2, pop = { x = 60, y = 56 } })
c:part(c:ellipse(66, 62, 3.5, 3.5), FUR, { band = 1, sep = true, pop = { x = 64, y = 60 } })
pts(c, { { 65, 63 }, { 67, 62 }, { 66, 64 }, { 68, 64 } }, FUR.deep)
c:part(c:ellipse(66, 80, 3, 2.5), PINK, { band = 1, sep = true, nopop = true })
c:finish{ outline = true }
for _, sg in ipairs{ -1, 1 } do
  c:fillMask(c:line({ { 39.5 + sg * 19, 56 }, { 39.5 + sg * 26, 54 } }, 1), P.ink)
  c:fillMask(c:line({ { 39.5 + sg * 19, 59 }, { 39.5 + sg * 26, 61 } }, 1), P.ink)
end
backdrop(c, SUN)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
