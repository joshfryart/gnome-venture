-- npc-auntie-saffira portrait (npc2 P1_1) species: cat
-- Same cat as the sprite: blue-grey tabby, saffron hood with tasselled tip, teal cloak, cat-icon brass lantern.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-auntie-saffira"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local FUR, HOOD, CLOAK = P.stone, P.gold, P.sea
local MUZ = { hi = P.cream, base = "#f3e6c8", shade = "#cfc3d0", deep = P.stone.base }
local GLOW = { hi = P.cream, base = P.gold.hi, shade = P.gold.base, deep = P.gold.shade }
local DISC = { base = "#c9b2f0", shade = "#a58ee0", deep = "#8a6fd0" }
local function under(m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], hex, c.own[q[2] * c.w + q[1]]) end end
local function recol(m, hex) m:each(function(x, y) if c:get(x, y) then c:put(x, y, hex, c.own[y * c.w + x]) end end) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- hood tip + tassel (behind)
c:part(c:line({ { 54, 26 }, { 63, 21 }, { 69, 24 }, { 71, 30 } }, 5), HOOD, { band = 2 })
c:part(c:ellipse(71.5, 34, 2.5, 2.5), P.ember, { band = 1, pop = { x = 70, y = 33 } })
-- cloak
local body = c:ellipse(39.5, 110, 34, 32):clip(c:rect(0, 74, 79, 99))
c:part(body, CLOAK, { band = 3, pop = { x = 14, y = 86 } })
recol(c:line({ { 22, 84 }, { 19, 99 } }, 1):clip(body:shrink(1)), CLOAK.shade)
recol(c:line({ { 58, 84 }, { 61, 99 } }, 1):clip(body:shrink(1)), CLOAK.deep)
recol(c:rect(40, 80, 40, 99), CLOAK.deep)
c:stitch{ { 38, 82 }, { 38, 99 } }
-- hood cowl
local hood = c:ellipse(39.5, 42, 25, 24)
hood:add(c:ellipse(39.5, 72, 25, 8))
c:part(hood, HOOD, { band = 3, pop = { x = 22, y = 28 } }) under(hood, HOOD.deep)
recol(c:line({ { 18, 66 }, { 26, 77 } }, 1):clip(hood:shrink(1)), HOOD.shade)
recol(c:line({ { 61, 66 }, { 53, 77 } }, 1):clip(hood:shrink(1)), HOOD.deep)
-- ears through the hood
local eL = c:poly{ { 19, 32 }, { 21, 8 }, { 35, 22 } }
local eR = c:poly{ { 44, 22 }, { 58, 8 }, { 60, 32 } }
c:part(eL, FUR, { band = 2, pop = { x = 21, y = 14 } }) c:part(eR, FUR, { band = 2 })
c:part(c:poly{ { 23, 28 }, { 23, 14 }, { 31, 22 } }, P.petal, { band = 1, nopop = true, inner = false })
c:part(c:poly{ { 48, 22 }, { 56, 14 }, { 56, 28 } }, P.petal, { band = 1, nopop = true, inner = false })
-- face
local face = c:ellipse(39.5, 50, 19.5, 15)
c:part(face, FUR, { band = 3, pop = { x = 25, y = 40 } })
face:grow(1):cut(face):clip(hood):each(function(x, y) c:put(x, y, y < 52 and HOOD.hi or HOOD.shade, c.own[y * 80 + x]) end)
for _, l in ipairs({ { { 39, 36 }, { 39, 40 } }, { { 35, 37 }, { 34, 40 } }, { { 44, 37 }, { 45, 40 } },
  { { 21, 50 }, { 25, 51 } }, { { 21, 53 }, { 24, 53 } }, { { 58, 50 }, { 54, 51 } }, { { 58, 53 }, { 55, 53 } } }) do
  recol(c:line(l, 1):clip(face:shrink(1)), FUR.shade)
end
local mz = c:ellipse(39.5, 58, 7.5, 4.5):clip(face)
c:part(mz, MUZ, { band = 2, nopop = true, inner = false })
c:eyeLocked(28, 45) c:eyeLocked(47, 45)
for i = 1, 3 do c:put(28 + i, 44, P.ink) c:put(47 + i, 44, P.ink) end
c:put(27, 44, P.ink) c:put(52, 44, P.ink)
c:paint({ "hPPP", "PPPS", ".PS." }, 38, 54, { h = "petal.hi", P = "petal.base", S = "petal.shade" })
c:paint({ "...ii...", "i.i..i.i", ".i....i." }, 36, 57, { i = "ink" })
c:paint({ "PPP", "PPP" }, 23, 57, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 57, { P = "petal.base" })
for _, l in ipairs({ { { 31, 58 }, { 22, 56 } }, { { 31, 60 }, { 22, 61 } }, { { 48, 58 }, { 57, 56 } }, { { 48, 60 }, { 57, 61 } } }) do
  c:line(l, 1):each(function(x, y) c:put(x, y, FUR.deep, c.own[y * 80 + x]) end)
end
c:part(c:ellipse(39.5, 78, 2.5, 1.5), P.ember, { band = 1 })
-- lantern with cat icon, held by the left paw
c:part(c:poly{ { 10, 87 }, { 28, 87 }, { 24, 82 }, { 14, 82 } }, P.wood, { band = 1 })
local gl = c:rrect(11, 87, 27, 97, 1)
c:part(gl, GLOW, { band = 2, pop = { x = 13, y = 89 } })
for y = 87, 97 do c:put(11, y, P.wood.shade) c:put(27, y, P.wood.deep) end
c:paint({ "i.....i", "ii...ii", "iiiiiii", "iSiiiSi", "iiiiiii", ".iiiii." }, 16, 89, { i = "ink", S = "gold.hi" })
c:part(c:rect(10, 97, 28, 99), P.wood, { band = 1 })
c:part(c:ellipse(19, 80, 4, 3), FUR, { band = 1, pop = { x = 17, y = 78 } })
c:finish{ outline = true }
backdrop(DISC)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
