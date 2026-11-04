-- carved-heron (first draft, Sonnet). quirk: a tiny fish carved into its beak
local NAME = "carved-heron"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local WD = { "#3a2018", "#6a3a28", "#8e5a38", "#b07a4a", "#cf9e66", "#ecc890" }
c:groundShadow(32, 58, 14, 2.5)
-- base
local base = c:rrect(18, 52, 46, 58, 2) B.lit(c, base, WD, 3)
for x = 20, 44, 5 do c:px(x, 55, WD[2]) end
-- legs (one raised)
D.rod(c, 30, 52, 30, 38, 1.3, 1.1, WD)
D.rod(c, 34, 44, 40, 48, 1, 0.9, WD)
D.rod(c, 40, 48, 36, 52, 0.9, 1.1, WD)
-- body
local body = B.ell(32, 32, 7, 5.4, -0.2) B.lit(c, body, WD, 4)
-- tail / wing
local wing = c:poly{ {26, 30}, {38, 32}, {44, 40}, {30, 36} } B.lit(c, wing, WD, 2)
for i = 0, 4 do B.ln(c, 28 + i * 2, 31 + i, 33 + i * 2, 35 + i, WD[2], wing) end
-- neck S-curve
local nk = H.sweep({ {26, 30}, {20, 22}, {30, 18}, {24, 8} }, function(t) return 2.0 - t * 0.5 end)
H.lit(c, nk, WD, { R = 2 })
-- head + beak
local hd = B.ell(23, 8, 2.8, 2.4) B.lit(c, hd, WD, 1.8)
local bk = c:poly{ {20, 7}, {8, 11}, {20, 10} } B.lit(c, bk, "gold", 1)
c:fillMask(bk, "#b97a4a") B.ln(c, 20, 8, 9, 11, "#e8b982")
-- eye
c:px(23, 7, "#2b1c26") c:px(22, 6, "#fff4d6")
-- fish carving on beak
c:px(14, 9, "#51302b") c:px(15, 9, "#51302b") c:px(16, 9, "#51302b") c:px(13, 8, "#51302b") c:px(13, 10, "#51302b")
-- crest
B.ln(c, 26, 7, 33, 5, WD[2]) B.ln(c, 26, 8, 31, 8, WD[4])
D.fin()
