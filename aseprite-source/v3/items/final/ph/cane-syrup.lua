-- cane-syrup (first draft, Sonnet). quirk: a bee has landed on the lid
local NAME = "cane-syrup"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local AMB = { "#4a1c14", "#7a3016", "#b0521c", "#d97a22", "#f0a838", "#ffd870" }
c:groundShadow(30, 57, 17, 3)
-- cane stalk behind
local st = D.rod(c, 46, 56, 54, 12, 2.2, 2, { "#3a1a3a", "#5a2a5a", "#7a3e7a", "#9a58a0", "#b878bc", "#d8a0d8" })
for _, t in ipairs{ 0.25, 0.5, 0.75 } do local y = floor(56 - 44 * t) c:fillMask(c:rect(44 + floor(8 * t), y, 56 - floor(0 * t) - 2 + floor(0), y), "#2a1030") end
-- jar
local jar = c:rrect(14, 24, 40, 56, 5)
local n = H.vcyl(c, jar, "sea", 14, 40)
local glass = c:rrect(16, 26, 38, 55, 4)
-- syrup
local syr = c:rrect(16, 33, 38, 55, 4)
H.vcyl(c, syr, AMB, 16, 38)
c:fillMask(c:rect(16, 33, 38, 34), AMB[6])
c:px(19, 38, "#fff4d6") c:px(19, 39, "#fff4d6") c:px(20, 37, "#ffe8a8")
-- label
c:fillMask(c:rrect(20, 42, 34, 51, 1), "#f0e2b8")
c:fillMask(c:rect(20, 50, 34, 51), "#c8b078")
for i = 0, 3 do c:px(22 + i * 3, 46, "#7a3016") c:px(23 + i * 3, 47, "#b0521c") end
-- lid
local lid = c:rrect(17, 18, 37, 25, 2)
B.lit(c, lid, "gold", 2)
for x = 19, 35, 3 do c:px(x, 21, "#8f4a1f") end
-- drip
c:fillMask(c:rect(38, 28, 38, 32), AMB[4]) c:px(38, 33, AMB[5])
-- bee
local bm = B.ell(30, 15, 2.6, 1.8) B.lit(c, bm, "gold", 1.5)
c:px(29, 14, "#2b1c26") c:px(29, 16, "#2b1c26") c:px(31, 14, "#2b1c26") c:px(31, 16, "#2b1c26")
c:px(28, 12, "#e4f6ff") c:px(29, 12, "#e4f6ff") c:px(30, 12, "#e4f6ff")
D.fin()
