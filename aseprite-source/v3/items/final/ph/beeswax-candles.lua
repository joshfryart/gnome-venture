-- beeswax-candles: two hand-dipped beeswax tapers (tall lit one, short stamped one) in a small brass dish. quirk: the short candle has a tiny bee stamped in its side and a wax drip pooling on the dish.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("beeswax-candles")
local W = D.WAX
local BR = { "#5a3414", "#8a5a1c", "#b8821e", "#dcac2c", "#f6d24c", "#fff0a0" }
D.sh(32, 55, 20, 3)
-- dish
local dish = D.ell(32, 51, 19, 4, 0)
D.lit(dish, BR, 3)
for x = 16, 48 do c:px(x, 49, BR[6]) end
c:px(25, 52, BR[6]) c:px(26, 52, BR[5])
-- tall candle
local A = c:rect(20, 18, 26, 50)
D.vc(A, W, 20, 26)
local B = c:rect(35, 30, 40, 50)
D.vc(B, W, 35, 40)
-- tops (rims)
for _, t in ipairs{ {A, 20, 26, 18}, {B, 35, 40, 30} } do
  for x = t[2], t[3] do c:px(x, t[4], W[6]) end
  for x = t[2] + 1, t[3] - 1 do c:px(x, t[4] - 1, W[5]) end
end
-- wicks + flame
c:px(23, 16, "#3a2a2a") c:px(23, 17, "#3a2a2a")
local fl = D.ell(23, 10, 2.2, 4, 0)
D.lit(fl, { "#d9541e", "#f27a1e", "#ff9e2a", "#ffc23a", "#ffe27a", "#fff8c8" }, 2)
c:px(23, 12, "#fff8c8") c:px(23, 13, "#fff8c8") c:px(23, 14, "#8ad0ff")
c:px(35, 28, "#3a2a2a") c:px(35, 29, "#3a2a2a") c:px(36, 29, W[4])
-- drips on tall candle
for _, d in ipairs{ {25, 19, 24}, {21, 19, 28}, {26, 21, 33} } do for y = d[2], d[3] do c:px(d[1], y, W[5]) end c:px(d[1], d[3] + 1, W[4]) end
-- bee stamp on short candle
c:paint({ "..xx..", ".yyyy.", ".zzzz." }, 35, 38, { x = W[6], y = W[2], z = W[1] })
c:px(35, 42, W[5]) c:px(40, 42, W[5])
-- pooled drip on dish
for x = 38, 43 do c:px(x, 49, W[4]) end
for x = 39, 42 do c:px(x, 48, W[5]) end
D.fin()
