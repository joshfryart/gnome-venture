-- npc-juniper-kettleby portrait (npc2 P1_17) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Brisk tea-brewing hedgehog, 3/4 view: spine mound over crown + back, cream face with long snout and dark nose,
-- mustard tunic with a cream neckerchief, copper kettle held up in frame (a wisp of steam). Lavender disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3a2638", shade = "#57364a", base = "#7a4f36", hi = "#b98a5e", tip = "#f0d6aa" }
local FACE = { hi = "#fff0d4", base = "#f3d6aa", shade = "#c99e8c", deep = "#8a6470" }
local TUN = { hi = "#f5d36a", base = "#e0a83a", shade = "#b06a3a", deep = "#74404a" }
local KER = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local COP = { hi = "#ffc48e", base = "#dc7c46", shade = "#a64c4c", deep = "#5e2c40" }
local NO = { band = 1, nopop = true, inner = false }
HH.portrait{ name = "npc-juniper-kettleby", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 17,
  BG = { base = P.dusk.hi, shade = P.dusk.base, deep = P.dusk.shade },
  body = function(c, k)
    c:part(k.torso, TUN, { band = 2, inner = false, pop = { x = 30, y = 84 } })
    for y = 86, 98, 4 do c:part(c:ellipse(46, y, 1.5, 1.5), P.wood, NO) end
    local nk = c:poly{ { 33, 75 }, { 62, 75 }, { 48, 88 } }:clip(k.torso:copy():add(c:rect(30, 74, 64, 76)))
    c:part(nk, KER, NO) HH.under(c, nk, KER.deep)
    c:line({ { 48, 76 }, { 48, 86 } }, 1):clip(nk):each(function(x, y) c:put(x, y, KER.shade) end)
  end,
  front = function(c, k)
    local kt = c:ellipse(62, 87, 10, 7.5)
    kt:add(c:rrect(56, 79, 68, 82, 1))
    c:part(kt, COP, { band = 2, inner = false, pop = { x = 56, y = 82 } }) HH.under(c, kt, COP.deep)
    local lid = c:ellipse(62, 79, 5, 2) c:part(lid, COP, { band = 1, inner = false, pop = { x = 59, y = 78 } })
    c:part(c:rect(61, 75, 63, 77), P.wood, NO)
    local sp = c:poly{ { 70, 86 }, { 72, 85 }, { 77, 78 }, { 78, 79 }, { 74, 89 }, { 70, 90 } }
    c:part(sp, COP, NO)
    local h = c:line({ { 54, 84 }, { 52, 78 }, { 55, 74 } }, 2) c:part(h, P.wood, NO)
    c:put(57, 85, COP.hi) c:put(58, 84, COP.hi) c:put(57, 86, P.cream)
    for _, q in ipairs{ { 77, 75 }, { 76, 73 }, { 77, 71 } } do c:put(q[1], q[2], P.cream) end
    local paw = c:ellipse(52, 90, 3.5, 3) c:part(paw, FACE, NO) HH.under(c, paw, FACE.deep)
  end,
}
