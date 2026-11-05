-- npc-juniper-kettleby portrait (npc2 P1_17) species: hedgehog
-- Same design as the sprite: spine crown, cream face with long snout and dark nose, mustard tunic with a
-- cream neckerchief, copper kettle held up in frame. Backdrop: lavender disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-juniper-kettleby"
local SPINE = { hi = "#b98a5e", base = "#7a4f36", shade = "#57364a", deep = "#3a2638" }
local FACE = { hi = "#fff0d4", base = "#f3d6aa", shade = "#c99e8c", deep = "#8a6470" }
local SNOUT = { hi = FACE.hi, base = FACE.base, shade = FACE.shade, deep = FACE.deep }
local KER = { hi = FACE.hi, base = FACE.base, shade = FACE.shade, deep = FACE.deep }
local PAW = { hi = "#b07c5c", base = "#865640", shade = "#5c3a48", deep = "#3a2638" }
local COP = { hi = "#ffc48e", base = "#dc7c46", shade = "#a64c4c", deep = "#5e2c40" }
local NOSE = { hi = "#8a6470", base = "#4a2f3c", shade = "#3a2638", deep = "#3a2638" }
local BG = { base = P.dusk.hi, shade = P.dusk.base, deep = P.dusk.shade }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade:lower() then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function spikes(m, cx, cy, rx, ry, a0, a1, n, len, w)
  for i = 0, n - 1 do
    local a = math.rad(a0 + (a1 - a0) * i / math.max(1, n - 1))
    local ex, ey = cx + math.cos(a) * (rx - 1), cy + math.sin(a) * (ry - 1)
    local tx, ty = cx + math.cos(a) * (rx + len), cy + math.sin(a) * (ry + len)
    local px, py = -math.sin(a) * w, math.cos(a) * w
    m:add(HP.poly{ { ex + px, ey + py }, { tx, ty }, { ex - px, ey - py } })
  end
  return m
end
-- shoulder spines + tunic
local man = c:ellipse(39.5, 80, 19, 6)
spikes(man, 39.5, 80, 19, 6, 160, 200, 3, 4, 2.5) spikes(man, 39.5, 80, 19, 6, -20, 20, 3, 4, 2.5)
c:part(man, SPINE, { band = 2, nopop = true })
local tun = c:ellipse(39.5, 108, 30, 27):clip(c:rect(0, 0, 79, 99))
c:part(tun, P.gold, { band = 3, pop = { x = 18, y = 88 } })
c:part(HP.poly{ { 29, 79 }, { 50, 79 }, { 39.5, 91 } }, KER, { band = 2, nopop = true })
c:part(c:ellipse(39.5, 80, 3, 2), KER, { band = 1, sep = true })
for _, y in ipairs{ 93, 97 } do c:paint({ "hb", "bd" }, 39, y, { h = "gold.hi", b = "wood.base", d = "wood.deep" }) end
-- head: spine crown
local dome = c:ellipse(39.5, 46, 20, 18)
spikes(dome, 39.5, 46, 20, 18, 150, 390, 15, 5, 3)
c:part(dome, SPINE, { band = 3, pop = { x = 27, y = 33 } })
for i = 0, 13 do
  local a = math.rad(170 + i * 15)
  for f = 0.55, 1.15, 0.1 do
    local x, y = math.floor(39.5 + math.cos(a) * 20 * f + .5), math.floor(46 + math.sin(a) * 18 * f + .5)
    local v = c:get(x, y)
    if v == SPINE.base then keep(x, y, SPINE.shade) elseif v == SPINE.shade then keep(x, y, SPINE.deep) end
  end
  local x, y = math.floor(39.5 + math.cos(a) * 21 + .5), math.floor(46 + math.sin(a) * 19 + .5)
  if c:get(x, y) == SPINE.base and i < 7 then keep(x, y, SPINE.hi) end
end
for _, x in ipairs{ 19, 60 } do
  c:part(c:ellipse(x, 43, 3.5, 3.5), FACE, { band = 1, sep = true, nopop = true })
  c:paint({ "pp", "ps" }, x - 1, 43, { p = "petal.base", s = "petal.shade" })
end
local face = c:ellipse(39.5, 53, 14, 12):cut(HP.poly{ { 34, 40 }, { 39.5, 47 }, { 45, 40 } })
c:part(face, FACE, { band = 2, pop = { x = 29, y = 45 } })
c:part(c:ellipse(39.5, 58, 5.5, 4), SNOUT, { band = 1, nopop = true })
c:part(c:ellipse(39.5, 57, 2.5, 1.8), NOSE, { band = 1, pop = { x = 38, y = 56 } })
c:eyeLocked(29, 47) c:eyeLocked(46, 47)
c:paint({ "i....i", ".iiii." }, 37, 63, { i = "ink" })
c:paint({ "PPP" }, 26, 56, { P = "petal.base" }) c:paint({ "PPP" }, 51, 56, { P = "petal.base" })
-- copper kettle held up at the right
local ring = c:ellipse(62, 79, 7, 6):cut(c:ellipse(62, 79, 5, 4)):clip(c:rect(0, 0, 79, 80))
c:part(ring, COP, { band = 1, nopop = true })
c:part(c:line({ { 69, 88 }, { 73, 83 }, { 75, 79 } }, 3), COP, { band = 1, nopop = true })
c:part(c:ellipse(62, 88, 9, 7), COP, { band = 3, pop = { x = 56, y = 84 } })
c:part(c:ellipse(62, 82, 5.5, 1.5), COP, { band = 1, nopop = true, sep = true })
c:part(c:ellipse(62, 80, 1.5, 1.5), COP, { band = 1, sep = true })
for _, x in ipairs{ 56, 58 } do keep(x, 86, COP.hi) end
c:part(c:ellipse(56, 74, 3, 2.5), PAW, { band = 1 })
c:finish{ outline = true }
backdrop(BG)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
