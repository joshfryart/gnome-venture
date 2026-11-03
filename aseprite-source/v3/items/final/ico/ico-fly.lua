local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-fly: housefly from above with two pale veined wings and red eyes.
-- quirk: it leaves a dotted flight loop behind it.
local c = D.new("ico-fly")
local WING = { "#7a9ac0", "#a8c4e0", "#cce0f2", "#e4f0fa", "#f2f8fe", "#fbfdff" }
for _, w in ipairs{ {19,24,0.85,-1},{45,24,-0.85,1} } do
  local m = D.ell(w[1], w[2], 14, 7, w[3])
  D.lit(m, WING, 7, { amb = 0.05 })
  D.ln(c, w[1] - 10 * w[4] * -1 * -1 + 0, w[2], w[1], w[2], WING[1], m)
end
for _, l in ipairs{ { {26,38},{16,42},{12,50} }, { {26,44},{19,52},{20,58} }, { {38,38},{48,42},{52,50} }, { {38,44},{45,52},{44,58} } } do
  c:part(c:line(l, 3), D.BRN, { band = 1, nopop = true, noshade = true })
end
local body = D.ell(32, 43, 8, 13, 0)
D.lit(body, { "#1c1a24", "#2e2c3a", "#46445a", "#605e78", "#807e9a", "#a8a6c0" }, 8, { amb = 0.05 })
for y = 40, 52, 4 do D.fill(c:rect(26, y, 38, y), "#1c1a24") end
local hd = c:ellipse(32, 26, 7, 6)
D.lit(hd, { "#1c1a24", "#2e2c3a", "#46445a", "#605e78", "#807e9a", "#a8a6c0" }, 5)
for _, ex in ipairs{ 26, 38 } do D.lit(D.disc(ex, 24, 4), D.RED, 3, { amb = 0.05 }) c:px(ex - 1, 22, "#ffc0a0") end
D.fill(c:rect(31, 31, 33, 32), "#e8b028")
for _, d in ipairs{ {52,56},{57,50},{58,43} } do D.fill(c:rect(d[1], d[2], d[1] + 1, d[2] + 1), "#aaa6b8") end
D.fin()
