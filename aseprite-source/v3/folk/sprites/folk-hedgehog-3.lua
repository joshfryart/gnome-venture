-- folk-hedgehog-3 sprite (folk F1_0) variant: 3 (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Cook hedgehog, 3/4 view facing right: dark brown spine mound, long snout + wet nose, small red polka-dot kerchief
-- tied on the crown, mustard shirt, cream apron; prop: copper ladle of soup. idle(4): base / breath / base / blink + ladle tip.
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
HH.sprite{ name = "folk-hedgehog-3", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 33, sleeve = CLO,
  frames = { {}, { b = 1, pl = 1 }, {}, { blink = true, tw = -1 } },
  body = function(c, k)
    local b = k.b
    local sh = k.torso:copy():clip(c:rect(0, k.neck, 63, 95))
    c:part(sh, CLO, { band = 2, inner = false, nopop = true }) HH.under(c, sh, CLO.deep)
    local a = c:rrect(27, 67 + b, 43, 86, 2)
    a:add(c:line({ { 29, 67 + b }, { 30, k.neck + 1 } }, 1)) a:add(c:line({ { 41, 67 + b }, { 40, k.neck + 1 } }, 1))
    a:clip(sh)
    c:part(a, APR, { band = 1, nopop = true, inner = false }) HH.under(c, a, APR.deep)
    for x = 30, 39 do c:put(x, 75 + b, APR.shade) end
  end,
  hat = function(c, k)
    local x, y = k.crown.x + 1, k.crown.y + 3
    local kh = c:ellipse(x, y, 7, 5):clip(c:rect(0, 0, 63, y))
    kh:add(c:rrect(x - 8, y - 1, x + 7, y + 1, 1))
    c:part(kh, KER, { band = 1, nopop = true, inner = false }) HH.under(c, kh, KER.deep)
    for _, q in ipairs{ { -3, -3 }, { 2, -2 }, { -1, -1 }, { 4, 0 }, { -6, 0 } } do c:put(x + q[1], y + q[2], APR.hi) end
    local kn = c:poly{ { x - 8, y }, { x - 13, y + 4 }, { x - 11, y + 5 }, { x - 7, y + 1 } }
    kn:add(c:poly{ { x - 8, y - 1 }, { x - 14, y - 3 }, { x - 13, y }, { x - 8, y } })
    c:part(kn, KER, NO)
  end,
  front = function(c, k)
    local y, tw = k.p.pl or 0, k.p.tw or 0
    local px, py = k.paw.x, k.paw.y
    c:part(c:line({ { px, py + 1 }, { px + 3, py - 10 + y } }, 2), COP, NO)
    local bw = c:ellipse(px + 5 + tw, py - 13 + y, 4, 2.5)
    c:part(bw, COP, NO)
    c:fillMask(c:ellipse(px + 5 + tw, py - 14 + y, 2.5, 1), SOUP)
    c:put(px + 6 + tw, py - 14 + y, CARROT)
  end,
}
