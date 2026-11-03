-- beeswax: a slab of pale-gold beeswax in 3/4 view, honeycomb stamped on top and a bevelled front. quirk: a tiny bee has landed on it and left a wax-smudged footprint.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("beeswax")
local W = D.WAX
D.sh(32, 52, 22, 3)
local front = c:rect(10, 32, 44, 48)
local side = c:poly{ {44,32}, {54,24}, {54,40}, {44,48} }
local top = c:poly{ {10,32}, {20,24}, {54,24}, {44,32} }
D.lit(front, W, 3, { amb = .1 })
D.lit(side, { W[1], W[2], W[2], W[3], W[3], W[4] }, 2)
D.lit(top, { W[2], W[3], W[4], W[5], W[5], W[6] }, 2, { wrap = .5 })
-- edges: bright bevel on top front edge, deep lines between faces
for x = 10, 44 do c:px(x, 32, W[6]) end
for y = 32, 48 do c:px(44, y, W[1]) end
for i = 0, 8 do c:px(44 + i, 32 - i, W[1]) end
for y = 33, 46 do c:px(11, y, W[5]) end
-- honeycomb on top
local hex = { ".xx.", "x..x", ".xx." }
for i, x in ipairs{ 24, 30, 36, 42 } do
  c:paint(hex, x - (i % 2) * 1, 26 + (i % 2), { x = W[3] })
end
-- stamped comb on front: 3 big hex cells
local big = { "..xxxx..", ".x....x.", "x......x", ".x....x.", "..xxxx.." }
for i, x in ipairs{ 14, 22, 30 } do c:paint(big, x, 36 + (i % 2) * 2, { x = W[2] }) end
-- melted drip off the bottom edge
c:px(38, 49, W[3]) c:px(38, 50, W[3]) c:px(38, 51, W[4]) c:px(37, 49, W[3])
-- bee with footprint
c:px(26, 29, W[2]) c:px(27, 29, W[2])
D.bee(34, 26)
D.fin()
