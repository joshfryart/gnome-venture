-- npc-marigold-tuftwhistle portrait (npc2 P1_21) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Round bristly hedgehog, 3/4 view: spine mound with a perky top tuft, tan face + long snout + button nose,
-- red jumper with a cream collar, brass tin whistle on a cord at the chest. Moss disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3a2420", shade = P.skinC.shade, base = P.skinC.base, hi = P.skinB.base, tip = P.skinB.hi }
local FACE = { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }
local CR = { hi = P.cream, base = P.cream, shade = P.skinA.hi, deep = P.skinA.shade }
local BR = { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }
local NO = { band = 1, nopop = true, inner = false }
HH.portrait{ name = "npc-marigold-tuftwhistle", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 21,
  BG = P.moss,
  body = function(c, k)
    c:part(k.torso, P.ember, { band = 2, inner = false, pop = { x = 30, y = 84 } })
    for x = 24, 72, 3 do for y = 95, 99 do if k.torso:has(x, y) then c:put(x, y, P.ember.shade) end end end
    for _, f in ipairs{ { 40, 77, 6, 4 }, { 54, 77, 6, 4 } } do
      local m = c:ellipse(f[1], f[2], f[3], f[4]) c:part(m, CR, NO) HH.under(c, m, CR.deep)
    end
    c:fillMask(c:line({ { 41, 81 }, { 46, 89 } }, 1), P.wood.deep) c:fillMask(c:line({ { 53, 81 }, { 49, 89 } }, 1), P.wood.deep)
    local wh = c:rrect(43, 89, 58, 92, 1)
    c:part(wh, BR, NO) HH.under(c, wh, BR.deep)
    for _, x in ipairs{ 49, 52, 55 } do c:put(x, 90, BR.deep) end
    c:put(44, 89, BR.hi) c:put(45, 89, BR.hi)
  end,
  spines = function(c, k)
    for i, t in ipairs{ { 33, 22, 31, 12 }, { 37, 22, 38, 13 }, { 29, 23, 25, 15 } } do
      local m = c:poly{ { t[1] - 2, t[2] }, { t[1] + 2, t[2] }, { t[3], t[4] } }
      m:each(function(x, y) c:put(x, y, y < t[4] + 3 and SP.tip or (y < t[4] + 6 and SP.hi or SP.base)) end)
    end
  end,
}
