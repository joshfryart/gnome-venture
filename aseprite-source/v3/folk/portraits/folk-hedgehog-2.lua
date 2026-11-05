-- folk-hedgehog-2 portrait (folk F1_0) variant: 2 (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Wanderer hedgehog, 3/4 view: grey-brown spine mound, cream face + long snout + wet nose, pink knit cap perched
-- in the spines, blue jacket, teal scarf, pack strap + bedroll on the back, brass lantern. Blue disc.
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
HH.portrait{ name = "folk-hedgehog-2", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 32,
  BG = { base = "#a4c4dc", shade = "#7898bc", deep = "#56709a" },
  body = function(c, k)
    c:part(k.torso, CLO, { band = 3, inner = false, nopop = true })
    local st = c:line({ { 30, 80 }, { 52, 99 } }, 3):clip(k.torso)
    c:fillMask(st, PACK.base)
    st:each(function(x, y) if not st:has(x + 1, y + 1) then c:put(x, y, PACK.deep) end end)
    for _, y in ipairs{ 88, 94 } do c:put(62, y, BRASS.hi) c:put(63, y, BRASS.base) c:put(62, y + 1, BRASS.base) c:put(63, y + 1, BRASS.shade) end
    local s = c:rrect(30, 72, 66, 79, 3)
    c:part(s, SCARF, { band = 2, nopop = true, inner = false }) HH.under(c, s, SCARF.deep)
    for x = 33, 64, 5 do for y = 73, 78 do if s:has(x, y) then c:put(x, y, SCARF.shade) end end end
    local t = c:poly{ { 54, 77 }, { 61, 77 }, { 62, 94 }, { 55, 94 } }
    c:part(t, SCARF, NO) HH.under(c, t, SCARF.deep)
    for y = 82, 92, 4 do for x = 55, 61 do if t:has(x, y) then c:put(x, y, SCARF.shade) end end end
  end,
  spines = function(c, k)
    local r = c:ellipse(12, 77, 9, 5)
    c:part(r, ROLL, { band = 1, nopop = true, inner = false }) HH.under(c, r, ROLL.deep)
    for y = 72, 82 do for _, x in ipairs{ 7, 17 } do if r:has(x, y) then c:put(x, y, PACK.shade) end end end
    c:put(10, 74, ROLL.hi) c:put(11, 74, ROLL.hi)
  end,
  hat = function(c, k)
    local x, y = k.crown.x + 1, k.crown.y + 3
    local cm = c:ellipse(x, y, 10, 7):clip(c:rect(0, 0, 79, y))
    c:part(cm, CAP, { band = 2, nopop = true, inner = false })
    for xx = x - 8, x + 8, 3 do for yy = y - 7, y do if cm:has(xx, yy) and c:get(xx, yy) == CAP.base:lower() then c:put(xx, yy, CAP.shade) end end end
    local cu = c:rrect(x - 11, y - 2, x + 11, y + 3, 2)
    c:part(cu, CAP, NO) HH.under(c, cu, CAP.deep)
    for xx = x - 10, x + 10, 2 do for yy = y - 1, y + 2 do if cu:has(xx, yy) then c:put(xx, yy, CAP.shade) end end end
    c:part(c:ellipse(x - 2, y - 9, 3.5, 3.5), ROLL, { band = 1, nopop = true, inner = false })
  end,
  front = function(c, k)
    local L = c:rect(62, 76, 73, 90)
    L:add(c:poly{ { 63, 76 }, { 72, 76 }, { 70, 72 }, { 65, 72 } })
    L:add(c:rect(67, 69, 68, 71))
    c:part(L, BRASS, NO)
    c:fillMask(c:rect(64, 78, 71, 88), GL2)
    c:fillMask(c:rect(65, 79, 66, 83), GL1)
    for y = 84, 88 do c:put(70, y, GL3) c:put(71, y, GL3) end
    for y = 78, 88 do c:put(67, y, BRASS.shade) end
    for x = 62, 73 do c:put(x, 77, BRASS.shade) c:put(x, 89, BRASS.shade) end
    local paw = c:ellipse(67, 93, 4, 3) c:part(paw, FACE, NO) HH.under(c, paw, FACE.deep)
  end,
}
