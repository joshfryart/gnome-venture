-- npc-juniper-kettleby portrait (npc2 P1_17) species: hedgehog (front view 2026-11-05, HH.portraitFront in lib/hedgehog.lua)
-- Brisk tea-brewing hedgehog, head-on: spine arch, cream face, bead eyes, short snout + big dark nose,
-- mustard tunic with a cream neckerchief, copper kettle held up in both paws (a wisp of steam). Lavender disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3a2638", shade = "#57364a", base = "#7a4f36", hi = "#b98a5e", tip = "#f0d6aa" }
local FACE = { hi = "#fff0d4", base = "#f3d6aa", shade = "#c99e8c", deep = "#8a6470" }
local TUN = { hi = "#f5d36a", base = "#e0a83a", shade = "#b06a3a", deep = "#74404a" }
local KER = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local COP = { hi = "#ffc48e", base = "#dc7c46", shade = "#a64c4c", deep = "#5e2c40" }
local NO = { band = 1, nopop = true, inner = false }
HH.portraitFront{ name = "npc-juniper-kettleby", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 17,
  BG = { base = P.dusk.hi, shade = P.dusk.base, deep = P.dusk.shade },
  body = function(c, k)
    c:part(k.torso, TUN, { band = 2, inner = false, pop = { x = 22, y = 82 } })
    local nk = c:poly{ { 26, 70 }, { 54, 70 }, { 40, 83 } }:clip(k.torso:copy():add(c:rect(24, 68, 56, 71)))
    c:part(nk, KER, NO) HH.under(c, nk, KER.deep)
    c:line({ { 40, 71 }, { 40, 81 } }, 1):clip(nk):each(function(x, y) c:put(x, y, KER.shade) end)
  end,
  front = function(c, k)
    local kt = c:ellipse(40, 90, 10, 7.5)
    kt:add(c:rrect(34, 82, 46, 85, 1))
    c:part(kt, COP, { band = 2, inner = false, pop = { x = 34, y = 85 } }) HH.under(c, kt, COP.deep)
    local lid = c:ellipse(40, 82, 5, 2) c:part(lid, COP, { band = 1, inner = false, pop = { x = 37, y = 81 } })
    c:part(c:rect(39, 78, 41, 80), P.wood, NO)
    local sp = c:poly{ { 48, 89 }, { 50, 88 }, { 55, 81 }, { 56, 82 }, { 52, 92 }, { 48, 93 } }
    c:part(sp, COP, NO)
    local h = c:line({ { 32, 87 }, { 30, 81 }, { 33, 77 } }, 2) c:part(h, P.wood, NO)
    c:put(35, 88, COP.hi) c:put(36, 87, COP.hi) c:put(35, 89, P.cream)
    for _, q in ipairs{ { 56, 78 }, { 55, 76 }, { 56, 74 } } do c:put(q[1], q[2], P.cream) end
    HH.pawFront(c, k, 30, 92, 3.5, 3) HH.pawFront(c, k, 50, 95, 3.5, 3)
  end,
}
