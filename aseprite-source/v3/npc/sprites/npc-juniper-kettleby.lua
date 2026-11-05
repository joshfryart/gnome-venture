-- npc-juniper-kettleby sprite (npc2 P1_17) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Brisk tea-brewing hedgehog, 3/4 view facing right: spine mound over crown + back, long snout + dark nose,
-- mustard tunic with cream neckerchief, holds a copper kettle (prop). idle(4): base / breath / base / lid rattle + blink.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3a2638", shade = "#57364a", base = "#7a4f36", hi = "#b98a5e", tip = "#f0d6aa" }
local FACE = { hi = "#fff0d4", base = "#f3d6aa", shade = "#c99e8c", deep = "#8a6470" }
local TUN = { hi = "#f5d36a", base = "#e0a83a", shade = "#b06a3a", deep = "#74404a" }
local KER = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local COP = { hi = "#ffc48e", base = "#dc7c46", shade = "#a64c4c", deep = "#5e2c40" }
local NO = { band = 1, nopop = true, inner = false }
HH.sprite{ name = "npc-juniper-kettleby", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 17, sleeve = TUN,
  frames = { {}, { b = 1 }, {}, { blink = true, lid = -1 } },
  body = function(c, k)
    local b = k.b
    local t = k.torso:copy():clip(c:rect(0, k.neck, 63, 95))
    c:part(t, TUN, { band = 2, inner = false, pop = { x = 25, y = 62 + b } }) HH.under(c, t, TUN.deep)
    local nk = c:poly{ { 25, k.neck }, { 41, k.neck }, { 34, k.neck + 7 } }:clip(t)
    c:part(nk, KER, NO)
    for y = k.neck + 9, 84, 4 do c:put(33, y, P.wood.shade) end
  end,
  front = function(c, k)
    local b, ld = k.b, k.p.lid or 0
    local x, y = k.paw.x + 2, k.paw.y + 6
    local kt = c:ellipse(x, y, 5, 4) kt:add(c:rect(x - 3, y - 4, x + 3, y - 3))
    c:part(kt, COP, { band = 1, inner = false, pop = { x = x - 3, y = y - 2 } }) HH.under(c, kt, COP.deep)
    c:part(c:ellipse(x, y - 5 + ld, 3, 1), COP, NO) c:put(x, y - 7 + ld, P.wood.base)
    local sp = c:poly{ { x + 4, y }, { x + 9, y - 5 }, { x + 9, y - 4 }, { x + 5, y + 2 } }
    c:part(sp, COP, NO)
    c:fillMask(c:line({ { x - 5, y - 1 }, { x - 5, y - 4 }, { x - 3, y - 6 } }, 1), P.wood.shade)
    c:put(x - 2, y - 1, COP.hi)
  end,
}
