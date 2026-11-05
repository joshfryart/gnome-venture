-- npc-bram portrait (npc2 P1_2) species: hedgehog (front view 2026-11-05, HH.portraitFront in lib/hedgehog.lua)
-- Hedge-wizard hedgehog, head-on: spine arch, cream face mask, bead eyes, short snout + big wet nose,
-- purple wizard hat perched in the spines (tip bent back, gold star), pink robe, star wand in the right paw.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local HAT, ROBE = P.dusk, P.petal
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local NO = { band = 1, nopop = true, inner = false }
HH.portraitFront{ name = "npc-bram", out = app.params.out or (DIR .. "/"), BG = P.sky, seed = 2,
  body = function(c, k)
    local robe = k.torso
    c:part(robe, ROBE, { band = 2, inner = false, pop = { x = 22, y = 82 } })
    c:line({ { 24, 86 }, { 21, 99 } }, 1):clip(robe):each(function(x, y) c:put(x, y, ROBE.shade) end)
    local v = c:poly{ { 31, 70 }, { 49, 70 }, { 40, 86 } }:clip(robe)
    c:part(v, CR, NO)
    c:line({ { 31, 71 }, { 39, 86 } }, 1):add(c:line({ { 48, 71 }, { 40, 86 } }, 1)):clip(robe):each(function(x, y) c:put(x, y, ROBE.deep) end)
    c:part(c:ellipse(39.5, 88, 2.5, 2.5), P.gold, { band = 1, inner = false, pop = { x = 38, y = 87 } })
    c:hem(97, 14, 66)
    HH.pawFront(c, k, 27, 92, 3.5, 3)
  end,
  hat = function(c, k)
    local x, y = k.crown.x + 1, k.crown.y + 4
    local cone = c:poly{ { x - 9, y }, { x + 8, y }, { x + 3, y - 15 }, { x - 4, y - 16 } }
    cone:add(c:line({ { x, y - 15 }, { x - 3, y - 20 }, { x - 8, y - 23 }, { x - 13, y - 23 } }, 4))
    local brim = c:ellipse(x, y, 13, 2.5)
    local hat = cone:copy():add(brim)
    c:part(hat, HAT, { band = 2, inner = false, pop = { x = x - 3, y = y - 12 } })
    HH.under(c, hat, HAT.deep)
    cone:each(function(px, py) if (py == y - 4 or py == y - 3) and not brim:has(px, py) then c:put(px, py, px > x + 3 and P.gold.shade or P.gold.base) end end)
    c:put(x - 1, y - 9, P.gold.hi) c:put(x + 2, y - 7, P.gold.hi) c:put(x - 3, y - 13, P.cream)
    c:paint({ "..X..", ".XXX.", "XXXXX", ".XXX.", "..X.." }, x - 18, y - 26, { X = "gold.base" })
    c:put(x - 17, y - 25, P.gold.hi) c:put(x - 16, y - 26, P.gold.hi) c:put(x - 15, y - 23, P.gold.shade)
  end,
  front = function(c, k)
    c:part(c:line({ { 56, 99 }, { 63, 71 } }, 2), P.wood, { band = 1, inner = false, pop = { x = 60, y = 80 } })
    c:paint({ "...X...", "...X...", "XXXXXXX", ".XXXXX.", "..XXX..", ".XX.XX.", ".X...X." }, 60, 62, { X = "gold.base" })
    for _, q in ipairs{ { 62, 64 }, { 61, 65 }, { 63, 63 } } do c:put(q[1], q[2], P.gold.hi) end
    for _, q in ipairs{ { 64, 66 }, { 65, 65 }, { 64, 67 }, { 65, 68 } } do c:put(q[1], q[2], P.gold.shade) end
    HH.pawFront(c, k, 59, 87, 4, 3.2)
  end,
}
