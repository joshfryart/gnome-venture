-- folk-hedgehog-1 portrait (folk F1_0) variant: 1 (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Gardener hedgehog, 3/4 view: big swept-back spine mound, cream face mask + long snout + wet nose,
-- straw hat with a blue ribbon and leaf perched in the spines, peach shirt, green dungarees, trowel. Green disc.
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
HH.portrait{ name = "folk-hedgehog-1", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 31,
  BG = { base = "#a8c886", shade = "#7fa266", deep = "#5b7c50" },
  body = function(c, k)
    c:part(k.torso, SHIRT, { band = 2, inner = false, nopop = true })
    local d = c:rrect(34, 85, 62, 99, 2)
    d:add(c:line({ { 36, 86 }, { 31, 77 } }, 3)) d:add(c:line({ { 60, 86 }, { 64, 77 } }, 3))
    d:clip(k.torso)
    c:part(d, CLO, { band = 2, inner = false, nopop = true })
    for x = 40, 56, 2 do c:put(x, 91, CLO.deep) end
    for y = 92, 98 do c:put(40, y, CLO.shade) c:put(56, y, CLO.shade) end
    for _, q in ipairs{ { 35, 86 }, { 59, 86 } } do c:put(q[1], q[2], STRAW.hi) c:put(q[1] + 1, q[2], STRAW.base) c:put(q[1], q[2] + 1, STRAW.base) c:put(q[1] + 1, q[2] + 1, STRAW.shade) end
  end,
  hat = function(c, k)
    local x, y = k.crown.x + 1, k.crown.y + 4
    local brim = c:ellipse(x, y, 16, 3.5)
    local hm = brim:copy():add(c:rrect(x - 9, y - 11, x + 8, y, 4))
    c:part(hm, STRAW, { band = 2, nopop = true, inner = false })
    hm:each(function(px, py) if (px + py * 3) % 5 == 0 and c:get(px, py) == STRAW.base:lower() then c:put(px, py, STRAW.shade) end end)
    brim:each(function(px, py) if not brim:has(px, py + 1) then c:put(px, py, STRAW.deep) end end)
    for px = x - 6, x + 3 do c:put(px, y - 10, STRAW.hi) end
    c:part(c:rect(x - 9, y - 4, x + 8, y - 2), RIB, NO)
    local l = c:ellipse(x - 12, y - 4, 3.5, 2) l:add(c:ellipse(x - 9, y - 8, 2, 3.5))
    c:part(l, LEAF, NO)
    for px = x - 14, x - 10 do c:put(px, y - 4, LEAF.shade) end
  end,
  front = function(c, k)
    c:part(c:rrect(64, 76, 68, 88, 1), WOOD, NO)
    for y = 78, 86, 3 do c:put(65, y, WOOD.shade) end
    c:part(c:rect(64, 73, 68, 75), METAL, NO)
    local bl = c:poly{ { 61, 73 }, { 71, 73 }, { 67, 62 }, { 65, 62 } }
    c:part(bl, METAL, { band = 2, nopop = true, inner = false })
    for y = 65, 72 do c:put(66, y, METAL.shade) end c:put(63, 70, METAL.hi) c:put(64, 67, METAL.hi)
    local paw = c:ellipse(66, 90, 4, 3.5) c:part(paw, FACE, NO) HH.under(c, paw, FACE.deep)
  end,
}
