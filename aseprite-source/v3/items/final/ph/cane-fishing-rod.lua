-- cane-fishing-rod (first draft, Sonnet). quirk: a tiny frog sits on the bobber
local NAME = "cane-fishing-rod"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local BAM = { "#4a3a14", "#7a6a1e", "#a8982e", "#cdbf4a", "#e6dc72", "#f6f0a8" }
-- line first
local rod = D.rod(c, 8, 56, 52, 10, 2.2, 0.9, BAM)
-- nodes
for _, t in ipairs{ 0.2, 0.42, 0.62, 0.8 } do
  local x, y = 8 + 44 * t, 56 - 46 * t
  for d = -2, 2 do local px, py = floor(x + d * 0.7 + .5), floor(y + d * 0.7 + .5) c:px(px, py, BAM[2]) end
  c:px(floor(x + .5), floor(y - 1.5), BAM[6])
end
-- cork handle
local hm = D.rod(c, 6, 59, 14, 50, 2.6, 2.6, "wood")
-- line to tip
B.ln(c, 52, 10, 54, 11, "#e8e4d8")
B.polyline(c, { {52, 10}, {55, 20}, {50, 30}, {40, 38}, {38, 46} }, "#e8e4d8")
-- bobber
D.ball(c, 38, 48, 3.6, 3.6, "ember")
c:fillMask(c:rect(34, 49, 42, 50), "#fff4d6")
-- hook
B.polyline(c, { {38, 52}, {38, 56}, {40, 58}, {42, 56} }, "#cfd2e0")
-- frog on bobber
local fm = B.ell(38, 43, 2.6, 1.8) B.lit(c, fm, "moss", 1.6)
c:px(37, 41, "#fff4d6") c:px(40, 41, "#fff4d6") c:px(37, 41, "#2b1c26") c:px(40, 41, "#2b1c26")
D.fin()
