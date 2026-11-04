-- npc-moss-petalwing sprite (npc2 P1_22) species: grasshopper
-- Petalwing: cheerful moss grasshopper fiddler; pink petal wings, purple headband, red vest. prop: fiddle + bow.
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
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, s, tw = p.b or 0, p.s or 0, p.tw or 0
  c:groundShadow(32, 89.5, 13, 3)
  for _, sg in ipairs{ -1, 1 } do -- petal wings folded up behind
    local w = oval(32 + sg * 14, 67 + b + s, 4, 10, sg * 25)
    c:part(w, WING, { band = 1, pop = { x = 32 + sg * 14 - 1, y = 60 + b + s } })
    c:fillMask(c:line({ { 32 + sg * 12, 74 + b + s }, { 32 + sg * 16, 60 + b + s } }, 1):clip(w:shrink(1)), WING.shade)
  end
  for _, sg in ipairs{ -1, 1 } do c:part(oval(32 + sg * 9, 81 + b, 3, 6, sg * -20), GR, { band = 1, nopop = true }) end -- jumping thighs
  for _, x in ipairs{ 27, 37 } do local f = c:ellipse(x, 88, 3.5, 2) c:part(f, GR, { band = 1, nopop = true, sep = true }) under(c, f, GR.deep) end
  local v = c:ellipse(32, 77 + b, 10, 8.5)
  c:part(v, VEST, { band = 2, pop = { x = 25, y = 72 + b } })
  c:part(c:poly{ { 29, 69 + b }, { 35, 69 + b }, { 32, 76 + b } }, GR, { band = 1, nopop = true })
  under(c, v, VEST.deep)
  for _, y in ipairs{ 77, 81 } do c:paint({ "hg", "gs" }, 31, y + b, { h = "gold.hi", g = "gold.base", s = "gold.shade" }) end
  -- fiddle held upright at the left, bow in the right hand
  c:part(oval(21, 81 + b, 3, 4.5, -15), WD, { band = 1, pop = { x = 20, y = 78 + b } })
  keep(c, 21, 81 + b, WD.deep) keep(c, 21, 82 + b, WD.deep)
  c:part(c:line({ { 22, 76 + b }, { 24, 69 + b } }, 2), { hi = WD.shade, base = WD.shade, shade = WD.deep, deep = WD.deep }, { nopop = true, sep = true })
  c:part(c:ellipse(23, 74 + b, 2, 2), GR, { band = 1, nopop = true, sep = true })
  c:part(c:line({ { 40, 70 + b }, { 46, 84 + b } }, 1), P.stone, { nopop = true, noshade = true })
  c:part(c:ellipse(42, 76 + b, 2, 2), GR, { band = 1, nopop = true, sep = true })
  -- head
  local hy = 52 + b
  local head = c:ellipse(32, hy, 14, 12.5)
  c:part(head, GR, { band = 2, sep = true, pop = { x = 24, y = hy - 9 } })
  pts(c, { { 27, hy - 11 }, { 28, hy - 11 }, { 29, hy - 12 }, { 30, hy - 12 }, { 25, hy - 10 } }, GR.hi)
  c:part(c:rect(0, hy - 8, 63, hy - 6):clip(head), BAND, { band = 1, inner = false, pop = { x = 22, y = hy - 8 } })
  c:part(c:poly{ { 44, hy - 8 }, { 50, hy - 10 }, { 51, hy - 4 }, { 46, hy - 5 } }, BAND, { band = 1, nopop = true, sep = true })
  for _, sg in ipairs{ -1, 1 } do c:part(c:ellipse(32 + sg * 13, hy + 1, 4.5, 4.5), GR, { band = 1, nopop = true, sep = true }) end
  if p.blink then
    for _, x in ipairs{ 17, 43 } do c:paint({ ".sss.", "sssss", "iiiii" }, x, hy - 1, { s = "moss.shade", i = "ink" }) end
  else c:eyeLocked(17, hy - 1) c:eyeLocked(43, hy - 1) end
  c:part(c:ellipse(32, hy + 6, 5, 3.5), FACE, { band = 1, sep = true, pop = { x = 29, y = hy + 4 } })
  pts(c, { { 32, hy + 5 }, { 32, hy + 6 } }, FACE.deep)
  c:paint({ "i.....i", ".iiiii." }, 29, hy + 9, { i = "ink" })
  c:cheek(23, hy + 6) c:cheek(40, hy + 6)
  c:part(c:ellipse(23, 18 + b + s, 2, 2), BAND, { band = 1, pop = { x = 22, y = 17 + b + s } })
  c:part(c:ellipse(42 + tw, 18 + b + s - tw, 2, 2), BAND, { band = 1, pop = { x = 41 + tw, y = 17 + b + s - tw } })
  c:finish{ outline = true }
  c:fillMask(c:line({ { 28, hy - 11 }, { 25, hy - 20 }, { 23, 20 + b + s } }, 1), P.ink)
  c:fillMask(c:line({ { 36, hy - 11 }, { 39, hy - 20 }, { 42 + tw, 20 + b + s - tw } }, 1), P.ink)
  HP.assertClean(c)
  return c
end
local IDLE = { { b = 0 }, { b = 1, s = 1 }, { b = 0 }, { b = 0, tw = 1 } }
local frames = {}
for _, p in ipairs(IDLE) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")

