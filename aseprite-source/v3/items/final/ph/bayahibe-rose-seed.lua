local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- bayahibe-rose-seed: three small flat black seeds with a hint of papery wing on a fleshy Pereskia leaf scrap; sprout is a thin stem with thick oval succulent leaves and one tiny spine. quirk: a pink bud no bigger than a seed.
local c = D.new("bayahibe-rose-seed")
D.scrap(6, 55, 56, 49, 6.5, D.LEAF, {veins = {}})
for _, p in ipairs{{20, 52, 0.3}, {30, 53, -0.2}, {40, 52, 0.5}} do
  D.seed(p[1], p[2], 3.2, 2.4, p[3], D.BLK, "#7c6a82")
  D.ln(p[1] + 3, p[2] - 2, p[1] + 5, p[2] - 3, "#c9a98a")
end
D.lit(D.ell(49, 51, 2.4, 2, 0), D.PINK, 1.6) c:px(48, 50, "#ffc9d8")
D.stem(31, 49, 31, 24, "#86b86c") D.stem(32, 49, 32, 24, "#6a9a58")
for _, p in ipairs{{37, 42, 0.3}, {26, 36, -0.3}, {37, 30, 0.2}, {26, 26, -0.2}} do D.lf(p[1], p[2], 5, 2.8, p[3], D.LEAF2) end
D.lf(32, 20, 2.6, 4, 0, D.LEAF2) D.ln(29, 40, 27, 40, "#fff4d6")
D.fin()
