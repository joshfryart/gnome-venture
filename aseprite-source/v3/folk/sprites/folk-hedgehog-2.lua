-- folk-hedgehog-2 sprite (folk F1_0) variant: 2 (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Wanderer hedgehog, 3/4 view facing right: grey-brown spine mound, long snout + wet nose, pink knit cap perched in
-- the spines, blue jacket, teal scarf, bedroll strapped low on the back; prop: brass lantern swinging in the paw. idle(4).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local function R4(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local SP = { hi = "#b8a48c", base = "#7f6a5e", shade = "#54465a", deep = "#372c40", tip = "#ece2cf" }
local FACE = R4("#f6dfb0", "#e0b986", "#b38469", "#7d5763")
local CLO = R4("#8fa6d0", "#5d74a8", "#414f80", "#2e3458")
local CAP = R4("#d67a9c", "#a84a78", "#74345e", "#4a2448")
local SCARF = R4("#7fd0c4", "#3f9e9c", "#2e6c78", "#234a5a")
local PACK = R4("#d19a62", "#9c6640", "#6a4238", "#45293a")
local ROLL = R4("#efd9a8", "#cdb07e", "#9a8070", "#6a5866")
local BRASS = R4("#f2d27a", "#c99a3e", "#8a6034", "#5a3a30")
local GL1, GL2, GL3 = "#fff0a8", "#f7c75a", "#e8913f"
local NO = { band = 1, nopop = true, inner = false }
HH.sprite{ name = "folk-hedgehog-2", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 32, sleeve = CLO,
  frames = { {}, { b = 1, pl = 1 }, {}, { blink = true, sx = 1 } },
  body = function(c, k)
    local b = k.b
    local j = k.torso:copy():clip(c:rect(0, k.neck, 63, 95))
    c:part(j, CLO, { band = 2, inner = false, nopop = true }) HH.under(c, j, CLO.deep)
    c:fillMask(c:line({ { 24, k.neck + 3 }, { 36, 84 } }, 1):clip(j), PACK.base)
    local s = c:rrect(22, k.neck - 1, 42, k.neck + 2, 1)
    c:part(s, SCARF, { band = 1, inner = false, nopop = true })
    local t = c:poly{ { 34, k.neck + 2 }, { 38, k.neck + 2 }, { 39, k.neck + 10 }, { 35, k.neck + 10 } }
    c:part(t, SCARF, NO) HH.under(c, t, SCARF.deep)
  end,
  spines = function(c, k)
    local b = k.b
    local r = c:ellipse(14, 76 + b, 5.5, 3)
    c:part(r, ROLL, NO) HH.under(c, r, ROLL.deep)
    for _, x in ipairs{ 11, 17 } do for y = 73, 79 do if r:has(x, y + b) then c:put(x, y + b, PACK.shade) end end end
  end,
  hat = function(c, k)
    local x, y = k.crown.x + 1, k.crown.y + 2
    local cm = c:ellipse(x, y, 6.5, 4.5):clip(c:rect(0, 0, 63, y))
    c:part(cm, CAP, { band = 1, nopop = true, inner = false })
    local cu = c:rrect(x - 7, y - 1, x + 7, y + 1, 1)
    c:part(cu, CAP, NO) HH.under(c, cu, CAP.deep)
    for xx = x - 6, x + 6, 2 do c:put(xx, y, CAP.shade) end
    c:part(c:ellipse(x - 1, y - 6, 2, 2), ROLL, NO)
  end,
  front = function(c, k)
    local x0 = k.paw.x - 2 + (k.p.sx or 0)
    local y = k.paw.y + 2 + (k.p.pl or 0)
    c:put(k.paw.x, k.paw.y + 1, BRASS.deep)
    local L = c:rect(x0, y + 1, x0 + 5, y + 8) L:add(c:rect(x0 + 1, y, x0 + 4, y))
    c:part(L, BRASS, NO)
    c:fillMask(c:rect(x0 + 1, y + 3, x0 + 4, y + 6), GL2)
    c:put(x0 + 1, y + 3, GL1) c:put(x0 + 2, y + 4, GL1) c:put(x0 + 4, y + 6, GL3) c:put(x0 + 4, y + 5, GL3)
    for x = x0, x0 + 5 do c:put(x, y + 2, BRASS.shade) c:put(x, y + 7, BRASS.shade) end
  end,
}
