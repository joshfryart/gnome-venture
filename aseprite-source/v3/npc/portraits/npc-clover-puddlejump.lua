-- npc-clover-puddlejump portrait (npc2 P1_6) species: seven-spot ladybird beetle
-- Same design as the sprite: red face + spotted elytra shoulders, gold vest, violet pronotum cap with cream
-- patches, green sweatband with knot tails, elbowed club antennae, violet mandible snout, cheek spots.
-- prop: four-leaf clover held up at the right with a dew drop. Sky (puddle) disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-clover-puddlejump"
local RED = P.ember
local CAP = { hi = "#8a6fd0", base = "#5a459e", shade = "#35295f", deep = "#2a1f45" }
local PAT = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local VEST, BAND, LEAF = P.gold, P.moss, P.moss
local SPOT = "#35295f"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- elytra shoulders + vest
local body = c:ellipse(39.5, 106, 33, 29):clip(c:rect(0, 0, 79, 99))
c:part(body, RED, { band = 3, pop = { x = 14, y = 87 } })
for _, s in ipairs{ {13, 92}, {21, 84}, {64, 92}, {57, 83}, {17, 98}, {62, 99} } do
  c:ellipse(s[1], s[2], 2.5, 2.5):clip(body:shrink(1)):each(function(x, y) c:put(x, y, SPOT, "s") end)
end
local vest = c:ellipse(39.5, 104, 12, 23):clip(body)
c:part(vest, VEST, { band = 2, pop = { x = 32, y = 86 } })
for y = 82, 99 do if vest:has(39, y) then c:put(39, y, VEST.shade) end end
c:button(42, 88) c:button(42, 95)
-- clover held up at the right
c:part(c:line({ {60, 86}, {62, 76}, {64, 66} }, 2), LEAF, { band = 1, nopop = true })
local lv = HP.mask()
local cx, cy = 65, 61
for _, o in ipairs{ {-3, -3}, {3, -3}, {-3, 3}, {3, 3} } do lv:add(c:ellipse(cx + o[1], cy + o[2], 3, 3)) end
c:part(lv, LEAF, { band = 2, pop = { x = 60, y = 57 } })
for _, d in ipairs{ {0,0},{-1,-1},{1,-1},{-1,1},{1,1},{-2,-2},{2,-2},{-2,2},{2,2} } do c:put(cx + d[1], cy + d[2], LEAF.deep) end
c:put(68, 56, P.sky.hi) c:put(68, 57, P.sky.base) c:put(69, 57, P.sky.shade)
c:part(c:ellipse(60, 85, 4, 3.5), CAP, { band = 1, pop = { x = 58, y = 83 }, sep = true })
-- head
local head = c:ellipse(39.5, 53, 21, 18)
c:part(head, RED, { band = 3, sep = true, pop = { x = 24, y = 56 } })
local cap = head:copy():clip(c:rect(0, 0, 79, 46))
c:part(cap, CAP, { band = 3, pop = { x = 30, y = 38 } })
c:part(c:ellipse(26, 42, 4, 3):clip(cap), PAT, { band = 1, pop = { x = 24, y = 41 } })
c:part(c:ellipse(53, 42, 4, 3):clip(cap), PAT, { band = 1, nopop = true })
c:put(39, 36, CAP.hi) c:put(40, 36, CAP.hi) c:put(39, 37, CAP.hi)
local band = head:grow(1):clip(c:rect(0, 47, 79, 50))
band:add(c:poly{ {57, 48}, {60, 48}, {66, 56}, {63, 58} }):add(c:poly{ {57, 50}, {59, 50}, {61, 60}, {58, 60} })
c:part(band, BAND, { band = 1, pop = { x = 22, y = 47 } })
c:stitch{ {24, 48}, {55, 48} }
-- antennae
local an = c:line({ {32, 37}, {28, 27}, {21, 22} }, 2):add(c:line({ {47, 37}, {51, 27}, {58, 22} }, 2))
an:add(c:ellipse(19, 20, 3, 3)):add(c:ellipse(60, 20, 3, 3))
c:part(an, CAP, { band = 1, nopop = true })
c:put(18, 19, CAP.hi) c:put(59, 19, CAP.hi)
-- face
c:eyeLocked(28, 53) c:eyeLocked(46, 53)
local sn = c:ellipse(39.5, 61, 2.5, 2)
c:part(sn, CAP, { band = 1, pop = { x = 38, y = 60 }, sep = true })
c:paint({ "i.....i", ".iDDDi.", "..iPi.." }, 36, 64, { i = "ink", D = "ember.deep", P = "petal.base" })
for _, s in ipairs{ {23, 61}, {56, 61} } do c:ellipse(s[1], s[2], 2, 2):each(function(x, y) c:put(x, y, SPOT) end) end
c:finish{ outline = true }
backdrop(P.sky)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
