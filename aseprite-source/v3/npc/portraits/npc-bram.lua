-- npc-bram portrait (npc2 P1_2) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Hedge-wizard hedgehog in 3/4 view: big swept-back spine mound, cream face mask + long snout + wet nose,
-- purple wizard hat perched in the spines (tip bent back, gold star), pink robe, star wand in the paw.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local HAT, ROBE = P.dusk, P.petal
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local NO = { band = 1, nopop = true, inner = false }
HH.portrait{ name = "npc-bram", out = app.params.out or (DIR .. "/"), BG = P.sky, seed = 2,
  body = function(c, k)
    local robe = k.torso
    c:part(robe, ROBE, { band = 2, inner = false, pop = { x = 24, y = 84 } })
    c:line({ { 30, 86 }, { 27, 99 } }, 1):clip(robe):each(function(x, y) c:put(x, y, ROBE.shade) end)
    local v = c:poly{ { 35, 76 }, { 52, 76 }, { 44, 89 } }:clip(robe)
    c:part(v, CR, NO)
    c:line({ { 35, 77 }, { 43, 89 } }, 1):add(c:line({ { 52, 77 }, { 45, 89 } }, 1)):clip(robe):each(function(x, y) c:put(x, y, ROBE.deep) end)
    c:part(c:ellipse(44, 90, 2.5, 2.5), P.gold, { band = 1, inner = false, pop = { x = 43, y = 89 } })
    c:hem(97, 14, 70)
  end,
  hat = function(c, k)
    local x, y = k.crown.x + 2, k.crown.y + 5
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
    c:part(c:line({ { 58, 99 }, { 66, 70 } }, 2), P.wood, { band = 1, inner = false, pop = { x = 63, y = 80 } })
    c:paint({ "...X...", "...X...", "XXXXXXX", ".XXXXX.", "..XXX..", ".XX.XX.", ".X...X." }, 63, 61, { X = "gold.base" })
    for _, q in ipairs{ { 65, 63 }, { 64, 64 }, { 66, 62 } } do c:put(q[1], q[2], P.gold.hi) end
    for _, q in ipairs{ { 67, 65 }, { 68, 64 }, { 67, 66 }, { 68, 67 } } do c:put(q[1], q[2], P.gold.shade) end
    local paw = c:ellipse(61, 86, 4, 3.2)
    c:part(paw, k.FACE, NO) HH.under(c, paw, k.FACE.deep)
    c:put(59, 87, k.FACE.shade) c:put(61, 88, k.FACE.shade)
  end,
}
