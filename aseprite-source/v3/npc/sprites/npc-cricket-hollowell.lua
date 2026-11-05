-- npc-cricket-hollowell sprite (npc2 P1_8) species: hedgehog (rewrite 2026-11-05, shared lib/hedgehog.lua)
-- Shy round hedgehog, 3/4 view facing right: big spine mound over crown + back, long snout, wet nose, startled 'o' mouth,
-- pale belly; quirk: a red apple skewered on her back quills. idle(4): base / breath (apple + leaf settle) / base / blink.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local P = HH.P
local SP = { deep = "#3c2840", shade = "#5a3c4c", base = "#80573a", hi = "#b0804e", tip = "#efd6a2" }
local FACE = { hi = "#f8e6c4", base = "#e6c294", shade = "#b98c7c", deep = "#80606c" }
local APL = { hi = "#ff9070", base = "#da443c", shade = "#9c2c48", deep = "#621c3e" }
local LEAF = { hi = "#aad85c", base = "#62aa3e", shade = "#3c7248", deep = "#26484c" }
local FUR = { hi = "#c49a74", base = "#9a7058", shade = "#6e4c48", deep = "#4a3040" }
local NO = { band = 1, nopop = true, inner = false }
HH.sprite{ name = "npc-cricket-hollowell", out = app.params.out or (DIR .. "/"), SP = SP, FACE = FACE, seed = 8,
  faceOpts = { mouthO = true }, sleeve = FUR,
  body = function(c, k)
    c:part(k.torso, FUR, { band = 2, inner = false, nopop = true })
    local bel = c:ellipse(k.X(8), 72 + k.b * 0.5, 7, 12.5):clip(k.torso)
    c:part(bel, FACE, { band = 2, inner = false, pop = { x = k.X(5), y = 63 + k.b } })
  end,
  frames = { {}, { b = 1, lf = 1 }, {}, { blink = true } },
  spines = function(c, k)
    local ay = 58 + k.b
    local ap = c:ellipse(12, ay, 3.5, 3.2)
    c:part(ap, APL, { band = 1, inner = false, pop = { x = 10, y = ay - 2 } })
    HH.under(c, ap, APL.deep)
    c:put(12, ay - 4, SP.deep) c:put(13, ay - 5, SP.deep)
    local lf = k.p.lf or 0
    local m = c:poly{ { 14, ay - 5 }, { 17, ay - 7 + lf }, { 18, ay - 5 + lf }, { 15, ay - 4 } }
    c:part(m, LEAF, NO)
  end,
}
