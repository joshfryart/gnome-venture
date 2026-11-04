-- cattail-root (first draft, Sonnet). quirk: a pale new shoot pushes up from one end
local NAME = "cattail-root"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local RT = { "#4a3222", "#6e4e34", "#947050", "#b89470", "#d8b890", "#f0dcb8" }
-- rhizome sweeps
local m, T = H.sweep({ {8, 46}, {20, 36}, {34, 56}, {52, 42} }, function(t) return 4.2 - t * 1.0 end)
X.tone(c, m, X.light(X.pillow(m, 3.6), { amb = 0.08, wrap = 0.25 }), RT, { cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 } })
-- rings (nodes)
m:each(function(x, y) local t = T[B.K(x, y)] if t and floor(t * 18) % 4 == 0 and (x + y) % 2 == 0 then c:px(x, y, RT[2]) end end)
-- cut end shows white
c:fillMask(B.ell(52, 42, 2, 3.2), "#fff4d6") c:px(52, 42, "#e0d4b0")
-- root hairs
for _, p in ipairs{ {16, 40}, {24, 43}, {30, 56}, {40, 54}, {46, 46} } do
  local dy = (p[2] > 45) and 4 or 5
  B.ln(c, p[1], p[2] + 3, p[1] - 2, p[2] + 3 + dy, RT[3])
end
-- shoot
D.rod(c, 14, 38, 12, 14, 1.8, 1.0, { "#6a8a3a", "#9ac460", "#c0e088", "#dcf0a8", "#eef8c8", "#fffce0" })
B.blade(c, 12, 22, 4, 10, 2.2, LEAF)
c:px(14, 30, "#6a8a3a") c:px(13, 26, "#6a8a3a")
D.fin()
