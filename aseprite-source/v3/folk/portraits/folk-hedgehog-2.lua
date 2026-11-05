-- folk-hedgehog-2 portrait (folk F1_0) variant: 2 (front view 2026-11-05, HH.portraitFront in lib/hedgehog.lua)
-- Wanderer hedgehog, head-on: grey-brown spine arch, cream face, bead eyes, short snout + wet nose, pink knit cap perched
-- in the spines, blue jacket, teal scarf, pack strap + bedroll behind the shoulder, brass lantern in the right paw. Blue disc.
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
HH.portraitFront{ name = "folk-hedgehog-2", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 32,
  BG = { base = "#a4c4dc", shade = "#7898bc", deep = "#56709a" },
  behind = function(c, k)
    local r = c:ellipse(12, 72, 9, 5)
    c:part(r, ROLL, { band = 1, nopop = true, inner = false }) HH.under(c, r, ROLL.deep)
    for y = 67, 77 do for _, x in ipairs{ 7, 17 } do if r:has(x, y) then c:put(x, y, PACK.shade) end end end
    c:put(10, 69, ROLL.hi) c:put(11, 69, ROLL.hi)
  end,
  body = function(c, k)
    c:part(k.torso, CLO, { band = 3, inner = false, nopop = true })
    local st = c:line({ { 21, 78 }, { 44, 99 } }, 3):clip(k.torso)
    c:fillMask(st, PACK.base)
    st:each(function(x, y) if not st:has(x + 1, y + 1) then c:put(x, y, PACK.deep) end end)
    for _, y in ipairs{ 86, 92 } do c:put(52, y, BRASS.hi) c:put(53, y, BRASS.base) c:put(52, y + 1, BRASS.base) c:put(53, y + 1, BRASS.shade) end
    local s = c:rrect(22, 68, 57, 75, 3)
    c:part(s, SCARF, { band = 2, nopop = true, inner = false }) HH.under(c, s, SCARF.deep)
    for x = 25, 56, 5 do for y = 69, 74 do if s:has(x, y) then c:put(x, y, SCARF.shade) end end end
    local t = c:poly{ { 44, 74 }, { 51, 74 }, { 52, 91 }, { 45, 91 } }
    c:part(t, SCARF, NO) HH.under(c, t, SCARF.deep)
    for y = 79, 89, 4 do for x = 45, 51 do if t:has(x, y) then c:put(x, y, SCARF.shade) end end end
  end,
  hat = function(c, k)
    local x, y = k.crown.x, k.crown.y + 3
    local cm = c:ellipse(x, y, 10, 7):clip(c:rect(0, 0, 79, y))
    c:part(cm, CAP, { band = 2, nopop = true, inner = false })
    for xx = x - 8, x + 8, 3 do for yy = y - 7, y do if cm:has(xx, yy) and c:get(xx, yy) == CAP.base:lower() then c:put(xx, yy, CAP.shade) end end end
    local cu = c:rrect(x - 11, y - 2, x + 11, y + 3, 2)
    c:part(cu, CAP, NO) HH.under(c, cu, CAP.deep)
    for xx = x - 10, x + 10, 2 do for yy = y - 1, y + 2 do if cu:has(xx, yy) then c:put(xx, yy, CAP.shade) end end end
    c:part(c:ellipse(x - 2, y - 9, 3.5, 3.5), ROLL, { band = 1, nopop = true, inner = false })
  end,
  front = function(c, k)
    local L = c:rect(57, 76, 68, 90)
    L:add(c:poly{ { 58, 76 }, { 67, 76 }, { 65, 72 }, { 60, 72 } })
    L:add(c:rect(62, 69, 63, 71))
    c:part(L, BRASS, NO)
    c:fillMask(c:rect(59, 78, 66, 88), GL2)
    c:fillMask(c:rect(60, 79, 61, 83), GL1)
    for y = 84, 88 do c:put(65, y, GL3) c:put(66, y, GL3) end
    for y = 78, 88 do c:put(62, y, BRASS.shade) end
    for x = 57, 68 do c:put(x, 77, BRASS.shade) c:put(x, 89, BRASS.shade) end
    HH.pawFront(c, k, 62, 93, 4, 3)
  end,
}
