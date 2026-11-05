-- folk-hedgehog-1 sprite (folk F1_0) variant: 1 (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Gardener hedgehog, 3/4 view facing right: spine mound over crown + back, long snout + wet nose,
-- straw hat with blue ribbon + leaf perched in the spines, peach shirt, green dungarees; trowel in the paw. idle(4).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local function R4(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local SP = { hi = "#c99a5e", base = "#8f5f3a", shade = "#5e3a35", deep = "#3d2532", tip = "#f0d8a8" }
local FACE = R4("#f6dfb0", "#e0b986", "#b38469", "#7d5763")
local SHIRT = R4("#f4c890", "#d89a5c", "#a0664c", "#6a4040")
local CLO = R4("#9cc46a", "#6a9a48", "#46704a", "#2f4a42")
local STRAW = R4("#f7df85", "#e0b453", "#b07f45", "#7a5040")
local RIB = R4("#9ad0f0", "#5a9ad0", "#3e6aa0", "#2c4470")
local LEAF = R4("#b8e07a", "#7cb84a", "#4e8a44", "#2f5a3e")
local METAL = R4("#e6ecee", "#a9b4c4", "#6f7894", "#474a68")
local WOOD = R4("#d39a5c", "#a5683c", "#714434", "#4a2c2e")
local NO = { band = 1, nopop = true, inner = false }
HH.sprite{ name = "folk-hedgehog-1", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 31, sleeve = SHIRT,
  frames = { {}, { b = 1, pl = 1 }, {}, { blink = true } },
  body = function(c, k)
    local b = k.b
    local sh = k.torso:copy():clip(c:rect(0, k.neck, 63, 95))
    c:part(sh, SHIRT, { band = 2, inner = false, nopop = true }) HH.under(c, sh, SHIRT.deep)
    local d = sh:copy():clip(c:rect(0, 70 + b, 63, 95))
    d:add(c:line({ { 27, 70 + b }, { 25, k.neck + 2 } }, 2)) d:add(c:line({ { 38, 70 + b }, { 39, k.neck + 2 } }, 2))
    d:clip(sh)
    c:part(d, CLO, { band = 2, inner = false, nopop = true }) HH.under(c, d, CLO.deep)
    for x = 29, 36, 2 do c:put(x, 74 + b, CLO.deep) end
    c:put(26, 70 + b, STRAW.hi) c:put(38, 70 + b, STRAW.hi)
  end,
  hat = function(c, k)
    local x, y = k.crown.x + 1, k.crown.y + 3
    local brim = c:ellipse(x, y, 10, 2)
    local hm = brim:copy():add(c:rrect(x - 6, y - 7, x + 5, y, 3))
    c:part(hm, STRAW, { band = 1, nopop = true, inner = false })
    brim:each(function(px, py) if not brim:has(px, py + 1) then c:put(px, py, STRAW.deep) end end)
    for px = x - 4, x + 2 do c:put(px, y - 7, STRAW.hi) end
    c:part(c:rect(x - 6, y - 3, x + 5, y - 2), RIB, NO)
    local l = c:ellipse(x - 8, y - 3, 2, 1.2) c:part(l, LEAF, NO)
  end,
  front = function(c, k)
    local px, py = k.paw.x, k.paw.y + (k.p.pl or 0) - (k.p.pl and 1 or 0)
    c:part(c:rect(px, py - 5, px + 1, py + 1), WOOD, NO)
    c:part(c:rect(px, py + 3, px + 1, py + 4), METAL, NO)
    local bl = c:poly{ { px - 2, py + 5 }, { px + 3, py + 5 }, { px + 2, py + 11 }, { px + 1, py + 12 }, { px, py + 12 }, { px - 1, py + 11 } }
    c:part(bl, METAL, NO) c:put(px - 1, py + 6, METAL.hi)
    for yy = 6, 10 do c:put(px + 1, py + yy, METAL.shade) end
  end,
}
