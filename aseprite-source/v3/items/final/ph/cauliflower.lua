-- cauliflower (first draft, Sonnet). quirk: a small caterpillar snoozes between two curds
local NAME = "cauliflower"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local CU = { "#8a7a50", "#bcae7c", "#dccd9a", "#efe4b8", "#fbf3d4", "#fffdf0" }
-- outer leaves
local LF = { "#173f36", "#2a6a3e", "#3e8a46", "#5aa650", "#80c060", "#b0dc80" }
B.blade(c, 32, 56, 6, 28, 8, LF, { veins = { 8, 14, 20 } })
B.blade(c, 32, 56, 58, 28, 8, LF, { veins = { 8, 14, 20 } })
B.blade(c, 32, 58, 20, 8, 6.4, LF, { veins = { 10, 18 } })
B.blade(c, 32, 58, 46, 10, 6, LF, { veins = { 10, 18 } })
-- head
local hd = B.ell(32, 32, 17, 14) B.lit(c, hd, CU, 12)
-- curds: small bumps
for _, p in ipairs{ {22, 26, 5}, {31, 22, 5}, {40, 26, 5}, {26, 34, 5}, {36, 34, 5}, {44, 34, 4}, {20, 36, 4}, {32, 42, 5}, {24, 42, 4}, {41, 42, 4} } do
  local m = B.ell(p[1], p[2], p[3], p[3] - 0.6) B.lit(c, m, CU, p[3] - 1)
  c:fillMask(c:rect(p[1] - 1, p[2] - 2, p[1], p[2] - 2), CU[6])
end
-- caterpillar
for i = 0, 3 do local m = B.ell(29 + i * 3, 38 - (i % 2), 1.8, 1.8) B.lit(c, m, "moss", 1.2) end
c:px(41, 37, "#2b1c26") c:px(40, 36, "#fff4d6")
D.fin()
