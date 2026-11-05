-- npc-bram portrait (npc2 P1_2) species: hedgehog
-- Same design as the sprite: hedgehog hedge-wizard, radiating quills, cream face mask, pointed snout with a
-- glossy button nose, purple wizard hat bent left with a gold star tip, pink robe; holds a star wand.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local HH = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hedgehog.lua")
local out = app.params.out or "./"
local NAME = "npc-bram"
local SP = { hi = "#c39a78", base = "#86604e", shade = "#58405a", deep = "#36263e" }
local FACE = { hi = "#ffe8c8", base = "#ecc49a", shade = "#c08a78", deep = "#80525a" }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local HAT, ROBE = P.dusk, P.petal
local NO = { band = 1, nopop = true, inner = false }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function under(m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end

-- star wand
c:part(c:line({ { 61, 99 }, { 65, 62 } }, 2), P.wood, { band = 1, inner = false, pop = { x = 62, y = 70 } })
c:paint({ "...X...", "...X...", "XXXXXXX", ".XXXXX.", "..XXX..", ".XX.XX.", ".X...X." }, 62, 53, { X = "gold.base" })
for _, q in ipairs{ { 64, 55 }, { 63, 56 }, { 65, 54 } } do c:put(q[1], q[2], P.gold.hi) end
for _, q in ipairs{ { 66, 57 }, { 67, 56 }, { 66, 58 }, { 67, 59 } } do c:put(q[1], q[2], P.gold.shade) end
-- robe
local robe = c:ellipse(39.5, 106, 31, 32):clip(c:rect(0, 72, 79, 99))
c:part(robe, ROBE, { band = 2, inner = false, pop = { x = 16, y = 86 } })
for _, l in ipairs{ { { 24, 84 }, { 21, 99 } }, { { 55, 84 }, { 58, 99 } } } do
  c:line(l, 1):clip(robe):each(function(x, y) c:put(x, y, ROBE.shade) end) end
c:part(c:poly{ { 31, 72 }, { 48, 72 }, { 39.5, 85 } }, CR, NO)
c:line({ { 31, 73 }, { 39, 85 } }, 1):add(c:line({ { 48, 73 }, { 40, 85 } }, 1)):each(function(x, y) c:put(x, y, ROBE.deep) end)
c:part(c:ellipse(39.5, 86, 2.5, 2.5), P.gold, { band = 1, inner = false, pop = { x = 38, y = 85 } })
c:hem(97, 12, 67)
local paw = c:ellipse(61.5, 82, 3.5, 3) c:part(paw, FACE, { band = 1, inner = false, pop = { x = 60, y = 80 } }) under(paw, FACE.shade)
c:put(60, 83, FACE.shade) c:put(62, 83, FACE.shade)
HH.head(c, { cx = 39.5, cy = 49, s = 1.4, SP = SP, FACE = FACE })
-- wizard hat
local cone = c:poly{ { 28, 41 }, { 51, 41 }, { 46, 19 }, { 36, 17 } }
cone:add(c:line({ { 41, 19 }, { 37, 12 }, { 31, 8 }, { 26, 7 } }, 5))
local brim = c:ellipse(39.5, 41, 22, 3.5)
local hat = cone:copy():add(brim)
c:part(hat, HAT, { band = 3, inner = false, pop = { x = 36, y = 22 } }) under(hat, HAT.deep)
cone:each(function(x, y) if (y == 35 or y == 36 or y == 37) and not brim:has(x, y) then c:put(x, y, x > 45 and P.gold.shade or P.gold.base) end end)
for x = 30, 50 do if cone:has(x, 35) and not brim:has(x, 35) then c:put(x, 35, P.gold.hi) break end end
for _, q in ipairs{ { 41, 27 }, { 42, 26 }, { 42, 28 }, { 43, 27 }, { 37, 31 } } do c:put(q[1], q[2], P.gold.hi) end
c:put(34, 22, P.cream)
c:paint({ "..X..", ".XXX.", "XXXXX", ".XXX.", "..X.." }, 19, 3, { X = "gold.base" })
c:put(20, 5, P.gold.hi) c:put(21, 4, P.gold.hi) c:put(22, 6, P.gold.shade)
c:finish{ outline = true }
backdrop(P.sky)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
