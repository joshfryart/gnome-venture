-- cherimoya (v3 first draft, dB15). quirk: a cut quarter shows white flesh and black seeds
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("cherimoya")
D.shadow(c, 30, 54, 22, 3)
local CH = { "#2f5a3a", "#4a8a48", "#78b254", "#9ccd6c", "#bce28a", "#dff4b4" }
local body = B.ell(26, 34, 15, 15, 0):add(B.ell(26, 24, 11, 9, 0))
H.lit(c, body, CH, { R = 5 })
for y = 17, 48, 4 do for x = 14, 40, 4 do
  local xx = x + ((y // 4) % 2) * 2
  if body:has(xx, y) and body:has(xx, y + 2) then c:px(xx, y + 1, CH[2]) c:px(xx - 1, y, CH[2]) c:px(xx + 1, y, CH[2]) c:px(xx, y - 1, CH[5]) end
end end
H.lit(c, c:rect(25, 11, 27, 14), "wood", { R = 1 })
-- cut wedge piece, lower right
local rind = B.ell(46, 44, 9, 9, 0):clip(c:rect(36, 40, 58, 58))
H.lit(c, rind, CH, { R = 2 })
local flesh = B.ell(46, 44, 7, 7, 0):clip(c:rect(37, 41, 58, 58))
H.lit(c, flesh, { "#cfc49c", "#e4dcb8", "#f2ecd0", "#faf4de", "#fffaec", "#fff8e8" }, { R = 3 })
for _, p in ipairs{ {42, 45}, {47, 47}, {51, 45}, {45, 50} } do c:fillMask(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#2a1a1e") c:px(p[1], p[2], "#6a5058") end
D.fin()
