-- npc-moss-petalwing portrait (npc2 P1_22) species: grasshopper
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

local NAME = "npc-moss-petalwing"
local GR, VEST, WING, BAND, WD = P.moss, P.ember, P.petal, P.dusk, P.wood
local FACE = { hi = "#e6f2a8", base = P.moss.hi, shade = "#9fcf68", deep = P.moss.shade }
local c = HP.canvas{ w = 80, h = 100, name = NAME }
for _, sg in ipairs{ -1, 1 } do
  local w = oval(39.5 + sg * 24, 70, 6.5, 15, sg * 30)
  c:part(w, WING, { band = 2, pop = { x = 39.5 + sg * 24 - 3, y = 60 } })
  c:fillMask(c:line({ { 39.5 + sg * 19, 82 }, { 39.5 + sg * 29, 58 } }, 1):clip(w:shrink(1)), WING.shade)
end
c:part(c:rect(32, 58, 47, 78), GR, { band = 2, nopop = true })
local body = c:ellipse(39.5, 104, 33, 29):clip(c:rect(0, 70, 79, 99))
c:part(body, VEST, { band = 3, pop = { x = 16, y = 82 } })
c:part(c:poly{ { 31, 75 }, { 48, 75 }, { 39.5, 92 } }, GR, { band = 1, nopop = true })
for _, y in ipairs{ 93, 97 } do c:paint({ "hg", "gs" }, 39, y, { h = "gold.hi", g = "gold.base", s = "gold.shade" }) end
pts(c, { { 30, 76 }, { 30, 77 }, { 31, 78 }, { 49, 76 }, { 49, 77 }, { 48, 78 } }, VEST.deep)
-- head
local head = c:ellipse(39.5, 44, 20, 17)
c:part(head, GR, { band = 3, sep = true, pop = { x = 29, y = 31 } })
pts(c, { { 31, 30 }, { 32, 30 }, { 33, 29 }, { 34, 29 }, { 27, 32 } }, GR.hi)
c:part(c:rect(0, 34, 79, 37):clip(head), BAND, { band = 1, inner = false, pop = { x = 24, y = 34 } })
c:part(c:poly{ { 56, 33 }, { 64, 30 }, { 66, 38 }, { 59, 37 } }, BAND, { band = 1, sep = true, nopop = true })
c:part(c:poly{ { 58, 37 }, { 63, 40 }, { 62, 45 }, { 58, 41 } }, BAND, { band = 1, sep = true, nopop = true })
for _, sg in ipairs{ -1, 1 } do c:part(c:ellipse(39.5 + sg * 18.5, 45, 5.5, 5.5), GR, { band = 2, nopop = true, sep = true }) end
c:eyeLocked(19, 43) c:eyeLocked(56, 43)
c:part(c:ellipse(39.5, 52, 8, 6), FACE, { band = 2, sep = true, pop = { x = 35, y = 48 } })
pts(c, { { 39, 51 }, { 40, 51 }, { 39, 52 } }, FACE.deep)
c:paint({ "i......i", ".iiiiii.", "..iPPi.." }, 36, 56, { i = "ink", P = "petal.base" })
pts(c, { { 33, 59 }, { 34, 60 }, { 46, 59 }, { 45, 60 } }, GR.deep)
c:cheek(27, 53) c:cheek(51, 53)
c:part(c:ellipse(26, 9, 2.5, 2.5), BAND, { band = 1, pop = { x = 25, y = 8 } })
c:part(c:ellipse(55, 7, 2.5, 2.5), BAND, { band = 1, pop = { x = 54, y = 6 } })
-- fiddle on the shoulder, bow across
local fid = oval(63, 86, 5, 8, 20)
c:part(fid, WD, { band = 2, pop = { x = 61, y = 80 } })
pts(c, { { 61, 85 }, { 61, 86 }, { 65, 87 }, { 65, 88 } }, WD.deep)
c:part(c:line({ { 61, 79 }, { 56, 67 } }, 2), { hi = WD.shade, base = WD.shade, shade = WD.deep, deep = WD.deep }, { nopop = true, sep = true })
c:part(c:ellipse(55.5, 66, 1.5, 1.5), WD, { band = 1, nopop = true, sep = true })
c:part(c:line({ { 50, 97 }, { 76, 76 } }, 1), P.stone, { nopop = true, noshade = true, sep = true })
c:part(c:ellipse(59, 76, 3, 2.5), GR, { band = 1, sep = true, nopop = true })
c:finish{ outline = true }
c:fillMask(c:line({ { 33, 30 }, { 29, 18 }, { 26, 11 } }, 1), P.ink)
c:fillMask(c:line({ { 45, 30 }, { 50, 18 }, { 55, 9 } }, 1), P.ink)
backdrop(c, P.sky)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
