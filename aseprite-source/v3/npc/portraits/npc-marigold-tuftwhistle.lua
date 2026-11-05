-- npc-marigold-tuftwhistle portrait (npc2 P1_21) species: hedgehog (front view 2026-11-05, HH.portraitFront in lib/hedgehog.lua)
-- Round bristly hedgehog, head-on: spine arch with a perky top tuft, tan face, bead eyes, short snout + button nose,
-- red jumper with a cream collar, brass tin whistle on a cord held at the chest in both paws. Moss disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3a2420", shade = P.skinC.shade, base = P.skinC.base, hi = P.skinB.base, tip = P.skinB.hi }
local FACE = { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }
local CR = { hi = P.cream, base = P.cream, shade = P.skinA.hi, deep = P.skinA.shade }
local BR = { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }
local NO = { band = 1, nopop = true, inner = false }
HH.portraitFront{ name = "npc-marigold-tuftwhistle", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 21,
  BG = P.moss,
  body = function(c, k)
    c:part(k.torso, P.ember, { band = 2, inner = false, pop = { x = 22, y = 82 } })
    for x = 16, 64, 3 do for y = 95, 99 do if k.torso:has(x, y) then c:put(x, y, P.ember.shade) end end end
    for _, f in ipairs{ { 33, 71, 6, 4 }, { 46, 71, 6, 4 } } do
      local m = c:ellipse(f[1], f[2], f[3], f[4]) c:part(m, CR, NO) HH.under(c, m, CR.deep)
    end
    c:fillMask(c:line({ { 34, 75 }, { 37, 85 } }, 1), P.wood.deep) c:fillMask(c:line({ { 45, 75 }, { 42, 85 } }, 1), P.wood.deep)
    local wh = c:rrect(32, 85, 47, 88, 1)
    c:part(wh, BR, NO) HH.under(c, wh, BR.deep)
    for _, x in ipairs{ 38, 41, 44 } do c:put(x, 86, BR.deep) end
    c:put(33, 85, BR.hi) c:put(34, 85, BR.hi)
    HH.pawFront(c, k, 31, 90, 3.5, 3) HH.pawFront(c, k, 48, 90, 3.5, 3)
  end,
  spines = function(c, k)
    for i, t in ipairs{ { 38, 23, 36, 11 }, { 42, 23, 43, 12 }, { 34, 24, 30, 14 } } do
      local m = c:poly{ { t[1] - 2, t[2] }, { t[1] + 2, t[2] }, { t[3], t[4] } }
      m:each(function(x, y) c:put(x, y, y < t[4] + 3 and SP.tip or (y < t[4] + 6 and SP.hi or SP.base)) end)
    end
  end,
}
