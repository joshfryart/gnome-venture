-- npc-woad portrait (npc2 P1_38) species: moth
-- Same design as the sprite: fuzzy moth dyer, lilac eye-spot wings, feathery antennae, berry beret, green smock,
-- red scarf, curled proboscis nose. Prop: clay pot of woad-blue dye, indigo-stained fingertips. Backdrop: sea disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-woad"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local MOTH = { hi = "#f3e3d0", base = "#d9c2b0", shade = "#a68fa0", deep = "#6b5470" }
local BERET = { hi = P.petal.base, base = P.petal.shade, shade = P.petal.deep, deep = "#4e1c40" }
local INDIGO = { hi = "#7d9cf0", base = "#4a5ac8", shade = "#33388f", deep = "#22235a" }
local WLOW = { hi = P.dusk.base, base = P.dusk.shade, shade = P.dusk.deep, deep = "#241a45" }
local FEA = { hi = P.gold.hi, base = "#d9b070", shade = "#a6806a", deep = MOTH.deep }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function feather(x0, y0, x1, y1, Lmax)
  local m = c:line({ { x0, y0 }, { x1, y1 } }, 1)
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  local len = math.sqrt((x1 - x0) ^ 2 + (y1 - y0) ^ 2)
  local px, py = -(y1 - y0) / len, (x1 - x0) / len
  for i = 3, n, 2 do
    local t = i / n
    local x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
    local L = math.max(1, math.floor(Lmax * math.sin(math.pi * math.min(t, 0.9)) + 0.5))
    for s = 1, L do
      m:set(math.floor(x + px * s + .5), math.floor(y + py * s + .5))
      m:set(math.floor(x - px * s + .5), math.floor(y - py * s + .5))
    end
  end
  return m
end
-- wings
for _, s in ipairs({ -1, 1 }) do
  local lo = oval(39.5 + s * 22, 75, 8, 7, s * 15)
  local up = oval(39.5 + s * 25, 50, 12, 14, s * -20)
  c:part(lo, WLOW, { band = 1, nopop = true })
  c:part(up, P.dusk, { band = 2, nopop = true })
  c:fillMask(c:line({ { 39.5 + s * 15, 60 }, { 39.5 + s * 29, 42 } }, 1):clip(up:shrink(1)), P.dusk.shade)
  c:fillMask(c:line({ { 39.5 + s * 15, 62 }, { 39.5 + s * 33, 56 } }, 1):clip(up:shrink(1)), P.dusk.shade)
  up:edge():each(function(x, y) if not up:has(x, y - 1) then c:put(x, y, P.dusk.hi) end end)
  local sx = math.floor(39.5 + s * 27)
  c:fillMask(HP.ellipse(sx, 46, 2.5, 2.5), P.cream)
  c:fillMask(c:rect(sx, 46, sx + 1, 47), P.ink)
end
-- antennae
c:part(feather(32, 34, 22, 6, 2), FEA, { band = 1, nopop = true })
c:part(feather(47, 34, 57, 6, 2), FEA, { band = 1, nopop = true })
-- smock
local body = c:ellipse(39.5, 110, 33, 32):clip(c:rect(0, 74, 79, 99))
c:part(body, P.moss, { band = 3 })
c:fillMask(c:line({ { 34, 78 }, { 39, 86 }, { 45, 78 } }, 1):clip(body), P.moss.deep)
-- head
local head = c:ellipse(39.5, 52, 20, 17)
for _, ang in ipairs({ 5, 25, 50, 75, 105, 130, 155, 175 }) do
  local r = math.rad(ang)
  head:add(HP.ellipse(39.5 + math.cos(r) * 19.5, 52 + math.sin(r) * 16.5, 2, 2))
end
c:part(head, MOTH, { band = 3, pop = { 26, 44 } })
for _, q in ipairs({ { 24, 60 }, { 28, 64 }, { 51, 63 }, { 55, 59 }, { 34, 66 }, { 45, 66 } }) do
  c:put(q[1], q[2], MOTH.shade) c:put(q[1], q[2] + 1, MOTH.shade)
end
-- scarf
local sc = c:ellipse(39.5, 73, 16, 3.5)
c:part(sc, P.ember, { band = 1 })
c:part(c:ellipse(47, 78, 3, 2.5), P.ember, { band = 1, sep = true, nopop = true })
c:part(c:line({ { 47, 81 }, { 50, 93 } }, 4), P.ember, { band = 2, sep = true, nopop = true })
-- dye pot
local pot = c:rrect(8, 84, 30, 99, 5)
c:part(pot, P.wood, { band = 3 })
c:fillMask(c:rect(9, 92, 29, 92):clip(pot:shrink(1)), P.gold.shade)
c:part(c:ellipse(19, 84, 11.5, 2.5), P.wood, { band = 1, sep = true, nopop = true })
c:part(c:ellipse(19, 84, 9, 1.2), INDIGO, { band = 1, inner = false, pop = { 13, 84 } })
c:part(c:line({ { 12, 87 }, { 12, 90 } }, 2), INDIGO, { band = 1, inner = false, nopop = true })
c:put(12, 91, INDIGO.shade)
-- paw on the rim, dyed fingertips
c:part(c:ellipse(30, 84, 3.5, 3), MOTH, { band = 1, nopop = true })
c:put(27, 86, INDIGO.base) c:put(29, 87, INDIGO.base) c:put(31, 87, INDIGO.base) c:put(27, 85, INDIGO.shade)
-- beret
local ber = c:ellipse(36, 38, 21, 5):add(c:ellipse(37, 34, 17, 6)):add(c:rect(36, 26, 38, 28))
c:part(ber, BERET, { band = 2, pop = { 27, 31 } })
ber:each(function(x, y) if not ber:has(x, y + 1) then c:put(x, y, BERET.deep) end end)
-- face
c:eyeLocked(28, 48) c:eyeLocked(46, 48)
c:paint({ ".GGGG.", "G....G", "G.GG.G", "G..GG.", ".G...." }, 37, 54, { G = "gold.shade" })
c:put(38, 54, P.gold.hi) c:put(39, 54, P.gold.hi)
c:paint({ "i....i", ".iiii." }, 37, 60, { i = "ink" })
c:paint({ "PPP", "PPP" }, 23, 57, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 57, { P = "petal.base" })
c:finish{ outline = true }
backdrop(P.sea)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
