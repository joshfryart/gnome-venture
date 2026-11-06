-- npc-bram sprite (npc2 P1_2) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Hedge-wizard hedgehog, 3/4 view facing right: spine mound over crown + back, long snout, wet nose;
-- purple wizard hat perched on the spines (bent tip, gold star), pink robe; star wand in the front paw.
-- 64x96 cell, feet y=90, idle(4): base / breath + hat tip + wand bob / base / blink.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local HAT, ROBE = P.dusk, P.petal
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local NO = { band = 1, nopop = true, inner = false }
HH.sprite{ name = "npc-bram", out = app.params.out or (DIR .. "/"), seed = 2, sleeve = ROBE,
  frames = { {}, { b = 1, hb = 1 }, {}, { blink = true } },
  body = function(c, k)
    local b = k.b
    local robe = k.torso:copy():clip(c:rect(0, k.neck, 63, 95))
    robe:add(c:poly{ { k.X(-1), 64 + b }, { k.X(13), 64 + b }, { k.X(15), 86 }, { k.X(-3), 86 } })
    c:part(robe, ROBE, { band = 2, inner = false, pop = { x = k.X(2), y = 66 + b } })
    HH.under(c, robe, ROBE.deep)
    c:line({ { k.X(5), 72 + b }, { k.X(4), 85 } }, 1):clip(robe):each(function(x, y) c:put(x, y, ROBE.shade) end)
    c:hem(85, math.floor(k.X(-2)), math.floor(k.X(14)))
    c:part(c:poly{ { k.X(3), k.neck }, { k.X(12), k.neck }, { k.X(8), k.neck + 6 } }:clip(robe), CR, NO)
    c:button(math.floor(k.X(8) + 0.5), k.neck + 7)
  end,
  hat = function(c, k)
    local x, y, hb = k.crown.x + 1, k.crown.y + 4, k.p.hb or 0
    local cone = c:poly{ { x - 6, y }, { x + 6, y }, { x + 2, y - 10 }, { x - 3, y - 11 } }
    cone:add(c:line({ { x, y - 10 }, { x - 2, y - 13 }, { x - 5, y - 15 + hb }, { x - 8, y - 15 + hb } }, 3))
    local brim = c:ellipse(x, y, 9, 1.6)
    local hat = cone:copy():add(brim)
    c:part(hat, HAT, { band = 2, inner = false, pop = { x = x - 2, y = y - 8 } })
    HH.under(c, hat, HAT.deep)
    cone:each(function(px, py) if py == y - 3 and not brim:has(px, py) then c:put(px, py, px > x + 2 and P.gold.shade or P.gold.base) end end)
    c:put(x, y - 6, P.gold.hi) c:put(x - 2, y - 9, P.cream)
    c:paint({ ".X.", "XXX", ".X." }, x - 11, y - 17 + hb, { X = "gold.base" })
    c:put(x - 10, y - 17 + hb, P.gold.hi)
  end,
  front = function(c, k)
    local b = k.b
    local px, py = k.paw.x, k.paw.y
    c:part(c:line({ { px, py + 6 }, { px + 3, py - 10 } }, 1), P.wood, NO)
    c:paint({ "..X..", "XXXXX", ".XXX.", ".X.X." }, px + 1, py - 14, { X = "gold.base" })
    c:put(px + 2, py - 13, P.gold.hi) c:put(px + 3, py - 14, P.gold.hi) c:put(px + 4, py - 12, P.gold.shade)
  end,
}
