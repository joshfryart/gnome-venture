-- npc-bramble-mossfoot portrait (npc2 P1_3) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Shy earthy hedgehog, 3/4 view: brown spine mound with pale tips, cream face mask + long snout, wet nose,
-- green knit sweater, red stitched scarf; quirk: a red-cap mushroom + moss tuft growing on his back spines. Moss disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3a2230", shade = P.wood.deep, base = P.wood.shade, hi = P.wood.base, tip = P.wood.hi }
local STEM = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local NO = { band = 1, nopop = true, inner = false }
HH.portrait{ name = "npc-bramble-mossfoot", out = app.params.out or (DIR .. "/"), BG = P.moss, SP = SP, seed = 3,
  body = function(c, k)
    c:part(k.torso, P.moss, { band = 2, inner = false, pop = { x = 30, y = 84 } })
    for x = 26, 72, 3 do for y = 92, 99 do if k.torso:has(x, y) then c:put(x, y, P.moss.shade) end end end
    for x = 24, 72 do if k.torso:has(x, 91) then c:put(x, 91, P.moss.deep) end end
    local sc = c:rrect(30, 72, 66, 79, 3)
    c:part(sc, P.ember, { band = 1, inner = false, pop = { x = 33, y = 73 } })
    HH.under(c, sc, P.ember.deep)
    c:stitch{ { 32, 74 }, { 64, 74 } }
    local tl = c:poly{ { 52, 78 }, { 59, 78 }, { 61, 96 }, { 54, 96 } }
    c:part(tl, P.ember, NO) HH.under(c, tl, P.ember.deep)
    for y = 82, 94, 4 do c:put(55, y, P.ember.shade) c:put(56, y, P.ember.shade) end
    for x = 54, 60, 2 do c:put(x, 97, P.ember.deep) end
  end,
  spines = function(c, k)
    local tuft = c:ellipse(21, 33, 7, 2.5) tuft:add(c:ellipse(15, 32, 2.5, 2)) tuft:add(c:ellipse(27, 32, 2.5, 1.8))
    c:part(tuft, P.moss, { band = 1, inner = false, pop = { x = 16, y = 31 } }) HH.under(c, tuft, P.moss.deep)
    for _, x in ipairs{ 14, 19, 24 } do c:put(x, 30, P.moss.hi) end
    c:part(c:rect(21, 25, 23, 31), STEM, NO)
    local cap = c:ellipse(22, 23, 6, 3.5):clip(c:rect(0, 0, 79, 25))
    c:part(cap, P.ember, { band = 1, inner = false, pop = { x = 19, y = 21 } }) HH.under(c, cap, P.ember.deep)
    for _, q in ipairs{ { 21, 21 }, { 25, 22 }, { 18, 23 } } do c:put(q[1], q[2], P.cream) end
  end,
}
