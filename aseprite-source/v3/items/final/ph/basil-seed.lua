local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- basil-seed: tiny jet-black seeds, two swollen in clear gel jackets, on a basil leaf scrap; sprout has two round cotyledons over a first leaf pair. quirk: a dew droplet on the scrap.
local c = D.new("basil-seed")
D.scrap(7, 55, 56, 50, 7, D.LEAF2, {veins = {8, 13, 18, 24, 30, 36, 42}})
for _, p in ipairs{{14, 52}, {19, 54}, {26, 52}, {44, 52}} do D.seed(p[1], p[2], 2.2, 1.9, 0.4, D.BLK, "#7c6a82") end
for _, p in ipairs{{33, 52}, {39, 54}} do
  c:fillMask(D.ell(p[1], p[2], 4.4, 3.8, 0.3), "#cfe8ec") c:fillMask(D.ell(p[1], p[2], 3.4, 2.8, 0.3), "#e4f4f4")
  D.seed(p[1], p[2], 2.2, 1.9, 0.4, D.BLK, "#7c6a82")
end
D.ln(48, 49, 48, 49, "#b4e8d0") D.lit(D.ell(50, 54, 1.6, 1.4, 0), D.TEAL, 1.2)
D.stem(31, 48, 31, 30, "#86b86c") D.stem(32, 48, 32, 30, "#6a9a58")
D.lf(24, 32, 4.5, 3.3, -0.2, D.LEAF2) D.lf(39, 32, 4.5, 3.3, 0.2, D.LEAF2)
D.lf(26, 23, 3.4, 2.4, -0.7, D.LEAF) D.lf(37, 23, 3.4, 2.4, 0.7, D.LEAF) D.lf(31, 19, 2, 3, 0, D.LEAF)
D.fin()
