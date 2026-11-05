-- npc-cricket-hollowell portrait (npc2 P1_8) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Shy round hedgehog, 3/4 view: big spine mound, cream face + long snout, wet nose, startled little 'o' mouth,
-- pale belly; quirk: a red apple skewered on her back quills. Green disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3c2840", shade = "#5a3c4c", base = "#80573a", hi = "#b0804e", tip = "#efd6a2" }
local FACE = { hi = "#f8e6c4", base = "#e6c294", shade = "#b98c7c", deep = "#80606c" }
local APL = { hi = "#ff9070", base = "#da443c", shade = "#9c2c48", deep = "#621c3e" }
local LEAF = { hi = "#aad85c", base = "#62aa3e", shade = "#3c7248", deep = "#26484c" }
local FUR = { hi = "#c49a74", base = "#9a7058", shade = "#6e4c48", deep = "#4a3040" }
local NO = { band = 1, nopop = true, inner = false }
HH.portrait{ name = "npc-cricket-hollowell", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 8,
  BG = { base = "#8cc06a", shade = "#64a052", deep = "#447648" }, faceOpts = { mouthO = true },
  body = function(c, k)
    c:part(k.torso, FUR, { band = 2, inner = false, nopop = true })
    local bel = c:ellipse(51, 100, 15, 19):clip(k.torso)
    c:part(bel, FACE, { band = 2, inner = false, pop = { x = 43, y = 85 } })
    for i = 0, 7 do local x, y = 30 + i * 5 + (i % 2), 82 + (i % 3) * 5
      if bel:has(x, y) and bel:has(x + 1, y + 2) then c:put(x, y, FACE.shade) c:put(x + 1, y + 1, FACE.shade) end end
    for _, q in ipairs{ { 54, 92 }, { 64, 90 } } do local m = c:ellipse(q[1], q[2], 3.5, 2.8) c:part(m, FACE, NO) HH.under(c, m, FACE.deep)
      c:put(q[1] - 1, q[2] + 1, FACE.shade) c:put(q[1] + 1, q[2] + 1, FACE.shade) end
  end,
  spines = function(c, k)
    c:fillMask(c:line({ { 18, 58 }, { 13, 50 } }, 1), SP.deep)
    local ap = c:ellipse(14, 47, 5.5, 5)
    c:part(ap, APL, { band = 2, inner = false, pop = { x = 11, y = 44 } })
    HH.under(c, ap, APL.deep)
    c:put(12, 44, P.cream)
    c:fillMask(c:line({ { 14, 42 }, { 15, 38 } }, 1), SP.deep)
    local lf = c:poly{ { 16, 40 }, { 22, 36 }, { 23, 39 }, { 18, 42 } }
    c:part(lf, LEAF, NO) c:put(19, 39, LEAF.hi)
  end,
}
