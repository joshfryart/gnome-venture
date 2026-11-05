-- npc-tumble-seedwell portrait (npc2 P1_36) species: hedgehog (front view 2026-11-05, HH.portraitFront in lib/hedgehog.lua)
-- Hedgehog seed-keeper, head-on: mauve-brown spine arch with lilac tips and seeds stuck in it, a sprout growing
-- from the crown, peach face + bead eyes + short snout + berry nose, pink smock with cream ruff, satchel strap + seed satchel. Moss disc.
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
HH.portraitFront{ name = "npc-tumble-seedwell", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 36,
  BG = P.moss,
  body = function(c, k)
    c:part(k.torso, P.petal, { band = 2, inner = false, pop = { x = 22, y = 82 } })
    for _, x in ipairs{ 22, 28, 34, 40, 46, 52, 58 } do local m = c:ellipse(x - 0.5, 72, 3.5, 2.5) c:part(m, CR, NO) HH.under(c, m, CR.deep) end
    local st = c:line({ { 25, 75 }, { 52, 99 } }, 3):clip(k.torso)
    c:fillMask(st, P.wood.base)
    st:each(function(x, y) if not st:has(x + 1, y + 1) then c:put(x, y, P.wood.deep) end end)
  end,
  spines = function(c, k)
    for _, q in ipairs{ { 19, 34 }, { 27, 26 }, { 13, 52 }, { 54, 25 }, { 62, 36 }, { 65, 54 }, { 12, 74 } } do seed(c, q[1], q[2]) end
    local x, y = k.crown.x, k.crown.y
    c:fillMask(c:line({ { x, y + 3 }, { x + 1, y - 6 } }, 1), P.moss.shade)
    local l1 = c:ellipse(x - 3, y - 7, 3.5, 2) local l2 = c:ellipse(x + 4, y - 8, 3.5, 2)
    c:part(l1, P.moss, NO) c:part(l2, P.moss, NO) c:put(x - 4, y - 8, P.moss.hi) c:put(x + 3, y - 9, P.moss.hi)
  end,
  front = function(c, k)
    local sa = c:rrect(48, 84, 66, 99, 3)
    c:part(sa, P.wood, { band = 2, inner = false, pop = { x = 50, y = 86 } })
    local fl = c:rrect(47, 83, 67, 90, 3) c:part(fl, { hi = P.wood.hi, base = P.wood.hi, shade = P.wood.base, deep = P.wood.shade }, NO)
    HH.under(c, fl, P.wood.deep)
    c:part(c:rect(56, 89, 58, 91), P.gold, NO)
    seed(c, 51, 81) seed(c, 55, 80) seed(c, 60, 81)
    HH.pawFront(c, k, 47, 92, 3.5, 3)
  end,
}
