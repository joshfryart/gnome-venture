-- npc-sorrel-inkcap portrait (npc2 P1_34) species: garden snail
-- 80x100 head-and-shoulders, eyes on stalks (locked eyes), button snout, quill in the teal headband, inky shell
-- behind the right shoulder dripping ink; dusk backdrop disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-sorrel-inkcap"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local SKIN = P.skinA
local SHELL = { hi = P.dusk.base, base = P.dusk.shade, shade = P.dusk.deep, deep = "#221a3e" }
local BAND = P.sea
local MUZ = { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }
local QUILL = { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }
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
local function spiral(cx, cy, turns, k)
  local pts = {}
  for i = 0, math.floor(turns * 24) do local t = i / 24 * 2 * math.pi local r = 0.6 + k * t
    pts[#pts + 1] = { math.floor(cx + math.cos(t) * r + .5), math.floor(cy + math.sin(t) * r * 0.9 + .5) } end
  return pts
end
-- shell + ink drip
local sh = c:ellipse(61, 66, 16, 15)
c:part(sh, SHELL, { band = 3, pop = { x = 52, y = 55 } })
c:fillMask(c:line(spiral(64, 67, 2.5, 1.7), 1):clip(sh:shrink(1)), SHELL.deep)
c:fillMask(c:rect(70, 79, 71, 84):add(c:ellipse(70.5, 86, 1.8, 1.8)), SHELL.shade) c:put(70, 85, SHELL.hi)
-- body + bib
local body = c:ellipse(39.5, 106, 29, 32):clip(c:rect(0, 70, 79, 99))
c:part(body, SKIN, { band = 3, pop = { x = 17, y = 86 } })
c:part(c:rrect(28, 79, 51, 99, 3), MUZ, { band = 2, nopop = true })
c:stitch{ { 30, 82 }, { 49, 82 } }
-- eye stalks behind the head
c:part(c:line({ { 33, 40 }, { 30, 28 }, { 28, 19 } }, 4), SKIN, { band = 1, nopop = true })
c:part(c:line({ { 46, 39 }, { 50, 26 }, { 52, 17 } }, 4), SKIN, { band = 1, nopop = true })
c:part(c:ellipse(28, 15, 6, 6), SKIN, { band = 2, pop = { x = 25, y = 11 } })
c:part(c:ellipse(52, 13, 6, 6), SKIN, { band = 2, pop = { x = 49, y = 9 } })
-- head
local head = c:ellipse(39.5, 53, 20, 17)
c:part(head, SKIN, { band = 3, pop = { x = 26, y = 42 } })
c:part(c:ellipse(39.5, 60, 11, 7), MUZ, { band = 2, nopop = true })
c:part(head:copy():clip(c:rect(0, 41, 79, 44)), BAND, { band = 1, pop = { x = 24, y = 41 } })
c:part(c:ellipse(59, 43, 2.5, 2.5), BAND, { band = 1, nopop = true })
c:part(c:line({ { 60, 45 }, { 64, 52 } }, 3), BAND, { band = 1, nopop = true })
-- quill tucked in the band
c:part(oval(15, 28, 12, 3.5, -110), QUILL, { band = 1, nopop = true })
c:fillMask(c:line({ { 22, 45 }, { 11, 16 } }, 1), QUILL.shade)
for _, q in ipairs{ { 12, 24 }, { 14, 30 }, { 17, 36 } } do c:put(q[1], q[2], QUILL.base) end
c:put(22, 45, SHELL.shade) c:put(21, 46, SHELL.shade)
-- face
c:eyeLocked(26, 13) c:eyeLocked(50, 11)
c:part(c:ellipse(39.5, 56.5, 3, 2), SKIN, { band = 1, nopop = true }) c:put(38, 55, SKIN.hi) c:put(39, 55, SKIN.hi)
c:paint({ "i.......i", ".iiiiiii.", "..iPPPi..", "...iii..." }, 35, 61, { i = "ink", P = "petal.base" })
c:paint({ "PPP", "PPP" }, 24, 59, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 53, 59, { P = "petal.base" })
c:finish{ outline = true }
backdrop(P.dusk)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
