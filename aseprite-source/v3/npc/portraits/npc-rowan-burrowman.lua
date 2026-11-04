-- npc-rowan-burrowman portrait (npc2 P1_32) species: ant
-- Rowan Burrowman: gentle digger ant, teal stitched hood with elbowed antennae through grommets, cream bib,
-- lower arm pair clasped on the bib, spade over the shoulder. Gold disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-rowan-burrowman"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local ANT, DARK, HANDLE, HOOD = P.wood, P.skinC, P.skinB, P.sea
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local PLATE = { hi = P.wood.hi, base = P.wood.hi, shade = P.wood.base, deep = P.wood.shade }
local SOCK = { hi = P.stone.base, base = P.stone.shade, shade = P.stone.deep, deep = "#2e2f45" }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- spade over the right shoulder
c:part(c:line({ { 53, 99 }, { 66, 40 } }, 3), HANDLE, { band = 1, nopop = true })
c:part(c:rect(63, 36, 68, 41), SOCK, { band = 1, nopop = true })
local bl = c:rrect(60, 19, 73, 36, 4) bl:add(c:poly{ { 61, 22 }, { 72, 22 }, { 66.5, 13 } })
c:part(bl, P.stone, { band = 2, pop = { x = 63, y = 20 } })
c:put(66, 30, P.stone.shade) c:put(66, 31, P.stone.shade) c:put(66, 32, P.stone.shade)
-- cloak + bib
c:part(c:ellipse(39.5, 108, 32, 32):clip(c:rect(0, 72, 79, 99)), HOOD, { band = 3 })
c:part(c:poly{ { 31, 76 }, { 48, 76 }, { 46, 99 }, { 33, 99 } }, CR, { band = 1, nopop = true })
c:part(c:poly{ { 30, 75 }, { 38, 75 }, { 34, 81 } }, CR, { band = 1, nopop = true })
c:part(c:poly{ { 41, 75 }, { 49, 75 }, { 45, 81 } }, CR, { band = 1, nopop = true })
c:paint({ "hg", "gs" }, 39, 86, { h = "gold.hi", g = "gold.base", s = "gold.shade" })
-- lower arm pair clasped on the bib (quirk)
c:part(c:ellipse(36.5, 93, 3, 2), ANT, { band = 1, nopop = true })
c:part(c:ellipse(42.5, 93, 3, 2), ANT, { band = 1, nopop = true })
-- hand on the handle
c:part(c:ellipse(57, 80, 3.5, 3), ANT, { band = 1, pop = { x = 55, y = 78 } })
-- hood + stitch
local hood = c:ellipse(39.5, 50, 25, 26) hood:add(c:ellipse(39.5, 74, 26, 7))
c:part(hood, HOOD, { band = 3, pop = { x = 21, y = 38 } })
local pts = {}
for a = 195, 345, 10 do local r = math.rad(a) pts[#pts + 1] = { math.floor(39.5 + 23 * math.cos(r) + .5), math.floor(53 + 21.5 * math.sin(r) + .5) } end
c:stitch(pts)
-- round ant head
c:part(c:ellipse(39.5, 53, 20, 18), ANT, { band = 3, pop = { x = 27, y = 40 } })
for _, ex in ipairs{ 29, 46 } do
  local ring = c:rrect(ex - 1, 46, ex + 5, 52, 2)
  c:fillMask(ring, ANT.deep)
  c:eyeLocked(ex, 47)
end
c:part(c:poly{ { 35, 56 }, { 44, 56 }, { 43, 61 }, { 36, 61 } }, PLATE, { band = 1, nopop = true })
c:put(37, 57, P.cream)
c:paint({ "dd...", ".dd..", "..d.." }, 32, 62, { d = "wood.deep" })
c:paint({ "...dd", "..dd.", "..d.." }, 43, 62, { d = "wood.deep" })
c:paint({ "i....i", ".iiii." }, 37, 63, { i = "ink" })
c:paint({ "PPP", "PPP" }, 25, 57, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 52, 57, { P = "petal.base" })
-- antenna knobs
c:part(c:ellipse(22, 11, 2.5, 2.5), DARK, { band = 1, pop = { x = 21, y = 10 } })
c:part(c:ellipse(57, 11, 2.5, 2.5), DARK, { band = 1, pop = { x = 56, y = 10 } })
c:finish{ outline = true }
c:fillMask(c:line({ { 32, 30 }, { 29, 21 }, { 23, 14 } }, 1), P.ink)
c:fillMask(c:line({ { 47, 30 }, { 50, 21 }, { 56, 14 } }, 1), P.ink)
for _, q in ipairs{ { 31, 30 }, { 33, 30 }, { 46, 30 }, { 48, 30 } } do c:put(q[1], q[2], P.gold.base) end
backdrop(P.gold)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
