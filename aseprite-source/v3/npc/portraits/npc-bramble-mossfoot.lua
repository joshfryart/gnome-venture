-- npc-bramble-mossfoot portrait (npc2 P1_3) species: hedgehog (front view 2026-11-05, HH.portraitFront in lib/hedgehog.lua)
-- Shy earthy hedgehog, head-on: brown spine arch with pale tips, cream face mask, two bead eyes, short snout + big wet nose,
-- green knit sweater, red stitched scarf (paws clasped on the tail); quirk: a red-cap mushroom + moss tuft on his spines. Moss disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3a2230", shade = P.wood.deep, base = P.wood.shade, hi = P.wood.base, tip = P.wood.hi }
local STEM = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local NO = { band = 1, nopop = true, inner = false }
HH.portraitFront{ name = "npc-bramble-mossfoot", out = app.params.out or (DIR .. "/"), BG = P.moss, SP = SP, seed = 3,
  body = function(c, k)
    c:part(k.torso, P.moss, { band = 2, inner = false, pop = { x = 24, y = 82 } })
    for x = 17, 62, 3 do for y = 93, 99 do if k.torso:has(x, y) then c:put(x, y, P.moss.shade) end end end
    for x = 14, 66 do if k.torso:has(x, 92) then c:put(x, 92, P.moss.deep) end end
    local sc = c:rrect(22, 68, 57, 75, 3)
    c:part(sc, P.ember, { band = 1, inner = false, pop = { x = 25, y = 69 } })
    HH.under(c, sc, P.ember.deep)
    c:stitch{ { 24, 70 }, { 55, 70 } }
    local tl = c:poly{ { 44, 74 }, { 51, 74 }, { 52, 95 }, { 45, 95 } }
    c:part(tl, P.ember, NO) HH.under(c, tl, P.ember.deep)
    for y = 78, 94, 4 do c:put(47, y, P.ember.shade) c:put(48, y, P.ember.shade) end
    for x = 45, 51, 2 do c:put(x, 96, P.ember.deep) end
    -- sleeves reaching in to the clasped paws
    for _, a in ipairs{ { { 15, 82 }, { 26, 88 }, { 37, 89 } }, { { 64, 82 }, { 55, 88 }, { 50, 89 } } } do
      local sl = c:line(a, 5)
      c:part(sl, P.moss, { band = 1, inner = false, nopop = true }) HH.under(c, sl, P.moss.deep)
    end
    HH.pawFront(c, k, 40, 88, 3.5, 3)
    HH.pawFront(c, k, 47, 87, 3.5, 3)
  end,
  spines = function(c, k)
    local tuft = c:ellipse(24, 27, 6, 2.5) tuft:add(c:ellipse(19, 27, 2.5, 2)) tuft:add(c:ellipse(29, 26, 2.5, 1.8))
    c:part(tuft, P.moss, { band = 1, inner = false, pop = { x = 19, y = 25 } }) HH.under(c, tuft, P.moss.deep)
    for _, x in ipairs{ 18, 23, 28 } do c:put(x, 24, P.moss.hi) end
    c:part(c:rect(23, 19, 25, 25), STEM, NO)
    local cap = c:ellipse(24, 17, 6, 3.5):clip(c:rect(0, 0, 79, 19))
    c:part(cap, P.ember, { band = 1, inner = false, pop = { x = 21, y = 15 } }) HH.under(c, cap, P.ember.deep)
    for _, q in ipairs{ { 23, 15 }, { 27, 16 }, { 20, 17 } } do c:put(q[1], q[2], P.cream) end
  end,
}
