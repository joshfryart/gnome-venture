-- folk-hedgehog-3 portrait (folk F1_0) variant: 3 (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Cook hedgehog, 3/4 view: dark brown spine mound, cream face + long snout + wet nose, small red polka-dot kerchief
-- tied on the crown (knot tails trailing back through the spines), mustard shirt, cream apron, copper ladle of soup. Peach disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local function R4(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local SP = { hi = "#a06a48", base = "#6a3f2e", shade = "#46283a", deep = "#3a2236", tip = "#e6c79c" }
local FACE = R4("#f6dfb0", "#e0b986", "#b38469", "#7d5763")
local CLO = R4("#f2cb6a", "#d69c3a", "#a06a3a", "#6a4236")
local KER = R4("#f08a6e", "#d0503e", "#963648", "#5e2440")
local APR = R4("#fbf1d8", "#ecdcb8", "#c3aea0", "#8a7884")
local COP = R4("#f4b27c", "#cf7a48", "#9a4c40", "#64303a")
local SOUP, CARROT = "#f2b45a", "#e8703a"
local NO = { band = 1, nopop = true, inner = false }
HH.portrait{ name = "folk-hedgehog-3", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 33,
  BG = { base = "#f0b88a", shade = "#d08c68", deep = "#a2644e" },
  body = function(c, k)
    c:part(k.torso, CLO, { band = 3, inner = false, nopop = true })
    local a = c:rrect(34, 84, 60, 99, 2)
    a:add(c:line({ { 36, 85 }, { 38, 77 } }, 2)) a:add(c:line({ { 58, 85 }, { 56, 77 } }, 2))
    a:clip(k.torso)
    c:part(a, APR, { band = 2, nopop = true, inner = false })
    for x = 39, 55 do c:put(x, 92, APR.shade) end for y = 93, 98 do c:put(39, y, APR.shade) c:put(55, y, APR.shade) end
  end,
  hat = function(c, k)
    local x, y = k.crown.x + 1, k.crown.y + 4
    local kh = c:ellipse(x, y, 11, 8):clip(c:rect(0, 0, 79, y))
    kh:add(c:rrect(x - 12, y - 1, x + 11, y + 2, 1))
    c:part(kh, KER, { band = 2, nopop = true, inner = false }) HH.under(c, kh, KER.deep)
    kh:each(function(px, py) if (px + 2 * py) % 6 == 0 and py % 3 == 0 and c:get(px, py) == KER.base:lower() then c:put(px, py, APR.hi) end end)
    local kn = c:ellipse(x - 12, y, 2.5, 2)
    kn:add(c:poly{ { x - 13, y + 1 }, { x - 20, y + 6 }, { x - 17, y + 8 }, { x - 12, y + 2 } })
    kn:add(c:poly{ { x - 13, y - 1 }, { x - 21, y - 4 }, { x - 20, y + 1 }, { x - 13, y + 1 } })
    c:part(kn, KER, NO) HH.under(c, kn, KER.deep)
  end,
  front = function(c, k)
    c:part(c:line({ { 66, 96 }, { 64, 72 } }, 3), COP, NO)
    c:part(c:ellipse(66, 68, 7, 4.5), COP, { band = 2, nopop = true, inner = false })
    c:fillMask(c:ellipse(66, 67, 5, 2), SOUP)
    c:put(67, 67, CARROT) c:put(63, 66, CARROT) c:put(61, 66, COP.hi) c:put(62, 65, COP.hi)
    local paw = c:ellipse(65, 92, 4, 3.5) c:part(paw, FACE, NO) HH.under(c, paw, FACE.deep)
  end,
}
