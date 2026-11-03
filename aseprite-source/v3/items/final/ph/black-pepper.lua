-- black-pepper: a hanging spike of wrinkled peppercorns ripening green, red then black down the strand, on a vine node with a heart-shaped leaf. quirk: one black corn has fallen and cracked open to show its white heart.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("black-pepper")
local GR = { "#1c3a20", "#2c5a2c", "#44843c", "#68a84c", "#98cc68", "#d0f09c" }
local RD = D.RED
local BK = { "#0e0a10", "#1c1620", "#2c2430", "#403848", "#5e5468", "#8a8094" }
-- vine
local vm, vn = D.tube({ {8,10}, {16,6}, {30,6}, {44,8} }, function(t) return 1.4 end)
D.tn(vm, vn, { "#3a5a30", "#56803c", "#7aa04c", "#a0c470" })
-- leaf (heart)
local lf = D.ell(48, 17, 8, 5.4, .55) lf:add(D.ell(44, 21, 4, 3.6, 0)) lf:add(D.ell(50, 13, 4, 3.6, 0))
D.lit(lf, D.LEAF2, 3.5)
D.ln(44, 10, 55, 20, "#c8e898") D.ln(48, 14, 53, 14, "#9ccc68") D.ln(47, 17, 52, 21, "#9ccc68")
-- strand
D.ln(24, 8, 24, 14, "#7aa04c") D.ln(25, 8, 25, 14, "#56803c")
local ramps = { GR, GR, GR, RD, RD, BK, BK, BK, BK }
for i = 1, 9 do
  local y = 15 + (i - 1) * 3.6
  local x = 24.5 + ((i % 2 == 0) and 3 or -3) * 1.0 - (i % 2 == 0 and 0 or 0)
  local m = D.ell(x, y, 3.6, 3.6, 0)
  D.lit(m, ramps[i], 2.8, { wrap = .3 })
  for _, d in ipairs{ {-1,0}, {1,1}, {0,-1} } do if X.hash(floor(x), floor(y), i) > .3 then c:px(floor(x) + d[1], floor(y) + d[2], ramps[i][2]) end end
  c:px(floor(x - 1.5), floor(y - 1.5), i > 5 and "#e6e0f0" or "#fff4d6")
end
-- fallen cracked corn
c:fillMask(D.ell(15, 57, 5, 2.6, 0), "#1d1523")
local fc = D.ell(14, 54, 4.4, 4.4, 0) D.lit(fc, BK, 3.5)
D.lit(D.ell(25, 55, 4.4, 4.4, 0), BK, 3.5)
c:px(12, 51, "#e6e0f0")
c:paint({ "x.x", ".x.", "x.x" }, 23, 54, { x = "#f4efe6" }) c:px(24, 55, "#d8d0c0")
for y = 51, 58 do c:px(25, y, y % 2 == 0 and "#f4efe6" or BK[1]) end
D.fin()
