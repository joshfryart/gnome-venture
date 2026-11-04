-- carrot-cake (first draft, Sonnet). quirk: a single walnut half balances on a cream swirl
local NAME = "carrot-cake"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local CK = { "#4a2410", "#7a3e1c", "#a65a26", "#c8783a", "#e29a56", "#f4be82" }
local CRM = { "#a8987a", "#d0c0a0", "#ece0c0", "#f8f0d8", "#fffaec", "#ffffff" }
CRM[6] = "#fff8e8"
c:groundShadow(32, 56, 22, 3)
-- plate
c:fillMask(B.ell(32, 54, 24, 4), "#e4f6ff") c:fillMask(B.ell(32, 53, 20, 3), "#b9e2f5")
-- slice (wedge front face) 
local face = c:poly{ {12, 30}, {40, 30}, {44, 52}, {14, 52} }
face = c:rect(12, 30, 42, 52)
-- layers
local l1 = c:rect(12, 40, 42, 52) H.vcyl(c, l1, CK, 6, 48)
local l2 = c:rect(12, 30, 42, 37) H.vcyl(c, l2, CK, 6, 48)
-- cream filling
c:fillMask(c:rect(12, 37, 42, 39), CRM[4]) c:fillMask(c:rect(12, 39, 42, 39), CRM[2])
-- carrot flecks and raisins
for _, p in ipairs{ {16, 33}, {24, 34}, {33, 32}, {20, 44}, {30, 47}, {37, 43}, {16, 49} } do c:px(p[1], p[2], "#ee6c22") c:px(p[1] + 1, p[2], "#fb983a") end
for _, p in ipairs{ {27, 33}, {14, 45}, {36, 49} } do c:px(p[1], p[2], "#4a2a5a") end
-- top frosting with drip
local fr = c:rect(11, 25, 43, 30) B.lit(c, fr, CRM, 2)
for _, d in ipairs{ {15, 3}, {22, 5}, {30, 2}, {38, 4} } do c:fillMask(c:rect(d[1], 31, d[1] + 2, 30 + d[2]), CRM[4]) end
-- swirl + walnut
c:fillMask(B.ell(27, 22, 5, 3), CRM[4]) c:fillMask(B.ell(27, 20, 3, 2), CRM[5])
local wn = B.ell(28, 17, 3.4, 2.6) B.lit(c, wn, { "#4a2a14", "#6a4020", "#8a5a30", "#a87a48", "#c8a068", "#e4c890" }, 2)
c:px(28, 16, "#4a2a14") c:px(28, 18, "#4a2a14")
-- carrot candy at left
c:fillMask(c:poly{ {17, 20}, {22, 22}, {19, 28} }, "#ee6c22") c:px(18, 22, "#ffc874") c:fillMask(c:rect(16, 17, 18, 19), "#5aa650")
D.fin()
