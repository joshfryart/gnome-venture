-- bilberries: an upright zig-zag bilberry sprig, five dusky-bloomed berries on short pedicels, small oval leaves. quirk: a green caterpillar is inching along the stem.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("bilberries")
local B = { "#1a1238", "#2c2060", "#42368a", "#5a4aa8", "#8678c8", "#b8aee8" }
-- zig-zag stem
local pts = { {30,56}, {24,46}, {36,36}, {26,26}, {34,14} }
for i = 1, #pts - 1 do D.ln(pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], "#5a8a40") D.ln(pts[i][1] + 1, pts[i][2], pts[i+1][1] + 1, pts[i+1][2], "#3a6a38") end
-- leaves
D.lf(14, 40, 5.5, 3, -.5, D.LEAF2) D.lf(46, 32, 5.5, 3, .6, D.LEAF2) D.lf(16, 24, 5, 2.8, -.4, D.LEAF2) D.lf(44, 14, 4.5, 2.6, .5, D.LEAF2)
D.ln(24, 46, 17, 42, "#c8e898") D.ln(36, 36, 43, 33, "#c8e898") D.ln(26, 26, 19, 24, "#c8e898") D.ln(34, 14, 41, 14, "#c8e898")
-- berries
local bs = { {18,52,5,26,50}, {44,46,5.5,35,44}, {22,35,5,25,35}, {44,22,5,32,25}, {26,10,4.6,29,15} }
for i, b in ipairs(bs) do
  D.ln(b[4], b[5], floor(b[1]), floor(b[2]), "#4a7a38")
  local m = D.ell(b[1], b[2], b[3], b[3], 0)
  D.lit(m, B, b[3] - .3, { wrap = .3 })
  m:each(function(x, y) if x + y < b[1] + b[2] + 2 and X.hash(floor(x / 2), floor(y / 2), i) > .55 then local cc = c:get(x, y) end end)
  c:px(floor(b[1] - b[3] * .45), floor(b[2] - b[3] * .5), "#f4f2ff") c:px(floor(b[1] - b[3] * .45) + 1, floor(b[2] - b[3] * .5), B[6])
  -- crown dot
  c:paint({ "x.x", ".x.", "x.x" }, floor(b[1] + 1), floor(b[2] + 1), { x = B[1] })
  c:px(floor(b[1] + b[3] * .5), floor(b[2] + b[3] * .6), "#4a76b8")
end
-- caterpillar
for i, p in ipairs{ {27,45}, {28,44}, {29,43}, {30,42} } do c:px(p[1], p[2], i % 2 == 0 and "#68b454" or "#9ccc68") end
c:px(31, 41, "#42944a") c:px(31, 42, D.INK)
D.fin()
