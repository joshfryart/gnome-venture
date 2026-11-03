-- cardboard-sheet (first draft, Sonnet). quirk: a loose strip of brown tape and a muddy boot print
local NAME = "cardboard-sheet"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local CB = { "#5e3a22", "#8a5a34", "#b07e48", "#cf9e62", "#e4bc82", "#f4d8a6" }
-- sheet as parallelogram, slightly tilted
local top = c:poly{ {10, 20}, {52, 10}, {56, 40}, {14, 50} }
B.lit(c, top, CB, 6)
-- thickness edge (corrugated)
local edge = c:poly{ {14, 50}, {56, 40}, {56, 46}, {14, 56} }
c:fillMask(edge, CB[2])
for i = 0, 20 do local x = 14 + i * 2 local y = 50 + floor(-(i * 2) * 10 / 42 + .5) c:px(x, y + 2, CB[1]) c:px(x, y + 4, CB[4]) c:px(x + 1, y + 3, CB[3]) end
-- corrugation lines
for k = 1, 5 do B.ln(c, 12 + k * 1, 24 + k * 5, 54 + k * 0, 14 + k * 5, CB[3], top) end
-- torn corner
c:fillMask(c:poly{ {50, 10}, {56, 40}, {51, 38}, {53, 30}, {49, 24} }, CB[5])
-- tape
local tp = c:poly{ {20, 18}, {28, 16}, {32, 44}, {24, 46} }
B.lit(c, tp, { "#6a4a14", "#a8802a", "#cca444", "#e0c060", "#f0d888", "#fff0b8" }, 2)
-- boot print
for _, r in ipairs{ {40, 28, 5, 3}, {42, 35, 4, 3} } do c:fillMask(B.ell(r[1], r[2], r[3], r[4]), CB[1]) end
for x = 38, 44 do c:px(x, 28, CB[3]) end
D.fin()
