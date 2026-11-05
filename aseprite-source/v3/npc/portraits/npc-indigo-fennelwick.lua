-- npc-indigo-fennelwick portrait (npc2 P1_15) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Cosy hedgehog herbalist, 3/4 view: chestnut spine mound with cream tips, cream face + long snout + plum nose,
-- indigo tam perched in the spines, indigo smock, mustard scarf; fennel sprig with a yellow umbel. Lilac disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3e2735", shade = "#5e3a48", base = "#8a5636", hi = "#b07a4f", tip = "#ecd4a4" }
local FACE = { hi = "#f8ecd4", base = "#ead2b0", shade = "#c9a6a0", deep = "#8f6f86" }
local SM = { hi = "#8582d8", base = "#5553a8", shade = "#3b357a", deep = "#2a2556" }
local SCF = { hi = "#f5d36a", base = "#e0a83a", shade = "#b06a3a", deep = "#74404a" }
local ST = { hi = "#b6d86a", base = "#7fae45", shade = "#4d7a48", deep = "#2f4f45" }
local UM = { hi = "#fbe77a", base = "#e9c63e", shade = "#b88c38", deep = "#7a5a3a" }
local NO = { band = 1, nopop = true, inner = false }
HH.portrait{ name = "npc-indigo-fennelwick", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 15,
  BG = { base = "#a7a2e6", shade = "#7d76c8", deep = "#5a52a0" },
  body = function(c, k)
    c:part(k.torso, SM, { band = 2, inner = false, pop = { x = 30, y = 84 } })
    for _, x in ipairs{ 40, 52 } do for y = 90, 99, 3 do c:put(x, y, SM.deep) end end
    local sc = c:rrect(30, 72, 66, 79, 3)
    c:part(sc, SCF, { band = 1, inner = false, pop = { x = 33, y = 73 } }) HH.under(c, sc, SCF.deep)
    local tl = c:poly{ { 36, 78 }, { 43, 78 }, { 41, 96 }, { 34, 95 } }
    c:part(tl, SCF, NO) HH.under(c, tl, SCF.deep)
    for x = 35, 41, 2 do c:put(x, 96, SCF.shade) end
  end,
  hat = function(c, k)
    local x, y = k.crown.x + 1, k.crown.y + 3
    local hat = c:ellipse(x, y, 12, 4) hat:add(c:ellipse(x - 1, y - 3, 10, 4.5))
    c:part(hat, SM, { band = 2, inner = false, pop = { x = x - 7, y = y - 6 } }) HH.under(c, hat, SM.deep)
    for xx = x - 11, x + 11, 3 do if hat:has(xx, y + 2) then c:put(xx, y + 2, SCF.base) end end
    c:part(c:line({ { x - 1, y - 7 }, { x + 1, y - 11 } }, 2), SM, NO)
  end,
  front = function(c, k)
    local stalk = c:line({ { 62, 99 }, { 66, 84 }, { 71, 70 } }, 2)
    c:part(stalk, ST, NO)
    for _, f in ipairs{ { 65, 88, 72, 84 }, { 66, 82, 60, 78 }, { 68, 77, 75, 74 } } do
      c:fillMask(c:line({ { f[1], f[2] }, { f[3], f[4] } }, 1), ST.hi)
    end
    for _, a in ipairs{ -5, -2, 1, 4 } do c:fillMask(c:line({ { 71, 70 }, { 71 + a, 66 } }, 1), ST.base) end
    local um = c:ellipse(71, 64, 6, 2.5)
    c:part(um, UM, { band = 1, inner = false, pop = { x = 67, y = 63 } })
    for _, x in ipairs{ 67, 70, 73, 75 } do c:put(x, 62, UM.hi) end
    local paw = c:ellipse(64, 88, 3.5, 3) c:part(paw, FACE, NO) HH.under(c, paw, FACE.deep)
  end,
}
