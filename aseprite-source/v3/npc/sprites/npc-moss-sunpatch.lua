-- npc-moss-sunpatch sprite (npc2 P1_22) species: field mouse
-- Sunpatch: sleepy, sun-loving field mouse in a floppy purple hat with a sun charm, oat smock. prop: sunflower.
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
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, s, tt = p.b or 0, p.s or 0, p.tt or 0
  c:groundShadow(32, 89.5, 13, 3)
  c:part(c:line({ { 26, 84 + b }, { 16, 86 }, { 10, 81 }, { 11 - tt, 75 + s } }, 2), PINK, { band = 1, nopop = true }) -- tail curls left
  for _, x in ipairs{ 26.5, 37.5 } do local f = c:ellipse(x, 88, 4, 2) c:part(f, PINK, { band = 1, nopop = true, sep = true }) under(c, f, PINK.deep) end
  local sm = c:ellipse(32, 78 + b, 11, 8.5)
  sm:add(c:rect(23, 78 + b, 41, 85))
  c:part(sm, SMOCK, { band = 2, pop = { x = 25, y = 72 + b } })
  under(c, sm, SMOCK.deep)
  for _, y in ipairs{ 73, 77, 81 } do c:paint({ "hg" }, 31, y + b, { h = "gold.hi", g = "gold.base" }) end
  c:part(c:ellipse(21, 77 + b, 2.5, 3.5), SMOCK, { band = 1, nopop = true, sep = true })
  c:part(c:ellipse(21, 81 + b, 2, 1.5), PINK, { band = 1, nopop = true, sep = true })
  -- sunflower: stem in the right paw, head nods on settle
  c:part(c:line({ { 49, 86 }, { 49, 64 + b } }, 2), P.moss, { nopop = true })
  c:part(oval(51, 74 + b, 3, 1.5, -30), P.moss, { band = 1, nopop = true, sep = true })
  local fy = 63 + b + s
  local fl = c:ellipse(51, fy, 5.5, 5.5)
  for i = 0, 7 do local a = math.rad(i * 45) fl:add(c:ellipse(51 + math.cos(a) * 5.5, fy + math.sin(a) * 5.5, 1.5, 1.5)) end
  c:part(fl, GO, { band = 1, pop = { x = 47, y = fy - 5 } })
  c:part(c:ellipse(51, fy, 2.5, 2.5), FUR, { band = 1, pop = { x = 50, y = fy - 1 } })
  pts(c, { { 50, fy + 1 }, { 52, fy } }, FUR.deep)
  c:part(c:ellipse(44, 79 + b, 2.5, 3.5), SMOCK, { band = 1, nopop = true, sep = true })
  c:part(c:ellipse(47, 79 + b, 2, 2), PINK, { band = 1, nopop = true, sep = true })
  -- ears, head, muzzle
  local hy = 55 + b
  for _, sg in ipairs{ -1, 1 } do
    local ex, ey = 32 + sg * 14, hy - 9 + s
    c:part(c:ellipse(ex, ey, 6, 6), FUR, { band = 1, nopop = true, sep = true })
    c:part(c:ellipse(ex + (sg < 0 and 0 or 0), ey, 3.5, 3.5), PINK, { band = 1, sep = true, pop = { x = ex - 2, y = ey - 2 } })
  end
  c:part(c:ellipse(32, hy, 14, 11), FUR, { band = 2, sep = true, pop = { x = 24, y = hy - 7 } })
  c:part(c:ellipse(32, hy + 5, 6.5, 4), MUZ, { band = 1, sep = true, pop = { x = 28, y = hy + 2 } })
  c:paint({ "hP.", "PPP", ".s." }, 31, hy + 2, { h = "petal.hi", P = "petal.base", s = "petal.shade" })
  c:paint({ "i.i.i", ".i.i." }, 30, hy + 6, { i = "ink" })
  pts(c, { { 24, hy + 4 }, { 23, hy + 4 }, { 22, hy + 3 }, { 24, hy + 6 }, { 23, hy + 6 }, { 22, hy + 7 },
           { 40, hy + 4 }, { 41, hy + 4 }, { 42, hy + 3 }, { 40, hy + 6 }, { 41, hy + 6 }, { 42, hy + 7 } }, FUR.deep)
  if p.blink then
    for _, x in ipairs{ 23, 36 } do c:paint({ "fffff", "fffff", "iiiii" }, x, hy - 4, { f = "wood.shade", i = "ink" }) end
  else c:eyeLocked(23, hy - 5) c:eyeLocked(36, hy - 5) end
  c:cheek(21, hy + 1) c:cheek(41, hy + 1)
  -- floppy purple hat: narrow brim, cone, tip flopped forward-left, gold sun charm
  local hm = c:ellipse(32, hy - 9, 11.5, 2.5)
  hm:add(c:poly{ { 23, hy - 9 }, { 41, hy - 9 }, { 36, hy - 22 }, { 29, hy - 22 } })
  hm:add(c:line({ { 32, hy - 21 }, { 29, hy - 28 }, { 24, hy - 30 + s } }, 4))
  hm:add(c:line({ { 24, hy - 30 + s }, { 20, hy - 27 + s } }, 3))
  c:part(hm, HAT, { band = 2, sep = true, pop = { x = 27, y = hy - 18 } })
  under(c, hm, HAT.deep)
  for x = 23, 41 do if hm:has(x, hy - 11) and (x % 3 ~= 2) then keep(c, x, hy - 11, GO.base) end end
  pts(c, { { 30, hy - 23 }, { 31, hy - 23 }, { 33, hy - 15 }, { 34, hy - 16 } }, HAT.deep)
  c:part(c:ellipse(19, hy - 25 + s, 2, 2), GO, { band = 1, sep = true, pop = { x = 18, y = hy - 26 + s } })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local IDLE = { { b = 0 }, { b = 1, s = 1 }, { b = 0 }, { b = 0, blink = true, tt = 1 } }
local frames = {}
for _, p in ipairs(IDLE) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")

