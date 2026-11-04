-- npc-reed-hollowell portrait (npc2 P1_32) species: frog
-- Reed Hollowell: cheerful pond frog, amber hood, red smock, gold-ringed eyes on domes, cattail reed in hand. Petal disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-reed-hollowell"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local SKIN, HOOD, TUN = P.moss, P.gold, P.ember
local STALK = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = "#1d3a36" }
local CAT = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2420" }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- cattail reed
c:part(c:rect(63, 38, 64, 99), STALK, { band = 1, nopop = true })
c:part(c:line({ { 65, 66 }, { 70, 58 }, { 73, 50 } }, 1), STALK, { band = 1, nopop = true })
c:part(c:rrect(61, 20, 66, 39, 2), CAT, { band = 2, pop = { x = 62, y = 23, horizontal = false } })
c:part(c:rect(63, 15, 64, 19), STALK, { noshade = true, nopop = true })
-- red smock
c:part(c:ellipse(39.5, 106, 31, 31):clip(c:rect(0, 70, 79, 99)), TUN, { band = 3 })
c:paint({ "d.........d", ".d.......d.", "..d.....d..", "...d...d...", "....d.d....", ".....d....." }, 34, 81, { d = "ember.deep" })
c:paint({ "hg", "gs" }, 39, 90, { h = "gold.hi", g = "gold.base", s = "gold.shade" })
-- hood
local hood = c:ellipse(39.5, 51, 25, 24) hood:add(c:ellipse(39.5, 74, 25, 7))
c:part(hood, HOOD, { band = 3, pop = { x = 21, y = 40 } })
-- face
c:part(c:ellipse(39.5, 55, 19.5, 15), SKIN, { band = 3, pop = { x = 25, y = 46 } })
-- eye domes with gold irises
for _, ex in ipairs{ 29.5, 49.5 } do
  c:part(c:ellipse(ex, 33, 8, 7), SKIN, { band = 2, pop = { x = math.floor(ex) - 5, y = 28 } })
  local x0 = math.floor(ex) - 2
  local ir = c:rrect(x0 - 1, 30, x0 + 5, 36, 2)
  c:fillMask(ir, P.gold.base)
  ir:each(function(x, y) if not ir:has(x + 1, y + 1) then c:put(x, y, P.gold.shade) end end)
  c:eyeLocked(x0, 31)
  for x = x0 - 1, x0 + 5 do c:put(x, 29, SKIN.shade) end
end
-- nose: raised snout with two nostrils
c:put(35, 49, SKIN.hi) c:put(36, 49, SKIN.hi) c:put(42, 49, SKIN.hi)
c:put(36, 51, P.ink) c:put(37, 51, P.ink) c:put(42, 51, P.ink) c:put(43, 51, P.ink)
-- wide smile
for x = 21, 58 do local t = (x - 39.5) / 18.5
  local y = math.floor(56 + 4 * (1 - t * t) + .5) c:put(x, y, P.ink)
  if math.abs(t) < .5 then c:put(x, y + 1, SKIN.shade) end end
c:put(20, 55, P.ink) c:put(59, 55, P.ink)
-- spots + cheeks
for _, q in ipairs{ { 24, 46 }, { 54, 45 }, { 28, 66 }, { 50, 67 }, { 39, 43 } } do c:fillMask(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), SKIN.shade) end
c:paint({ "PPP", "PPP" }, 23, 58, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 58, { P = "petal.base" })
-- hand on the reed
c:part(c:ellipse(62, 84, 4, 3.5), SKIN, { band = 1, pop = { x = 59, y = 82 } })
c:put(61, 85, SKIN.deep) c:put(63, 85, SKIN.deep)
c:finish{ outline = true }
backdrop(P.petal)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
