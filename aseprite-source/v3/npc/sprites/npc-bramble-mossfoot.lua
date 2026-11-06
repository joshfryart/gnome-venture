-- npc-bramble-mossfoot sprite (npc2 P1_3) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Shy earthy hedgehog, 3/4 view facing right: brown spine mound over crown + back, long snout, wet nose,
-- green knit sweater, red stitched scarf; quirk: a red-cap mushroom + moss tuft growing on his spines.
-- 64x96 cell, feet y=90, idle(4): base / breath + mushroom settles late / base / blink.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3a2230", shade = P.wood.deep, base = P.wood.shade, hi = P.wood.base, tip = P.wood.hi }
local STEM = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local NO = { band = 1, nopop = true, inner = false }
HH.sprite{ name = "npc-bramble-mossfoot", out = app.params.out or (DIR .. "/"), SP = SP, seed = 3, sleeve = P.moss,
  frames = { {}, { b = 1, md = 1 }, {}, { blink = true } },
  body = function(c, k)
    local b = k.b
    local sw = k.torso:copy():clip(c:rect(0, k.neck, 63, 95))
    c:part(sw, P.moss, { band = 2, inner = false, pop = { x = 25, y = 62 + b } })
    HH.under(c, sw, P.moss.deep)
    for x = 24, 42, 2 do if sw:has(x, 84) then c:put(x, 84, P.moss.shade) end end
    local sc = c:rrect(22, k.neck - 1, 42, k.neck + 2, 1)
    c:part(sc, P.ember, { band = 1, inner = false, pop = { x = 24, y = k.neck - 1 } })
    c:stitch{ { 23, k.neck }, { 41, k.neck } }
    local tl = c:poly{ { 34, k.neck + 2 }, { 38, k.neck + 2 }, { 39, k.neck + 10 }, { 35, k.neck + 10 } }
    c:part(tl, P.ember, NO) HH.under(c, tl, P.ember.deep)
  end,
  spines = function(c, k)
    local my = k.b + (k.p.md or 0)
    local tuft = c:ellipse(15, 36 + my, 4.5, 1.6) tuft:add(c:ellipse(11, 35 + my, 1.6, 1.4))
    c:part(tuft, P.moss, { band = 1, inner = false, pop = { x = 12, y = 35 + my } })
    c:part(c:rect(15, 31 + my, 16, 35 + my), STEM, NO)
    local cap = c:ellipse(15.5, 30 + my, 3.5, 2):clip(c:rect(0, 0, 63, 30 + my))
    c:part(cap, P.ember, { band = 1, inner = false, pop = { x = 13, y = 29 + my } })
    c:put(16, 29 + my, P.cream) c:put(13, 30 + my, P.cream)
  end,
}
