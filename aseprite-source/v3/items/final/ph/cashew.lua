-- cashew (first draft, Sonnet). quirk: the nut hangs on a tiny ring like an earring
local NAME = "cashew"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local AP = { "#7a1c2a", "#b02e36", "#d84a30", "#f07a2e", "#fba83e", "#ffd878" }
-- cashew apple
local ap = H.sweep({ {30, 10}, {36, 8}, {40, 30}, {30, 40} }, function(t) return 4 + t * 7 end)
X.tone(c, ap, X.light(X.pillow(ap, 6), { amb = 0.08, wrap = 0.25 }), AP, { cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 } })
-- waxy streaks
B.ln(c, 28, 18, 26, 30, AP[5], ap) B.ln(c, 33, 16, 34, 26, AP[6], ap)
c:px(27, 14, "#fff4d6") c:px(28, 14, "#fff4d6")
-- stem + leaf
B.ln(c, 31, 10, 31, 6, "#5a7a2a") B.ln(c, 32, 10, 33, 5, "#3a5a24")
B.blade(c, 33, 6, 54, 2, 4.4, LEAF, { veins = { 4, 8, 12 } })
-- nut (kidney) hanging
local nut = H.sweep({ {26, 40}, {36, 40}, {46, 48}, {36, 56} }, function(t) return 3.2 - t * 0.6 end)
H.lit(c, nut, { "#2a2420", "#4a4036", "#6e6252", "#948670", "#b8aa8e", "#dccfb0" }, { R = 2.4 })
c:px(28, 40, "#dccfb0")
-- ring
c:fillMask(c:ellipse(25, 41, 2, 2), "#f5b82e") c:fillMask(c:ellipse(25, 41, 1, 1), "#2b1c26"); c:px(25, 41, "#2b1c26")
D.fin()
