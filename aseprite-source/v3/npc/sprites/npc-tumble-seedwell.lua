-- npc-tumble-seedwell sprite (npc2 P1_36) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Hedgehog seed-keeper, 3/4 view facing right: mauve-brown spine mound with lilac tips and seeds stuck in it,
-- sprout from the crown, long snout + berry nose, pink smock with cream ruff; prop: seed satchel. idle(4).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#33243e", shade = "#54405e", base = "#7a6080", hi = "#a88cc4", tip = "#e4d6f4" }
local FACE = { hi = "#ffe8c8", base = "#f0c89a", shade = "#c98f72", deep = "#7a4a46" }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local SEED = { "#e8c27a", "#c8945a", "#7a4a36" }
local NO = { band = 1, nopop = true, inner = false }
local function seed(c, x, y) c:put(x, y, SEED[1]) c:put(x + 1, y, SEED[2]) c:put(x, y + 1, SEED[3]) end
HH.sprite{ name = "npc-tumble-seedwell", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 36, sleeve = P.petal,
  frames = { {}, { b = 1, sp = 1 }, {}, { blink = true } },
  body = function(c, k)
    local b = k.b
    local sm = k.torso:copy():clip(c:rect(0, k.neck, 63, 95))
    c:part(sm, P.petal, { band = 2, inner = false, pop = { x = 25, y = 62 + b } }) HH.under(c, sm, P.petal.deep)
    for x = 24, 40, 4 do c:part(c:ellipse(x, k.neck + 1, 2.2, 1.5), CR, NO) end
    c:fillMask(c:line({ { 39, k.neck + 2 }, { 22, 78 + b } }, 1), P.wood.deep)
  end,
  spines = function(c, k)
    local b = k.b
    for _, q in ipairs{ { 13, 40 }, { 19, 32 }, { 9, 52 }, { 11, 66 }, { 15, 78 } } do seed(c, q[1], q[2] + b) end
    local x, y, sp = k.crown.x, k.crown.y, k.p.sp or 0
    c:fillMask(c:line({ { x, y + 2 }, { x, y - 4 } }, 1), P.moss.shade)
    c:fillMask(c:ellipse(x - 2, y - 5 + sp, 2, 1), P.moss.base) c:fillMask(c:ellipse(x + 2, y - 6, 2, 1), P.moss.base)
    c:put(x - 3, y - 5 + sp, P.moss.hi) c:put(x + 2, y - 7, P.moss.hi)
    local sa = c:rrect(16, 75 + b, 26, 83 + b, 2)
    c:part(sa, P.wood, { band = 1, inner = false, pop = { x = 17, y = 76 + b } })
    local fl = c:rrect(16, 75 + b, 26, 78 + b, 1) c:part(fl, { hi = P.wood.hi, base = P.wood.hi, shade = P.wood.base, deep = P.wood.shade }, NO)
    HH.under(c, fl, P.wood.deep)
    seed(c, 18, 73 + b) seed(c, 22, 73 + b)
    c:put(21, 79 + b, P.gold.base)
  end,
}
