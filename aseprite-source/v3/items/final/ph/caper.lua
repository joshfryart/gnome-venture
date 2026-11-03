-- caper (first draft, Sonnet). quirk: one bud has opened into a tiny white flower
local NAME = "caper"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local TW = { "#2a3a1c", "#4a5a28", "#6a8038" }
B.polyline(c, { {10, 54}, {22, 44}, {34, 36}, {48, 22}, {56, 12} }, TW[2])
B.polyline(c, { {11, 55}, {23, 45}, {35, 37}, {49, 23}, {57, 13} }, TW[1])
-- round leaves
for _, l in ipairs{ {14, 44, 4.5, 3.4, -0.4}, {40, 44, 4.6, 3.4, 0.5}, {50, 30, 3.8, 3, -0.5} } do
  local m = B.ell(l[1], l[2], l[3], l[4], l[5]) B.lit(c, m, { "#173f36", "#2a6a3e", "#3e8a46", "#5aa650", "#80c060", "#b0dc80" }, 2)
  B.ln(c, l[1] - 2, l[2] + 1, l[1] + 2, l[2] - 1, "#b0dc80", m)
end
B.ln(c, 14, 48, 22, 44, TW[2]) B.ln(c, 40, 48, 36, 38, TW[2])
-- buds on pedicels
local buds = { {24, 54, 3.8, 3.4}, {32, 50, 3.4, 3.0}, {20, 36, 3, 2.7}, {46, 52, 3.5, 3.1} }
for _, b in ipairs(buds) do
  B.ln(c, b[1], b[2] - 3, b[1] - 2, b[2] - 7, TW[3])
  local m = B.ell(b[1], b[2], b[3], b[4]) B.lit(c, m, "moss", 2.2)
  c:px(b[1] - 1, b[2] - 1, "#e4f6a8")
end
-- open flower
local fx, fy = 52, 13
for i = 0, 3 do local a = i * pi / 2 + 0.4 local m = B.ell(fx + cos(a) * 3, fy + sin(a) * 3, 2.2, 1.4, a) B.lit(c, m, "sky", 1) c:fillMask(m, "#fff4d6") end
for i = 0, 5 do local a = i * pi / 3 B.ln(c, fx, fy, fx + floor(cos(a) * 5 + .5), fy + floor(sin(a) * 5 + .5), "#b080d0") end
c:px(fx, fy, "#f5b82e") c:px(fx + 1, fy, "#f5b82e")
D.fin()
