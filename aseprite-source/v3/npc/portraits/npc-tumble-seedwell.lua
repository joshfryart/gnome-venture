-- npc-tumble-seedwell portrait (npc2 P1_36) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Hedgehog seed-keeper, 3/4 view: mauve-brown spine mound with lilac tips and seeds stuck in it, a sprout growing
-- from the crown, peach face + long snout + berry nose, pink smock with cream ruff, satchel strap + seed satchel. Moss disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#33243e", shade = "#54405e", base = "#7a6080", hi = "#a88cc4", tip = "#e4d6f4" }
local FACE = { hi = "#ffe8c8", base = "#f0c89a", shade = "#c98f72", deep = "#7a4a46" }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local SEED = { "#e8c27a", "#c8945a", "#7a4a36" }
local NO = { band = 1, nopop = true, inner = false }
local function seed(c, x, y)
  c:put(x, y, SEED[1]) c:put(x + 1, y, SEED[2]) c:put(x, y + 1, SEED[2]) c:put(x + 1, y + 1, SEED[3]) c:put(x, y + 2, SEED[3])
end
HH.portrait{ name = "npc-tumble-seedwell", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 36,
  BG = P.moss,
  body = function(c, k)
    c:part(k.torso, P.petal, { band = 2, inner = false, pop = { x = 30, y = 84 } })
    for x = 30, 66, 6 do local m = c:ellipse(x, 77, 3.5, 2.5) c:part(m, CR, NO) HH.under(c, m, CR.deep) end
    local st = c:line({ { 62, 79 }, { 36, 99 } }, 3):clip(k.torso)
    c:fillMask(st, P.wood.base)
    st:each(function(x, y) if not st:has(x + 1, y + 1) then c:put(x, y, P.wood.deep) end end)
  end,
  spines = function(c, k)
    for _, q in ipairs{ { 17, 40 }, { 24, 30 }, { 12, 56 }, { 30, 36 }, { 9, 72 }, { 20, 84 } } do seed(c, q[1], q[2]) end
    local x, y = k.crown.x, k.crown.y
    c:fillMask(c:line({ { x, y + 3 }, { x + 1, y - 6 } }, 1), P.moss.shade)
    local l1 = c:ellipse(x - 3, y - 7, 3.5, 2) local l2 = c:ellipse(x + 4, y - 8, 3.5, 2)
    c:part(l1, P.moss, NO) c:part(l2, P.moss, NO) c:put(x - 4, y - 8, P.moss.hi) c:put(x + 3, y - 9, P.moss.hi)
  end,
  front = function(c, k)
    local sa = c:rrect(56, 84, 74, 99, 3)
    c:part(sa, P.wood, { band = 2, inner = false, pop = { x = 58, y = 86 } })
    local fl = c:rrect(55, 83, 75, 90, 3) c:part(fl, { hi = P.wood.hi, base = P.wood.hi, shade = P.wood.base, deep = P.wood.shade }, NO)
    HH.under(c, fl, P.wood.deep)
    c:part(c:rect(64, 89, 66, 91), P.gold, NO)
    seed(c, 59, 81) seed(c, 63, 80) seed(c, 68, 81)
  end,
}
