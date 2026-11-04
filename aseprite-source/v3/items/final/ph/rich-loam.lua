-- rich-loam (final draft D12, Sonnet). A crumbly mound of dark, fertile loam with clods, a couple of pebbles and a tiny
-- green shoot on top. quirk: a pink earthworm waves out of the left side of the heap.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rich-loam")
D.shadow(c, 32, 56, 25, 3)
local mound = c:ellipse(32, 44, 24, 15):clip(c:rect(0, 0, 63, 55))
local idx = D.lit(c, mound, D.R.soil, 9, { wrap = 0.3 })
-- clods
local rnd = D.rng(31)
for i = 1, 14 do
  local x, y = floor(14 + rnd() * 36), floor(32 + rnd() * 20)
  if mound:has(x, y) and mound:has(x + 3, y + 2) then
    local m = B.ell(x, y, 2.4 + rnd() * 1.2, 1.7 + rnd() * .6, rnd() * 3)
    m:clip(mound)
    B.lit(c, m, D.R.soil, 1.6, { wrap = 0.25 }) end
end
-- pebbles
for _, q in ipairs{ {22,46},{44,40} } do local m = B.ell(q[1], q[2], 2.2, 1.6, 0.2) B.lit(c, m, D.R.stone, 1.5) end
-- sprout
D.ln(c, 33, 33, 33, 22, "#8cc066") D.ln(c, 34, 33, 34, 23, "#5b9a52")
B.lit(c, B.ell(29, 21, 3.4, 2, -0.5), D.R.leaf, 1.6) B.lit(c, B.ell(38, 21, 3.4, 2, 0.5), D.R.leaf, 1.6)
-- worm
local WM = { "#7d2c5e", "#a8446e", "#d06484", "#e88aa0", "#f6b0bc", "#ffd0d8" }
local wm, T = D.sw(c, { {12,46},{6,44},{6,36},{11,32} }, function(t) return 1.8 - 0.4 * t end, WM, 1.6)
wm:each(function(x, y) local t = T[K(x, y)] or 0 if floor(t * 9) % 2 == 0 and t > 0.1 then c:px(x, y, WM[3]) end end)
c:px(11, 32, "#2b1c26")
D.fin()
