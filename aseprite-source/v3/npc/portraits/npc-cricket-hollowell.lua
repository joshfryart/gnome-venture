-- npc-cricket-hollowell portrait (npc2 P1_8) species: hedgehog (front view 2026-11-05, HH.portraitFront in lib/hedgehog.lua)
-- Shy round hedgehog, head-on: spine arch, cream face mask, bead eyes, short snout + wet nose, startled little 'o' mouth,
-- pale belly with paws folded on it; quirk: a red apple skewered on her quills. Green disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3c2840", shade = "#5a3c4c", base = "#80573a", hi = "#b0804e", tip = "#efd6a2" }
local FACE = { hi = "#f8e6c4", base = "#e6c294", shade = "#b98c7c", deep = "#80606c" }
local APL = { hi = "#ff9070", base = "#da443c", shade = "#9c2c48", deep = "#621c3e" }
local LEAF = { hi = "#aad85c", base = "#62aa3e", shade = "#3c7248", deep = "#26484c" }
local FUR = { hi = "#c49a74", base = "#9a7058", shade = "#6e4c48", deep = "#4a3040" }
local NO = { band = 1, nopop = true, inner = false }
HH.portraitFront{ name = "npc-cricket-hollowell", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 8,
  BG = { base = "#8cc06a", shade = "#64a052", deep = "#447648" }, faceOpts = { mouthO = true },
  body = function(c, k)
    c:part(k.torso, FUR, { band = 2, inner = false, nopop = true })
    local bel = c:ellipse(39.5, 98, 15, 22):clip(k.torso)
    c:part(bel, FACE, { band = 2, inner = false, pop = { x = 33, y = 80 } })
    for i = 0, 5 do local x, y = 30 + i * 4 + (i % 2), 80 + (i % 3) * 5
      if bel:has(x, y) and bel:has(x + 1, y + 2) then c:put(x, y, FACE.shade) c:put(x + 1, y + 1, FACE.shade) end end
    HH.pawFront(c, k, 34, 91, 3.5, 2.8) HH.pawFront(c, k, 45, 91, 3.5, 2.8)
  end,
  spines = function(c, k)
    c:fillMask(c:line({ { 19, 52 }, { 14, 45 } }, 1), SP.deep)
    local ap = c:ellipse(13, 42, 5.5, 5)
    c:part(ap, APL, { band = 2, inner = false, pop = { x = 10, y = 39 } })
    HH.under(c, ap, APL.deep)
    c:put(11, 39, P.cream)
    c:fillMask(c:line({ { 13, 37 }, { 14, 33 } }, 1), SP.deep)
    local lf = c:poly{ { 15, 35 }, { 21, 31 }, { 22, 34 }, { 17, 37 } }
    c:part(lf, LEAF, NO) c:put(18, 34, LEAF.hi)
  end,
}
