-- npc-indigo-fennelwick sprite (npc2 P1_15) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Cosy hedgehog herbalist, 3/4 view facing right: chestnut spine mound with cream tips, long snout, plum nose,
-- indigo tam perched in the spines with a stalk, indigo smock, mustard scarf; prop: fennel sprig with a yellow umbel.
-- 64x96 cell, feet y=90, idle(4): base / breath + umbel settle / base / blink + umbel twitch.
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
HH.sprite{ name = "npc-indigo-fennelwick", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 15, sleeve = SM,
  frames = { {}, { b = 1, dr = 1, hs = 1 }, {}, { blink = true, tw = 1 } },
  body = function(c, k)
    local b = k.b
    local sm = k.torso:copy():clip(c:rect(0, k.neck, 63, 95))
    c:part(sm, SM, { band = 2, inner = false, pop = { x = 25, y = 62 + b } }) HH.under(c, sm, SM.deep)
    local sc = c:rrect(22, k.neck - 1, 42, k.neck + 2, 1)
    c:part(sc, SCF, { band = 1, inner = false, pop = { x = 24, y = k.neck - 1 } })
    local tl = c:poly{ { 25, k.neck + 2 }, { 29, k.neck + 2 }, { 28, k.neck + 11 }, { 24, k.neck + 10 } }
    c:part(tl, SCF, NO) HH.under(c, tl, SCF.deep)
  end,
  hat = function(c, k)
    local x, y = k.crown.x + 1, k.crown.y + 2
    local hat = c:ellipse(x, y, 8, 2.5) hat:add(c:ellipse(x - 1, y - 2, 6.5, 2.5))
    c:part(hat, SM, { band = 1, inner = false, pop = { x = x - 5, y = y - 3 } }) HH.under(c, hat, SM.deep)
    for xx = x - 7, x + 7, 2 do if hat:has(xx, y + 1) then c:put(xx, y + 1, SCF.base) end end
    c:part(c:line({ { x - 1, y - 4 }, { x + (k.p.hs or 0), y - 7 } }, 2), SM, NO)
  end,
  front = function(c, k)
    local b, tw, dr = k.b, k.p.tw or 0, k.p.dr or 0
    local px, py = k.paw.x, k.paw.y
    c:part(c:line({ { px - 1, py + 7 }, { px + 3, py - 4 }, { px + 8 + tw, py - 13 + dr } }, 1), ST, NO)
    c:fillMask(c:line({ { px + 2, py - 2 }, { px + 6, py - 4 } }, 1), ST.hi)
    c:fillMask(c:line({ { px + 4, py - 7 }, { px + 1, py - 9 } }, 1), ST.hi)
    local um = c:ellipse(px + 8 + tw, py - 14 + dr, 4, 1.8)
    c:part(um, UM, { band = 1, inner = false, pop = { x = px + 6 + tw, y = py - 15 + dr } })
  end,
}
