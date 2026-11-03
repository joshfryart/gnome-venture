local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- bark-path: a winding stepping path of five round cut bark discs with rings and rough rims, tufts of grass between. quirk: a small red mushroom grows from the last disc.
local c = D.new("bark-path")
local BK = { "#2a1c1a", "#4a3028", "#6e4c3a", "#8e6a4c", "#b08a62", "#d0aa80" }
local d = { {13, 49, 8.5, 4.2}, {25, 42, 8, 4}, {36, 35, 7.4, 3.8}, {44, 27, 7, 3.6}, {52, 19, 6, 3.2} }
for i = #d, 1, -1 do
  local p = d[i]
  local rim = D.ell(p[1], p[2] + 2, p[3], p[4] + 1.4, 0) D.lit(rim, BK, 3)
  local top = D.ell(p[1], p[2], p[3] - 1, p[4], 0)
  D.lit(top, D.TAN, 2.2)
  c:fillMask(D.ell(p[1], p[2], p[3] * .55, p[4] * .5, 0), D.TAN[2]) c:fillMask(D.ell(p[1], p[2], p[3] * .22, p[4] * .22, 0), D.TAN[4])
  for x = p[1] - floor(p[3]) + 2, p[1] + floor(p[3]) - 2, 3 do D.px(x, p[2] + p[4] + 1, "#2a1c1a") end
end
for _, g in ipairs{{20, 52}, {30, 45}, {41, 38}, {47, 31}} do D.ln(g[1], g[2], g[1] - 1, g[2] - 3, "#45954c") D.ln(g[1] + 1, g[2], g[1] + 2, g[2] - 4, "#6ab455") end
D.lit(D.ell(52, 14, 3, 2, 0), D.RED, 2) D.ln(52, 16, 52, 18, "#f6e6bf") D.px(51, 13, "#fff4d6")
D.fin()
