local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- bee-balm-seed: a pinch of tiny dark brown nutlets on a toothed minty leaf scrap; sprout has a square stem with opposite serrated leaves. quirk: a single crimson petal curls beside the seeds.
local c = D.new("bee-balm-seed")
D.scrap(6, 55, 56, 49, 7, D.LEAF, {veins = {7, 12, 17, 22, 27, 33, 39, 45}})
for i = 0, 8 do c:px(10 + i * 5, 51 + (i % 2) * 3 - floor(i * .5), "#2e7646") end
for _, p in ipairs{{20, 52}, {24, 54}, {28, 52}, {32, 54}, {26, 50}, {36, 52}} do D.seed(p[1], p[2], 2, 1.6, 0.5 + p[1] % 3, { "#2a1c18", "#3e2a22", "#563c2e", "#6e4e3a", "#8e6a50", "#b08e6e" }, "#d4b088") end
D.lit(D.ell(46, 51, 4.2, 2.2, -0.4), D.RED, 2) D.ln(43, 54, 46, 53, "#7a2036")
D.stem(32, 48, 32, 22, "#86b86c") D.stem(33, 48, 33, 22, "#6a9a58")
for _, y in ipairs{40, 30} do
  for _, sd in ipairs{-1, 1} do
    local m = D.ell(33 + sd * 6, y - 1, 5.5, 2.8, sd * -0.4)
    D.lit(m, D.LEAF2, 2) for k = -4, 4, 2 do D.px(33 + sd * (6 + k), y - 4 + (k % 4 == 0 and 0 or 5), D.LEAF2[2]) end
  end
end
D.lf(32, 19, 2.2, 3.2, 0, D.LEAF2)
D.fin()
