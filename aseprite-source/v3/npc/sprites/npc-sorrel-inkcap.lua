-- npc-sorrel-inkcap sprite (npc2 P1_34) species: garden snail
-- Sorrel Inkcap, the village scribe-snail: inky indigo spiral shell, teal headband with a quill tucked in, cream bib.
-- quirk: the shell drips a bead of ink. 64x96 cell, feet baseline y=90, idle(4).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-sorrel-inkcap"
local SKIN = P.skinA
local SHELL = { hi = P.dusk.base, base = P.dusk.shade, shade = P.dusk.deep, deep = "#221a3e" }
local BAND = P.sea
local MUZ = { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }
local QUILL = { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }
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
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 16, 3)
  -- shell on the back, peeking out up-right
  local sh = c:ellipse(45.5, 57 + b, 14, 13)
  c:part(sh, SHELL, { band = 2, pop = { x = 39, y = 47 + b } })
  c:fillMask(c:line(spiral(49, 58 + b, 2.25, 1.55), 1):clip(sh:shrink(1)), SHELL.deep)
  -- ink drip (quirk)
  local dr = c:rect(55, 68 + b, 56, 71 + b + (p.drip or 0)):add(c:ellipse(55.5, 72.5 + b + (p.drip or 0), 1.5, 1.5))
  c:fillMask(dr, SHELL.shade) c:put(55, 72 + b + (p.drip or 0), SHELL.hi)
  -- snail foot (never moves)
  local foot = c:ellipse(32, 86.5, 14, 3.5)
  c:part(foot, SKIN, { band = 1, nopop = true })
  for x = 20, 44, 3 do c:put(x, 89, SKIN.shade) end
  -- body column + bib
  c:part(c:rrect(21, 51 + b, 43, 85, 6), SKIN, { band = 2, pop = { x = 23, y = 62 + b } })
  c:part(c:rrect(26, 63 + b, 38, 84, 3), MUZ, { band = 1, nopop = true })
  c:stitch{ { 27, 66 + b }, { 37, 66 + b } }
  c:part(c:ellipse(20, 69 + b, 3, 4.5), SKIN, { band = 1, nopop = true })
  c:part(c:ellipse(44, 69 + b, 3, 4.5), SKIN, { band = 1, nopop = true })
  -- eye stalks (behind the head)
  local s = p.st or 0
  local lx, ly = 22 + (p.lx or 0), 11 + b + s
  local rx, ry = 41 + (p.rx or 0), 10 + b + s
  c:part(c:line({ { 27, 32 + b }, { 24, 22 + b }, { lx, ly } }, 3), SKIN, { band = 1, nopop = true })
  c:part(c:line({ { 37, 31 + b }, { 39, 20 + b }, { rx, ry } }, 3), SKIN, { band = 1, nopop = true })
  c:part(c:ellipse(lx, ly, 4, 4), SKIN, { band = 1, nopop = true })
  c:part(c:ellipse(rx, ry, 4, 4), SKIN, { band = 1, nopop = true })
  -- head
  local head = c:ellipse(31.5, 41 + b, 15, 13)
  c:part(head, SKIN, { band = 2, pop = { x = 22, y = 33 + b } })
  c:part(c:ellipse(31.5, 47 + b, 8, 5), MUZ, { band = 1, nopop = true })
  c:part(head:copy():clip(c:rect(0, 32 + b, 63, 34 + b)), BAND, { band = 1, nopop = true })
  c:part(c:ellipse(46, 33 + b, 2, 2), BAND, { band = 1, nopop = true })
  c:part(c:line({ { 47, 35 + b }, { 49 + (p.tail or 0), 39 + b } }, 2), BAND, { band = 1, nopop = true })
  -- quill tucked in the headband
  local qx = p.qx or 0
  c:part(oval(15 + qx, 23 + b, 8, 2.5, -110), QUILL, { band = 1, nopop = true })
  c:fillMask(c:line({ { 19, 35 + b }, { 13 + qx, 16 + b } }, 1), QUILL.shade)
  c:put(19, 35 + b, SHELL.shade) c:put(19, 36 + b, SHELL.shade)
  -- face
  if p.blink then
    for i = -2, 2 do c:put(lx + i, ly, P.ink) c:put(rx + i, ry, P.ink) end
  else c:eyeLocked(lx - 2, ly - 2) c:eyeLocked(rx - 2, ry - 2) end
  c:put(31, 44 + b, SKIN.shade) c:put(32, 44 + b, SKIN.shade) c:put(31, 43 + b, SKIN.hi)
  c:paint({ "i...i", ".iii." }, 29, 47 + b, { i = "ink" })
  c:cheek(23, 46 + b) c:cheek(39, 46 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { { bob = 0 }, { bob = 1, st = 1, qx = 1, tail = 1, drip = 1 }, { bob = 0 }, { bob = 0, blink = true, rx = 1 } }
local frames = {}
for _, p in ipairs(F) do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
