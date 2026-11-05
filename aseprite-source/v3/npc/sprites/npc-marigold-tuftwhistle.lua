-- npc-marigold-tuftwhistle sprite (npc2 P1_21) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Round bristly hedgehog, 3/4 view facing right: spine mound with a perky top tuft, long snout + button nose,
-- red jumper with cream collar; prop: little brass tin whistle in her paw. idle(4): base / breath / base / tuft twitch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3a2420", shade = P.skinC.shade, base = P.skinC.base, hi = P.skinB.base, tip = P.skinB.hi }
local FACE = { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }
local CR = { hi = P.cream, base = P.cream, shade = P.skinA.hi, deep = P.skinA.shade }
local BR = { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }
local NO = { band = 1, nopop = true, inner = false }
HH.sprite{ name = "npc-marigold-tuftwhistle", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 21, sleeve = P.ember,
  frames = { {}, { b = 1 }, {}, { tw = 1 } },
  body = function(c, k)
    local b = k.b
    local j = k.torso:copy():clip(c:rect(0, k.neck, 63, 95))
    c:part(j, P.ember, { band = 2, inner = false, pop = { x = 25, y = 62 + b } }) HH.under(c, j, P.ember.deep)
    for x = 24, 42, 2 do if j:has(x, 83) then c:put(x, 83, P.ember.shade) end end
    for _, f in ipairs{ { 29, k.neck + 1 }, { 37, k.neck + 1 } } do c:part(c:ellipse(f[1], f[2], 3.5, 2), CR, NO) end
  end,
  spines = function(c, k)
    local tw = k.p.tw or 0
    local x, y = k.crown.x, k.crown.y
    for _, t in ipairs{ { x - 1, y + 2, x - 2 - tw, y - 5 }, { x + 2, y + 2, x + 3, y - 4 + tw }, { x - 4, y + 3, x - 7 - tw, y - 2 } } do
      local m = c:poly{ { t[1] - 1.5, t[2] }, { t[1] + 1.5, t[2] }, { t[3], t[4] } }
      m:each(function(px, py) c:put(px, py, py < t[4] + 2 and SP.tip or (py < t[4] + 4 and SP.hi or SP.base)) end)
    end
  end,
  front = function(c, k)
    local px, py = k.paw.x, k.paw.y
    local wh = c:line({ { px - 1, py + 1 }, { px + 7, py - 4 } }, 2)
    c:part(wh, BR, NO)
    c:put(px + 3, py - 2, BR.deep) c:put(px + 5, py - 3, BR.deep)
  end,
}
