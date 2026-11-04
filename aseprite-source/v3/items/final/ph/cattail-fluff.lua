-- cattail-fluff (first draft, Sonnet). quirk: a seed parachute drifts off alone
local NAME = "cattail-fluff"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local BR = { "#2a1410", "#4a2a1a", "#6e3e22", "#8e5a30", "#b07a42", "#d0a064" }
-- stalk
D.rod(c, 20, 58, 26, 22, 1.2, 1.0, { "#2e4a22", "#4a6a2e", "#6a8a3e", "#8aae54", "#aad070", "#cae890" })
-- seed head, burst on top half
local hd = B.ell(26, 22, 3.4, 8, 0.05) B.lit(c, hd, BR, 3)
for i = 1, 6 do c:px(24 + (i % 2) * 3, 16 + i * 2, BR[2]) end
-- fluff cloud
local FL = { "#a8a8c8", "#c8c8e0", "#e4e4f2", "#f6f6fc", "#ffffff", "#ffffff" }
FL[5] = "#fff8f0" FL[6] = "#fffdf6"
for _, p in ipairs{ {36, 18, 6, 5}, {42, 26, 7, 5}, {34, 28, 5, 4}, {46, 36, 6, 4}, {40, 40, 5, 4}, {30, 38, 4, 3} } do
  local m = B.ell(p[1], p[2], p[3], p[4]) B.lit(c, m, FL, 2.5)
end
-- wisps
for _, p in ipairs{ {16, 14}, {12, 24}, {50, 20}, {52, 46}, {24, 46} } do
  c:px(p[1], p[2], "#fffdf6") c:px(p[1] + 1, p[2] - 1, "#e4e4f2") c:px(p[1] - 1, p[2] + 1, "#e4e4f2")
end
-- parachute seed (quirk)
B.ln(c, 56, 8, 56, 12, "#6e3e22")
for i = -3, 3 do B.ln(c, 56, 8, 56 + i, 3, "#fffdf6") end
c:px(56, 13, "#4a2a1a")
D.fin()
