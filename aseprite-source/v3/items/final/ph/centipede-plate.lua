-- centipede-plate (v3 first draft, dB15). quirk: a parsley sprig garnishes the rim
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("centipede-plate")
D.shadow(c, 32, 52, 26, 3)
local plate = B.ell(32, 40, 26, 13, 0)
H.lit(c, plate, "stone", { R = 3 })
local well = B.ell(32, 40, 19, 9, 0)
H.lit(c, well, { "#444663", "#74758c", "#8e8ea4", "#aaa9b8", "#c4c3d0", "#e2e0e6" }, { R = 3, amb = 0.2 })
local SEG = { { "#6e2038", "#b52e3f", "#d03c3a", "#e8493b", "#ff6a4c", "#ff8a5c" }, { "#8f4a1f", "#d98322", "#e89a28", "#f5b82e", "#ffd060", "#ffe38a" } }
local pts = {}
for i = 0, 11 do local t = i / 11 pts[#pts + 1] = { 49 - 34 * t, 40 + 4 * sin(t * pi * 2.1) } end
for i = #pts, 1, -1 do   -- tail first, head last
  local p = pts[i]
  local x, y = floor(p[1] + .5), floor(p[2] + .5)
  B.ln(c, x, y - 2, x - 1, y - 5, "#74240f") B.ln(c, x, y + 2, x + 1, y + 5, "#74240f")
  H.lit(c, B.ell(x, y, 3, 2.6, 0), SEG[i % 2 + 1], { R = 1.6 })
end
local hx, hy = pts[1][1], pts[1][2]
H.lit(c, B.ell(hx + 2, hy, 4, 3.4, 0), "ember", { R = 2 })
c:px(hx + 3, hy - 1, "#2b1c26") c:px(hx + 3, hy + 1, "#2b1c26")
B.ln(c, hx + 5, hy - 2, hx + 8, hy - 5, "#6e2038") B.ln(c, hx + 5, hy + 2, hx + 8, hy + 5, "#6e2038")
c:px(hx + 6, hy, "#2b1c26") c:px(hx + 6, hy + 1, "#2b1c26")
-- parsley sprig
for _, L in ipairs{ {14, 33, 3, 2.4, -0.6}, {18, 31, 3, 2.4, 0.3}, {16, 35, 2.6, 2, 0.8} } do H.lit(c, B.ell(L[1], L[2], L[3], L[4], L[5]), "moss", { R = 1.5 }) end
D.fin()
